function runRRA(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, XMLTemplate, setupFiles, varargin)
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


%%

import org.opensim.modeling.*
fp = filesep;
% Make copy of generic RRA tool setup to edit
rraTool=RRATool(XMLTemplate, 0);

%Set the model
rraTool.setModel(osimModel);
rraTool.setModelFilename(osimModel.getDocumentFileName());
modelName = char(osimModel.getName);
[~,trialName,~] = fileparts(fileparts(coordinates_file));
rraTool.setName(trialName)

rraTool.setReplaceForceSet(true);
rraTool.setResultsDir(results_directory);
rraTool.setOutputPrecision(16)

% Setup files needed to run RRA
RRAForceSetFile = setupFiles{1}; 
RRATaskFile = setupFiles{2};
RRAConstraintsFile = setupFiles{3};

% Get mot data to determine time range (might have to be grf data
motData = Storage(coordinates_file);
grfData = Storage(GRFmot_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

% Define times to perform analysis over 
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
rraTool.setDesiredKinematicsFileName(coordinates_file);
rraTool.setExternalLoadsFileName(external_loads_file);

% Set actuators (force set) file 
forceSet = ArrayStr();
forceSet.append(RRAForceSetFile);
rraTool.setForceSetFiles(forceSet);
rraTool.setLowpassCutoffFrequency(5); %the default value is -1.0, so no filtering

% define other input files
rraTool.setTaskSetFileName(RRATaskFile);
% rraTool.setConstraintsFileName(RRAConstraintsFile);

%% Save the settings in the Setup folder
setupFileDir=[results_directory filesep 'Setup' filesep];

if exist(setupFileDir,'dir') ~= 7
    mkdir (setupFileDir);
end

% Define setup file name and output model name
setupFile='RRA_setup.xml';
[~,ModelName] = fileparts(char(osimModel.getDocumentFileName));
rraTool.setOutputModelFileName([ModelName '_rraAdjusted.osim']);
rraTool.print([setupFileDir setupFile ]);
rraTool=RRATool([setupFileDir setupFile ]);

%% Run
disp('')
disp('Running residual reduction algorithm')
disp('')

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
