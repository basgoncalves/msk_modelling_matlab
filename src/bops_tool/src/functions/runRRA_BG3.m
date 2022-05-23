function outputFile = runRRA_BG3(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, XMLTemplate, setupFiles, varargin)
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


%%
import org.opensim.modeling.*

fp = filesep;

% Make copy of generic RRA tool setup to edit
rraTool=RRATool(XMLTemplate, 0);
%Set the model
rraTool.setModel(osimModel);
ModelFilename = char(osimModel.getDocumentFileName());
ModelFilename = convertPathToLinux(relativepath(ModelFilename,results_directory));
rraTool.setModelFilename(ModelFilename);
[~,trialName,~] = fileparts(fileparts(coordinates_file));
rraTool.setName(trialName)

rraTool.setReplaceForceSet(true);

rraTool.setResultsDir(convertPathToLinux(results_directory));
rraTool.setOutputPrecision(16)

for ii = 1:length(setupFiles)
    setupFiles{ii} = convertPathToLinux(relativepath(setupFiles{ii},results_directory));
end

% Setup files needed to run RRA
RRAForceSetFile = setupFiles{1};
RRATaskFile = setupFiles{2};
RRAConstraintsFile = setupFiles{3};

% Get mot data to determine time range (might have to be grf data
motData = Storage(coordinates_file);
grfData = Storage(GRFmot_file);
DirElaborated = fileparts(fileparts(fileparts(coordinates_file)));
DirC3D = strrep(DirElaborated,'ElaboratedData', 'InputData');
OrganiseFAI

% Define times to perform analysis over
% Get initial and intial time
initial_time = motData.getFirstTime();
data = btk_loadc3d([DirC3D fp trialName '.c3d']);
%find where GRF are present
acq = xml_read([DirC3D fp 'acquisition.xml']);
idx = find(contains({acq.Trials.Trial.Type},trialName(1:end-1)));
FPN = find(contains({acq.Trials.Trial(idx).StancesOnForcePlatforms.StanceOnFP.leg},TestedLeg));
idx =[];
for pp = 1:length(FPN)
    Fz = data.fp_data.GRF_data(FPN(pp)).F(:,3); % vert GRF for the tested leg
    idx = unique([idx; find(Fz)]);
end
fs = data.fp_data.Info(1).frequency;
frameTime = 1/ fs;
timeWindow = idx ./ fs;
final_time = initial_time + timeWindow(end) + 20*frameTime;
initial_time = initial_time + timeWindow(1) - 20*frameTime;


rraTool.setInitialTime(initial_time);
rraTool.setFinalTime(final_time);

% Set optimiser settings
rraTool.setSolveForEquilibrium(false)
rraTool.setMaximumNumberOfSteps(20000)
%analyzeTool.setMaxDT(1e-005)
rraTool.setMaxDT(1)
rraTool.setMinDT(1e-008)
rraTool.setErrorTolerance(1e-005)

%% Residual reduction analysis

% Coordinates and external loads files
coordinates_file = convertPathToLinux(relativepath(coordinates_file,results_directory));
rraTool.setDesiredKinematicsFileName(coordinates_file);

external_loads_file = convertPathToLinux(relativepath(external_loads_file,results_directory));
rraTool.setExternalLoadsFileName(external_loads_file);

% Set actuators (force set) file
forceSet = ArrayStr();
forceSet.append(RRAForceSetFile);
rraTool.setForceSetFiles(forceSet);
rraTool.setLowpassCutoffFrequency(6); %the default value is -1.0, so no filtering

% define other input files
RRATaskFile = convertPathToLinux(relativepath(RRATaskFile,results_directory));
rraTool.setTaskSetFileName(RRATaskFile);
% rraTool.setConstraintsFileName(RRAConstraintsFile);

%% Save the settings in the Setup folder
setupFileDir=[results_directory];

% Define setup file name and output model name
setupFile='RRA_setup.xml';
[~ ,ModelName] = fileparts(char(osimModel.getDocumentFileName));

outputFile =[ModelName '_rra'];
outputModel = [results_directory fp outputFile '.osim'];
outputModel = convertPathToLinux(relativepath(outputModel,results_directory));

rraTool.setOutputModelFileName(outputModel);
rraTool.print([setupFileDir fp setupFile]);

% change COM adjustments - BG
initial_time = motData.getFirstTime();
RRA = xml_read ([setupFileDir fp setupFile]);
acq = xml_read([DirC3D fp 'acquisition.xml']);
idx = find(contains({acq.Trials.Trial.Type},trialName(1:end-1)));
FPN = find(contains({acq.Trials.Trial(idx).StancesOnForcePlatforms.StanceOnFP.leg},TestedLeg));
idx =[];
for pp = 1:length(FPN)
    Fz = data.fp_data.GRF_data(FPN(pp)).F(:,3); % vert GRF for the tested leg
    idx = unique([idx; find(Fz)]);
end
fs = data.fp_data.Info(1).frequency;
frameTime = 1/ fs;
timeWindow = idx ./ fs;
final_time = initial_time + timeWindow(end) + 20*frameTime;
initial_time = initial_time + timeWindow(1) - 20*frameTime;
RRA.RRATool.initial_time_for_com_adjustment = initial_time;
RRA.RRATool.final_time_for_com_adjustment = final_time;
RRA.RRATool.defaults.CMC_Joint.active = ['false ' 'false ' 'false'];
root = 'OpenSimDocument';
xml_write([setupFileDir fp setupFile], RRA,root);

%% Run
disp('')
disp('')
disp('RRA window and mass ajusted during stance')
disp('Running residual reduction algorithm...')
disp('')

% run RRA
fileout = [setupFileDir fp setupFile];
cd(fileparts(fileout))
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

disp('')
disp('')
disp('Out and err log files printed')
disp('')
