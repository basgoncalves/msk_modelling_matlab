function runRRA_BG2(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, XMLTemplate, setupFiles, varargin)
% Function to run Residual Reduction Analysis for a single trial
% Input - 'osimModel' - string which is the filename (including path) of the
%                OSIM file (model file)
%         'coordinates_file' - desired kinematics MOT file for ID
%         'forces_file' - filename string of the XML file containing GRF
%         information
%   XMLTemplate (used until problems with API will be solved)
%   lowpassfcut (optional)
%         'RRATaskFile' - filename string of the Tasks XML file
%         'RRAForceFile' - filename string of the Actuator XML file
%         'RRAConstraintsFile' - File containing the constraints on the
%               controls. (No longer required)
%         'RRAControlsFile' - File containing the controls output by RRA.
%               These can be used to place constraints on the residuals
%               during CMC. (No longer required)
%
% will need functions - BG June 2020
%   OrganiseFAI
%   convertPathToLinux
%   relativepath
%   xml_read
%   btk_loadc3d
%   combineForcePlates_multiple
%   GCOS
%
% Notes:
%   * If RRA time window is defined as for example, 3.41-3.64s, the algorithm
%   runs during 3.41-3.639. Don't know why! 
%   RRArms window RRA and IK do not agree. RRA final = 3.6390 instead of 3.6400
%   Also, in the very last 0.1 second the sample frequency increases exponentially   
%   see ExampleData ..\residualReductionAnalysis\RunA1\RRA_10 and ...\RRA11
% 
% cutting tasks = from foot contact – 0.1 sec until foot off + 0.1 sec
% running tasks = max pelvis position (late swing) to max pelvis position (early swing) 
% SJ            =  1 sec before take-off (zero force level);



%%
import org.opensim.modeling.*
fp = filesep;
% Make copy of generic RRA tool setup to edit
rraXML = xml_read(XMLTemplate);

%Set the model
rraXML.RRATool.model_file = relativepath(osimModel,results_directory);
[~,trialName,~] = fileparts(fileparts(coordinates_file));
rraXML.RRATool.ATTRIBUTE.name = trialName;

rraXML.RRATool.replace_force_set = 'true';

rraXML.RRATool.results_directory = results_directory;
rraXML.RRATool.output_precision = 16;

for ii = 1:length(setupFiles)
    setupFiles{ii} = relativepath(setupFiles{ii},results_directory);
end

% Setup files needed to run RRA
RRAForceSetFile = setupFiles{1};
RRATaskFile = setupFiles{2};
RRAConstraintsFile = setupFiles{3};

% Get mot data to determine time range (might have to be grf data
motData = load_sto_file(coordinates_file);
DirElaborated = fileparts(fileparts(fileparts(coordinates_file)));
DirC3D = strrep(DirElaborated,'ElaboratedData', 'InputData');
OrganiseFAI


% copy IK file 
cd([DirIK fp trialName])
copyfile('IK.mot',results_directory)

%% Define times to perform analysis over - BG
% Get initial and intial time
if contains (trialName, 'run','IgnoreCase',1) || contains(trialName,'SJ','IgnoreCase',1) ||...
        contains(trialName,'SquatNorm','IgnoreCase',1) 
    
    TimeWindow = TimeWindow_FatFAIS_RRA(DirC3D,trialName,TestedLeg);
    initial_time = TimeWindow(1);
    final_time =  TimeWindow(2);
else
   return
end

rraXML.RRATool.initial_time = initial_time;
rraXML.RRATool.final_time = final_time;

% change COM adjustments time window (shorten a little to avoid forceplate
% artifacts)
rraXML.RRATool.initial_time_for_com_adjustment = initial_time;
rraXML.RRATool.final_time_for_com_adjustment = final_time;

%% Set optimiser settings 
rraXML.RRATool.solve_for_equilibrium_for_auxiliary_states = 'false';
rraXML.RRATool.maximum_number_of_integrator_steps = 20000;

rraXML.RRATool.maximum_integrator_step_size = 1;
rraXML.RRATool.minimum_integrator_step_size = 1e-8;
rraXML.RRATool.integrator_error_tolerance = 1e-5;
rraXML.RRATool.optimization_convergence_tolerance = 1e-4;

%% define filepaths 
% Coordinates and external loads files
rraXML.RRATool.desired_kinematics_file = relativepath(coordinates_file,results_directory);

rraXML.RRATool.external_loads_file = relativepath(external_loads_file,results_directory);

% Set actuators (force set) file
rraXML.RRATool.force_set_files = RRAForceSetFile;
rraXML.RRATool.lowpass_cutoff_frequency = 6;

% task xml
rraXML.RRATool.task_set_file = relativepath(RRATaskFile,results_directory);

% Define setup file name and output model name
[~ ,ModelName] = fileparts(osimModel);

outputModel = [results_directory fp ModelName '_rra.osim'];
rraXML.RRATool.output_model_file = relativepath(outputModel,results_directory);

% tranform these from double to string
rraXML.RRATool.defaults.CMC_Joint.active = ['false ' 'false ' 'false'];
rraXML.RRATool.defaults.PointActuator.point = ['0 ' '0 ' '0'];
rraXML.RRATool.defaults.PointActuator.direction = ['-1 ' '0 ' '0'];
rraXML.RRATool.defaults.TorqueActuator.axis = ['-1 ' '-0 ' '-0'];

%% Save the settings in the Setup folder
setupFileDir=[results_directory];
setupFile='RRA_setup.xml';
root = 'OpenSimDocument';
xml_write([setupFileDir fp setupFile], rraXML,root);

%% Run
disp('')
disp('')
disp('RRA window from TO to TO with mass ajusted during stance')
disp('Running residual reduction algorithm...')
disp('')

% run RRA and print log
fileout = [setupFileDir fp setupFile];
cd(fileparts(fileout))
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

% [~,itr] = fileparts(fileparts(fileout));
% motion = 'pelvis_ty'
% compareIKwithRRA (DirElaborated,trialName,motion,itr)

disp('')
disp('')
disp('Out and err log files printed')
disp('')




