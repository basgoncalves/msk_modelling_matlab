function [FullFileName, RelativeFilePath] = inputFilesListGeneration(inputDir, trialsList, tag)
% Function to generate the list of .trc files

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

nTrials=length(trialsList);

for k=1:nTrials
     
     inputTrialsFullFilePaths{k}=[inputDir filesep trialsList{k}];
     
     switch tag
          case '.trc'
               
               FileName{k}=dir([inputTrialsFullFilePaths{k} filesep '*.trc']);
               nFile=1;
               
          case '.mot' %include results from IK (ik.mot) and .mot storing GRF
               
               FileName{k}=dir([inputTrialsFullFilePaths{k} filesep '*.mot']);
               
               %MOtoNMS store also emg.mot in the same folder of GRFmot
               nmotFiles=length(FileName{k});
               
			   % If more than one .mot file we want to process both
               if nmotFiles>1
                    
                    for i=1:nmotFiles
                         
                         % If the assist has already been added we don't
                         % want to pick this .mot file
                        
                         if strcmp(FileName{k}(i).name,'emg.mot')==0
%                               if strcmp(FileName{k}(i).name(end-9:end),'Assist.mot')==1
                              if strcmp(FileName{k}(i).name,'Assist.mot')==1
                                   continue
                              else
                                   nFile=i;
                              end
                              
                         end
                    end
               else
                    nFile=1;
               end
               
          case '.xml'
               
               nFile=1;
               %FileName{k}=dir([inputTrialsFullFilePaths{k} '\Setup\external_loads.xml']);
               FileName{k}(nFile).name=[ 'Setup' filesep 'external_loads.xml'];
               
               % Added check for .sto file to extract position data from PK
               % results
          case '.sto'
               
               FileName{k}=dir([inputTrialsFullFilePaths{k} filesep '*pos.sto']);
               
               %MOtoNMS store also emg.mot in the same folder of GRFmot
               nmotFiles=length(FileName{k});
               
               if nmotFiles>1
                    
                    for i=1:nmotFiles
                         
                         if strcmp(FileName{k}(i).name,'emg.mot')==0
                              nFile=i;
                         end
                    end
               else
                    nFile=1;
               end
               
          otherwise
               error ([tag ' case missing. Check function inputFilesListGeneration.m'])
               
     end
     
     FullFileName{k}=[inputTrialsFullFilePaths{k} filesep FileName{k}(nFile).name];
     
     RelativeFilePath{k}=['.' filesep trialsList{k} filesep  FileName{k}(nFile).name];
     
end
