function []=runKinematics(osimModel, coordinates_file, results_directory, XMLTemplate,varargin)
% Function to run Kinematics Analysis for a single trial
% Inputs:
%   model_file
%   coordinates_file
%   results_directory
%   XMLTemplate (used until problems with API will be solved)
%   lowpassfcut (optional)

%%

import org.opensim.modeling.*

analyzeTool=AnalyzeTool(XMLTemplate);

%Set the model
analyzeTool.setModel(osimModel);
analyzeTool.setModelFilename(osimModel.getDocumentFileName());

analyzeTool.setReplaceForceSet(false);
analyzeTool.setResultsDir(results_directory);
analyzeTool.setOutputPrecision(8)

% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

analyzeTool.setInitialTime(initial_time);
analyzeTool.setFinalTime(final_time);

analyzeTool.setSolveForEquilibrium(false)
analyzeTool.setMaximumNumberOfSteps(20000)
%analyzeTool.setMaxDT(1e-005)
analyzeTool.setMaxDT(1)
analyzeTool.setMinDT(1e-008)
analyzeTool.setErrorTolerance(1e-005)

%% Kinematics Analysis

%since setComputeMoments(true) from API does not work, it is necessary to 
%load the XMLTemplate, and set just initial and final time

analyzeTool.getAnalysisSet().get(0).setStartTime(initial_time);
analyzeTool.getAnalysisSet().get(0).setEndTime(final_time);


%%

analyzeTool.setCoordinatesFileName(coordinates_file);

analyzeTool.setLowpassCutoffFrequency(-1); %the default value is -1.0, so no filtering

%% Save the settings in the Setup folder
setupFileDir=[results_directory '\Setup'];

if exist(setupFileDir,'dir') ~= 7
    mkdir (setupFileDir);
end

setupFile='setup_point_kin.xml';
analyzeTool.print([setupFileDir '\' setupFile ]);

%% Run
runAnalyzeTool(setupFileDir, setupFile);

%Save the log file in a Log folder for each trial
logFolder=[results_directory '\Log'];
if exist(logFolder,'dir') ~= 7
    mkdir (logFolder);
end
movefile([setupFileDir '\out.log'],[logFolder '\out.log'])
movefile([setupFileDir '\err.log'],[logFolder '\err.log'])
