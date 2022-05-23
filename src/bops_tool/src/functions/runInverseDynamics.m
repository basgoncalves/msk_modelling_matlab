function [IDoutputDir, IDtrialsOutputDir]=runInverseDynamics(inputDir, IKmotDir, inputTrials, model_file, IDextLoadTemplate, IDid, fcut_coordinates)
% Function to run ID for multiple trials

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

%Definition of output folders
[IDoutputDir, IDtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, IDid, 'ID');

%Definition of input files lists
[IKmotFullFileName] = inputFilesListGeneration(IKmotDir, inputTrials, '.mot');

[GRFmotFullFileName] = inputFilesListGeneration(inputDir, inputTrials, '.mot');

% [PKstoFullFileName] = inputFilesListGeneration([regexprep(IKmotDir(1:end-3), 'inverseKinematics', 'kinematicsAnalysis'),...
%      filesep, 'origin_tibia'], inputTrials, '.sto');
%for both case you can have also the relative path:
%[GRFmotFullFileName, GRFmotRelativePath] = inputFilesListGeneration(inputDir, inputTrials, '.mot');

%% Loop through all trials and run ID
nTrials= length(inputTrials);

for k=1:nTrials
     
     trialName = inputTrials{k};
     
     results_directory=IDtrialsOutputDir{k};
     
     if exist(results_directory,'dir') ~= 7
          mkdir (results_directory);
     end
     
     %% Get the model from model list
     osimModel = Model(model_file.model_full_path{1});
     osimModel.initSystem();
     
     coordinates_file=IKmotFullFileName{k};
     GRFmot_file=GRFmotFullFileName{k};
     %      pk_file = PKstoFullFileName{k};
     
     fprintf(['Performing ID on trial %s \n'], inputTrials{k});
     
     % Run ID
     runID(osimModel, coordinates_file, GRFmot_file, IDextLoadTemplate, results_directory, fcut_coordinates)
     
end
