function []=plotSTOgroups(filesPath,filesname,stoFilesType, musclesGroups,xaxislabel)

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

close all

nTrials=size(filesPath,2);
nSTOfiles=size(filesname,2);
stoFilesTypeTitle=regexprep(stoFilesType, '_', ' ');

lineStyle={'-', '--', ':', '-.', '+', 'o', '*', '.', 'x', 's', 'd', 'v', '^', '>','<','p','h'};
color={'b', 'r','g', 'c', 'm','y','k'};


for k=1:nTrials
    
    
    for i=1:nSTOfiles
        
        figurePath=[filesPath{k} filesep 'Figures' filesep stoFilesType{i} filesep];
        
        if exist(figurePath,'dir') ~= 7
            mkdir(figurePath);
        end
        
        file=importdata([filesPath{k} filesep filesname{i}]);
        
        results=file.data;
        
        timeVector=getXaxis(xaxislabel, results);
        
        nMuscleGroups=size(musclesGroups,2);
        
        for m=1:nMuscleGroups
            
            Yquantities=musclesGroups{m}.muscle;
            YquantitiesLabel=regexprep(Yquantities, '_', ' ');
            
            nMuscles=size(Yquantities,2);
            
            if isfield(file,'colheaders')
                coord_idx=findIndexes(file.colheaders,Yquantities);
            else
                strheaders=file.textdata{end};
                colheaders=str_sep(strheaders);
                coord_idx=findIndexes(colheaders,Yquantities);
            end
            
            h=figure(m);
            hold on
            icolor=1;
            iline=1;
            save_to_base(1)
            for j =1:nMuscles
                
                coordCol=coord_idx(j);
                
                y = results(:,coordCol);
                
                plot(timeVector, y, strcat(lineStyle{iline},color{icolor}));
                title(stoFilesTypeTitle{i})
   
                if icolor==size(color,2)
                    icolor=1;
                    iline=iline+1;
                else
                    icolor=icolor+1;
                end
                
                xlabel(xaxislabel)
                %ylabel(plotLabels(j))
                warning off
                legend(YquantitiesLabel)
                
                
            end
            
            saveas(h,[figurePath musclesGroups{m}.name '.fig'])  
   %       saveas(h,[figurePath musclesGroups{m}.name '.png'])    
            close(h)
        end
    end
end