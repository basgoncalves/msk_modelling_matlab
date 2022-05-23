function [MAoutputDir, MAtrialsOutputDir]=runMuscleAnalysis(inputDir,inputTrials, model_file, IKmotDir, MAid, MATemplateXml, fcut_coordinates, varargin)
% Function to run Muscle Analysis for multiple trials

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

%Definition of output folders
[MAoutputDir, MAtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, MAid, 'MA');

%Definition of input files lists
[IKmotFullFileName] = inputFilesListGeneration(IKmotDir, inputTrials, '.mot');


%%
nTrials= length(inputTrials);

for k=1:nTrials
             
    results_directory=MAtrialsOutputDir{k};
           
    if exist(results_directory,'dir') ~= 7
        mkdir (results_directory);
    end
    
    coordinates_file=IKmotFullFileName{k};

    switch nargin 
           
        case 6  %until there will be probl setting the Muscle Analysis object with API
            runMA(model_file, coordinates_file, results_directory, MATemplateXml)
            
        case 5  %it will be the optimal case when API problems will be solved
            runMA(model_file, coordinates_file, results_directory)            
                     
        case 7
            runMA(model_file, coordinates_file, results_directory, MATemplateXml, fcut_coordinates)
    end
    
end