
function [MaxNumber,Labels] = CheckMaxNumber

subjectDir = uigetdir('','Select subject folder');
cd (subjectDir);
subjects = dir;
subjects (1:2) = [];
MaxNumber = [];
Labels = {};
for CurrentSubject = 1: length (subjects)
    
    if subjects(CurrentSubject).isdir ==0
        continue
    end
    CurrentPath = sprintf('%s\\%s',subjects(CurrentSubject).folder, subjects(CurrentSubject).name);
    cd (CurrentPath);
    if exist ('outputData.mat','file')==2
        
        load('outputData.mat')
    else
        continue
    end
    
    %% Max, Mean and mean baseline for each position
    
    FilesCell = struct2cell (indivData)';
    
    nameBiodex = sprintf ('%s', indivData(1).trial);                            % name of the first Biodex trial
    lastTrial = 1;                                                              % mark the last selected trial (start with one)
    ii =1;
    Maxtrials = struct;
    
    for ii = 1 :length (FilesCell)                                              % loop through all the Biodex trials
        
        if ii==length (FilesCell)  &&  strcmp (FilesCell{ii,7}, nameBiodex)==0  % if it's the last trial AND DIFFERENT name as before
            
            [Maxtrials(ii-1).MaxTrial,Maxtrials(ii-1).idx] = ...
                max([FilesCell{lastTrial:ii-1,8}]);                             % Get MAX of the trials with same name
            lastTrial = ii;
            
            [Maxtrials(ii).MaxTrial,Maxtrials(ii).idx] = ...
                max([FilesCell{lastTrial:ii,8}]);                                % Get MAX of the LAST trial
            
        elseif ii==length (FilesCell)  &&  strcmp (FilesCell{ii,7}, nameBiodex)==1     % if it's the last trial AND SAME name as before
            [Maxtrials(ii-1).MaxTrial,Maxtrials(ii-1).idx] = ...
                max([FilesCell{lastTrial:ii,8}]);                               % Get the Mean and MAX of the trials with same name
            
            
        elseif strcmp (FilesCell{ii,7}, nameBiodex)==0                          % if the current and previous trials DO NOT have same name
            
            if length(lastTrial:ii-1) == 1                                      % if theres is only one trial
                continue
            else
                [Maxtrials(ii-1).MaxTrial,Maxtrials(ii-1).idx] =...
                    max([FilesCell{lastTrial:ii-1,8}]);                             % select the trials with same name (between the last selected and the one before the name has gone different)
                lastTrial = ii;
                
            end
        end
        
        
        nameBiodex = sprintf ('%s', indivData(ii).trial);
        
    end
    
    idx = [Maxtrials.idx]';              %convert field to double
    
    Labels{CurrentSubject} = subjects(CurrentSubject).name;
    MaxNumber (1:length(idx),CurrentSubject) = idx;
    
end

MaxNumber(MaxNumber>5) = NaN;
MaxNumber(MaxNumber<1) = NaN;