function [inputDir, model_file, acquisitionFullFile] = processingConfiguration()
% Function to get common processing input from the user

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


%% input dir
inputDir = uigetdir(' ', 'Select your folder with elaboration identified for dynamic trials, e.g. dynamicElaborations\01');

ind=strfind(inputDir, '\dynamicElaborations');

%% Select acquisition xml
[acquisitionFile, acquisitionPath] = uigetfile('.xml', 'Select your acquisition .xml for the session, e.g. InputData\SubjectCode\Session 1');
acquisitionFullFile = fullfile(acquisitionPath, acquisitionFile);

%% model file
scalingDir=[inputDir(1:ind) 'scaling\']; 
    
if exist(scalingDir,'dir') == 7
    
    modelFile=dir([scalingDir '\*.osim']);
    modelFilePath=scalingDir;
    
    if length(modelFile)<2 
        modelFileName=modelFile.name;
        model_file=[scalingDir modelFileName];
    else
        [modelFileName, modelFilePath] = uigetfile([scalingDir '\*.osim'], 'Select the .osim model for use with dynamic elaborations');
        model_file=[modelFilePath modelFileName];
    end
    
else
    [modelFileName, modelFilePath] = uigetfile([inputDir '\*.osim'], 'Select the .osim model for use with dynamic elaborations');
    model_file=[modelFilePath modelFileName];
end