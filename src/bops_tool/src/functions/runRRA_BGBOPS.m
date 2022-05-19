function [outputFile] = runRRA_BGBOPS(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, XMLTemplate, setupFiles, varargin)
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
setupFileDir=[results_directory fp 'Setup' fp];

%Set the model
rraTool.setModel(osimModel);
ModelFilename = char(osimModel.getDocumentFileName());
ModelFilename = convertPathToLinux(relativepath(ModelFilename,setupFileDir));
rraTool.setModelFilename(ModelFilename);
[~,trialName,~] = fileparts(fileparts(coordinates_file));
rraTool.setName(trialName)

rraTool.setReplaceForceSet(true);

rraTool.setResultsDir(convertPathToLinux(results_directory));
rraTool.setOutputPrecision(16)

for ii = 1:length(setupFiles)
    setupFiles{ii} = convertPathToLinux(relativepath(setupFiles{ii},setupFileDir));
end

% Setup files needed to run RRA
RRAForceSetFile = setupFiles{1};
RRATaskFile = setupFiles{2};
RRAConstraintsFile = setupFiles{3};

% Get mot data to determine time range (might have to be grf data
motData = Storage(coordinates_file);
grfData = Storage(GRFmot_file);
DirElaborated = fileparts(fileparts(fileparts(fileparts(coordinates_file))));
DirC3D = strrep(DirElaborated,'ElaboratedData', 'InputData');
OrganiseFAI
c3dData = btk_loadc3d([DirC3D fp trialName '.c3d']);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

% Define times to perform analysis over 
rraTool.setInitialTime(initial_time);
rraTool.setFinalTime(final_time);


% Set optimiser settings and define filepaths 
rraTool.setSolveForEquilibrium(false)
rraTool.setMaximumNumberOfSteps(20000)
%analyzeTool.setMaxDT(1e-005)
rraTool.setMaxDT(1)
rraTool.setMinDT(1e-008)
rraTool.setErrorTolerance(1e-005)

% Coordinates and external loads files
coordinates_file = convertPathToLinux(relativepath(coordinates_file,setupFileDir));
rraTool.setDesiredKinematicsFileName(coordinates_file);

external_loads_file = convertPathToLinux(relativepath(external_loads_file,setupFileDir));
rraTool.setExternalLoadsFileName(external_loads_file);

% Set actuators (force set) file
forceSet = ArrayStr();
forceSet.append(RRAForceSetFile);
rraTool.setForceSetFiles(forceSet);
rraTool.setLowpassCutoffFrequency(5); %the default value is -1.0, so no filtering

% define other input files
RRATaskFile = convertPathToLinux(relativepath(RRATaskFile,results_directory));
rraTool.setTaskSetFileName(RRATaskFile);
% rraTool.setConstraintsFileName(RRAConstraintsFile);

%% Save the settings in the Setup folder

if exist(setupFileDir,'dir') ~= 7
    mkdir (setupFileDir);
end

% Define setup file name and output model name
setupFile='RRA_setup.xml';
[~,ModelName] = fileparts(char(osimModel.getDocumentFileName));
rraTool.setOutputModelFileName([ModelName '_rraAdjusted.osim']);
rraTool.print([setupFileDir setupFile ]);


%% change COM adjustments time window - BG
acq = xml_read([fileparts(DirElaborated) fp 'acquisition.xml']);

% match name and number from acquisition file
idx = find(contains({acq.Trials.Trial.Type},trialName(1:end-1))); 
idx = idx(find([acq.Trials.Trial(idx).RepetitionNumber] == str2double(trialName(end)))); % match number

% find region where there is GRF  
FPN = find(contains({acq.Trials.Trial(idx).StancesOnForcePlatforms.StanceOnFP.leg},TestedLeg));
idx =[];
for pp = 1:length(FPN)
    Fz = c3dData.fp_data.GRF_data(FPN(pp)).F(:,3); % vert GRF for the tested leg
    idx = unique([idx; find(Fz)]);
end

fs = c3dData.fp_data.Info(1).frequency;
fsRatio = fs / c3dData.marker_data.Info.frequency;
frameTime = 1/ fs;
timeWindow = (idx+c3dData.marker_data.First_Frame*fsRatio) ./ fs;
initial_time = timeWindow(1) - 20*frameTime;
final_time = timeWindow(end) + 20*frameTime;

% update setup xml 
RRA = xml_read ([setupFileDir setupFile ]);
RRA.RRATool.initial_time_for_com_adjustment = initial_time;
RRA.RRATool.final_time_for_com_adjustment = final_time;
% tranform these from double to string
RRA.RRATool.defaults.CMC_Joint.active = ['false ' 'false ' 'false'];    
RRA.RRATool.defaults.PointActuator.point = ['0 ' '0 ' '0'];
RRA.RRATool.defaults.PointActuator.direction = ['-1 ' '0 ' '0'];
RRA.RRATool.defaults.TorqueActuator.axis = ['-1 ' '-0 ' '-0'];

% if it's the first RRA, do not use the first few frames the
% Comment out if IK has already been trimmed 
if ~contains(coordinates_file,'Kinematics_q.mot')
    RRA.RRATool.initial_time = rraTool.getInitialTime + fs/5*frameTime;
    RRA.RRATool.final_time = rraTool.getFinalTime - fs/5*frameTime;
end
root = 'OpenSimDocument';
xml_write([setupFileDir setupFile], RRA,root);

%% Run
disp('')
disp('')
disp('RRA window from TO to TO with mass ajusted during stance')
disp('Running residual reduction algorithm...')
disp('')

% run RRA and print log
fileout = [setupFileDir setupFile];
cd(fileparts(fileout))
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

%Save the log file in a Log folder for each trial
logFolder=[results_directory filesep 'Log' filesep ];
if exist(logFolder,'dir') ~= 7
    mkdir (logFolder);
end
movefile([setupFileDir 'out.log'],[logFolder 'out.log'])
movefile([setupFileDir 'err.log'],[logFolder 'err.log'])


disp('')
disp('')
disp('Out and err log files printed')
disp('')
