function []=runID(osimModel, coordinates_file, GRFmot_file, genericExtLoadFullPath, results_directory, lowpassfcut, varargin)
% Function to run ID for a single trial

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

import org.opensim.modeling.*
    
disp('Solving ID..')

idTool = InverseDynamicsTool();

idTool.setModel(osimModel);
idTool.setModelFileName(osimModel.getDocumentFileName());

%Set Input
idTool.setCoordinatesFileName(coordinates_file);
idTool.setLowpassCutoffFrequency(lowpassfcut);

% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

idTool.setStartTime(initial_time);
idTool.setEndTime(final_time);

%Set folders
idTool.setResultsDir(results_directory);
idTool.setOutputGenForceFileName([ 'inverse_dynamics.sto' ]);

%retrieve input dir
index=strfind(coordinates_file, '\ik');
idTool.setInputsDir(coordinates_file(1:index));

%Set forces_to_exclude
excludedForces = ArrayStr();
excludedForces.append('Muscles');
idTool.setExcludedForces(excludedForces);

%External Load File
externForcesTree = xml_read(genericExtLoadFullPath);

externForcesTree.ExternalLoads.datafile = GRFmot_file;
externForcesTree.ExternalLoads.external_loads_model_kinematics_file = coordinates_file;

if nargin<6 %if lowpassfcut is not defined by the user, it is taken from XML Template for external loads
    lowpassfcut=externForcesTree.ExternalLoads.lowpass_cutoff_frequency_for_load_kinematics;
end

% Create name for the external loads xml file
extLoadsXml = 'external_loads.xml';

% Save the settings in the Setup folder
setupFileDir=[results_directory '\Setup'];

if exist(setupFileDir,'dir') ~= 7
    mkdir (setupFileDir);
end

%Write and then set External Load setup file
xml_write([setupFileDir '\' extLoadsXml], externForcesTree, 'OpenSimDocument');
idTool.setExternalLoadsFileName([setupFileDir '\' extLoadsXml]);

%Print ID setup file
setupFile = 'setup_ID.xml';
idTool.print([setupFileDir '\' setupFile]);

%Run ID
matlabdir=pwd;
cd(setupFileDir)
dos(['id -S ',setupFile]);
cd(matlabdir);
%Alternatively (but you need to comment all the following logging part):
%idTool.run();

%Save the log file in a Log folder for each trial
logFolder=[results_directory '\Log'];
if exist(logFolder,'dir') ~= 7
    mkdir (logFolder);
end
movefile([setupFileDir '\out.log'],[logFolder '\out.log'])
movefile([setupFileDir '\err.log'],[logFolder '\err.log'])
