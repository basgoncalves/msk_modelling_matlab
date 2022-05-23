function []=runMA(model_file, coordinates_file,GRFxml, results_directory, XMLTemplate, lowpassfcut,varargin)
% Function to run MA for a single trial
% Inputs:
%   model_file
%   coordinates_file
%   results_directory
%   XMLTemplate (used until problems with API will be solved)
%   lowpassfcut (optional)

% This file is part of Batch OpenSim Processing Scripts (BOPS).
% Copyright (C) 2015 Alice Mantoan, Monica Reggiani
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>


%%
fp = filesep;
import org.opensim.modeling.*

setupFileDir=[results_directory '\Setup'];
[~,trialName] = fileparts(results_directory);
osimModel = Model(model_file);

XML = xml_read([XMLTemplate]);

%Get the model
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



%% Save the settings in the Setup folder

DirIK = [fileparts(model_file) fp 'inverseKinematics' fp trialName fp 'setup_IK.xml'];
XML_IK = xml_read(DirIK);
[~,trialName] = fileparts(results_directory);
XML.AnalyzeTool.external_loads_file = relativepath(GRFxml,setupFileDir);
XML.AnalyzeTool.results_directory = relativepath(results_directory,setupFileDir);
XML.AnalyzeTool.model_file = relativepath(model_file,setupFileDir);
XML.AnalyzeTool.coordinates_file = relativepath(coordinates_file,setupFileDir);
XML.AnalyzeTool.initial_time = XML_IK.InverseKinematicsTool.time_range(1);
XML.AnalyzeTool.final_time = XML_IK.InverseKinematicsTool.time_range(2);
XML.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.start_time = XML_IK.InverseKinematicsTool.time_range(1);
XML.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.end_time = XML_IK.InverseKinematicsTool.time_range(2);

if nargin ==6
     XML.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = lowpassfcut;
else
    XML.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = -1;
end


%setup root and InverseKinematicsTool
setupFile='setup_MA.xml';
root = 'OpenSimDocument';
Pref.StructItem = false;
xml_write([setupFileDir '\' setupFile ],XML, root,Pref);
%% Run
cd(setupFileDir)
runAnalyzeTool(setupFileDir, setupFile);

%Save the log file in a Log folder for each trial
logFolder=[results_directory '\Log'];
if exist(logFolder,'dir') ~= 7
    mkdir (logFolder);
end
movefile([setupFileDir '\out.log'],[logFolder '\out.log'])
movefile([setupFileDir '\err.log'],[logFolder '\err.log'])
