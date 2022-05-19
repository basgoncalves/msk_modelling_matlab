function [IKoutputDir,IKtrialsOutputDir, varargout] = runInverseKinematics(inputDir,inputTrials, model_file, IKTemplateXml, IKid)
% Function to run IK for multiple trials

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
[IKoutputDir, IKtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, IKid, 'IK');

trcFullFileName = inputFilesListGeneration(inputDir, inputTrials, '.trc');
%to have also the relative path:
%[trcFullFileName, trcRelativePath] = inputFilesListGeneration(inputDir, inputTrials, '.trc');

%% Loop through trials and run IK
nTrials= length(inputTrials);

for k=1:nTrials
     
     % Get the model
     osimModel = Model(model_file.model_full_path{1});
     osimModel.initSystem();
        
    results_directory=IKtrialsOutputDir{k};
    
    marker_file=trcFullFileName{k};
    
    if exist(results_directory,'dir') ~= 7
        mkdir (results_directory);
    end
    
    fprintf('Performing IK on trial %s \n', inputTrials{k});
    
    runIK(osimModel, marker_file, IKTemplateXml, results_directory)
    
    clearvars -except trcFullFileName IKTemplateXml osimModel IKoutputDir IKtrialsOutputDir inputDir inputTrials staticTrialName model_file model_file2
    java.lang.System.gc()
end

%Save the log file
copyfile('out.log',[IKoutputDir 'out.log']);