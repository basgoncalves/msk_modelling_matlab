function []=plotResultsMultipleTrials_apm(resultsPath, elabDataFolder, trialsList, filename,x, Yquantities, varargin)
% Function to plot results from multiple trials. Also determines joint
% angular velocity and joint powers.

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

% Edited by Gavin Lenton October 2018 for CHESM apm project

%%

close all

subject_weight = varargin{1};
subject_name = regexprep(varargin{2}, ' ', '');
session_name = regexprep(varargin{3}, ' ', ''); % Session name without spaces
sessionName = varargin{3}; % Session name with spaces

% If session name is not appropriate for structure name, we build session name from the
% loop
sessionNumber = varargin{4};
sessionNameForStruct = ['Session', num2str(sessionNumber)];

% Define path names to save data - load if it alrady exists.
if strcmp(filename,'inverse_dynamics.sto')
     % Paths for ID results
     figurePath=[elabDataFolder filesep sessionName filesep 'Figures' filesep 'Torques' filesep];
     metricsPath = [elabDataFolder filesep sessionName filesep 'AnalysedData' filesep 'Torques' filesep];
     if exist(metricsPath,'dir') ~= 7
          mkdir(metricsPath);
     end
     % Load ID file if it exists
     if exist([elabDataFolder(1:end-8), 'momentsData.mat'], 'var')
          completeMetricsName = [elabDataFolder, filesep, 'momentsData.mat'];
          load(completeMetricsName);
     else
          completeMetricsName = [elabDataFolder, filesep, 'momentsData.mat'];
          allData = struct();
     end
     AnalysisName = [subject_name, '_ID_raw_data'];
else
     % IK data
     figurePath=[elabDataFolder filesep sessionName filesep 'Figures' filesep 'Angles' filesep];
     metricsPath=[elabDataFolder filesep sessionName filesep 'AnalysedData' filesep 'Angles' filesep];
     % Load IK file if it exists
     if exist(metricsPath,'dir') ~= 7
          mkdir(metricsPath);
     end
     cd(metricsPath);
     
     % Load structure with all data
     if exist([elabDataFolder, filesep, 'kinematicData.mat'], 'file')
          completeMetricsName = [elabDataFolder, filesep, 'kinematicData.mat'];
          load(completeMetricsName);
     else
          allData = struct();
          completeMetricsName = [elabDataFolder, filesep, 'kinematicData.mat'];
     end
     AnalysisName = [subject_name, '_IK_raw_data'];
end

% Make directory to save figures
if exist(figurePath,'dir') ~= 7
     mkdir(figurePath);
end

dirRemoved = 0;

%Load data
for k=1:length(trialsList)
     
     folder_trial = [resultsPath trialsList{k} filesep];
     
     if exist([folder_trial, filename], 'file')
          
          % Import data
          file=importdata([folder_trial, filename]);
          
          if nargin>4
               
               coord_idx=findIndexes(file.colheaders,Yquantities);
          else
               Yquantities=file.colheaders(2:end); %take all columns except time
               coord_idx=[2:size(file.colheaders,2)];
          end
          
          %% CHECK THE FILENAMES FOR BOTH IK AND ID
          
          results = file.data;
          
%           timeVector{k}=getXaxis(x, results);
          timeVecTrial = results(:,1);
          timeVec = linspace(timeVecTrial(1), timeVecTrial(end), 101);
          
          % Normalising moments to body weight
          if strcmp(filename,'inverse_dynamics.sto')
               results(:, 2:end) = results(:, 2:end)./subject_weight;
          end
          
          for j =1: length(coord_idx)
               
               coordCol=coord_idx(j);
               
               % Saves different trials in rows and different dofs in cols
               y{k,j} = results(:,coordCol);
               allData.(subject_name).(sessionNameForStruct).(Yquantities{j})(:, k) = ...
                    pchip(timeVecTrial, results(:,coordCol), timeVec);
          end
          

     else
%           rmdir([resultsPath, filesep, trialsList{k}], 's');
          dirRemoved = dirRemoved + 1;
     end
end

% Remove the deleted trials from the cell matrix
[sizeR, sizeC] = size(y);
sizeR_deletedRows = sizeR - dirRemoved;

% Remove any nonzero
yNew = y(~cellfun('isempty',y));
yLength = length(yNew);
difference = yLength/length(Yquantities) - sizeR_deletedRows;

if difference ~= 0
     sizeR_deletedRows = sizeR_deletedRows + difference;
end

y = reshape(yNew, [sizeR_deletedRows, sizeC]);

%Save data in mat format
save([metricsPath, AnalysisName], 'y');
save(completeMetricsName, 'allData');

% save([figurePath, 'plottedData'], 'y')

% Settings for plot
% plotLabels=regexprep(Yquantities, '_', ' ');
% legendLabels=regexprep(trialsList, '_', ' ');
% cmap = colormap(parula(180));
% plotTitle = filename;

% for k=1:size(y,1)
% 
% 	plotColor = cmap(round(1+5.5*(k-1)),:);
% 
% 	for j=1:size(y,2)
% 
% 		h(j)=figure(j);
% 
% 		plot(timeVector{k}, y{k,j},'Color',plotColor)
% 		hold on
% 
% 		xlabel(x)
% 		ylabel([plotLabels(j)])
% 		warning off
% 		legend(legendLabels)
% 		title(filename)
% 
% 		saveas(h(j),[figurePath  Yquantities{j} '.fig'])
% 	end
% end