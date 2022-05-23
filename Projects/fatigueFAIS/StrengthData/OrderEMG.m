% Order EMG

NewMaxEMG=MaxEMGTrials;
NewIdxEMG = IdxMaxEMG;
count=2;
for ii = 1:length (Isometrics_pre)
    
    idx_pre = find(strcmpi(Isometrics_pre{ii},MaxEMGTrials(:,1)));          % check pre names and compare with Isometrics_pre (contains names of all trials) 
    if isempty(idx_pre)~=1                                                  % if any trials exists 
        NewMaxEMG(count,:) = MaxEMGTrials(idx_pre,:);                           % assign data pre trial 
        NewIdxEMG(count,:) = IdxMaxEMG(idx_pre,:);                              % reorder IdxEMG 
        count=count+1;
    else                                                                    % if NOT
        NewMaxEMG{count,1} = Isometrics_pre{ii};                                % Name pre trial
        NewMaxEMG(count,2:end)={0};                                             % data pre trial = 0
        NewIdxEMG{count,1} = Isometrics_pre{ii}; 
        NewIdxEMG(count,:) = {0};                                               % order IdxEMG = 0
        count=count+1;
    end
    
    idx_post = find(strcmpi(Isometrics_post{ii},MaxEMGTrials(:,1)));        % check pre names and compare with Isometrics_post (contains names of all trials)
    
    if isempty(idx_post)~=1                                                 % if any trials exists 
        NewMaxEMG(count,:) = MaxEMGTrials(idx_post,:);                          % assign data pre trial 
        NewIdxEMG(count,:) = IdxMaxEMG(idx_post,:);                             % reorder IdxEMG
        count=count+1;
    else
        PostEMG = 0;
        NewMaxEMG{count,1} = Isometrics_post{ii};                               % Name pre trial
        NewMaxEMG(count,2:end)={0};                                             % data pre trial = 0
        NewIdxEMG{count,1} = Isometrics_pre{ii}; 
        NewIdxEMG(count,:) = {0};                                               % order IdxEMG = 0
        count=count+1;
    end
    
end
MaxEMGTrials=NewMaxEMG;
IdxMaxEMG=NewIdxEMG;

clear NewMaxEMG NewIdxEMG
disp ('Order max EMG - done')