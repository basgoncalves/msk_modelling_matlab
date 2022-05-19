function trials = getTrials(dirIK)
% §---TO BATCH PROCESS---§
% ========================
trlsdir   = dir([dirIK filesep]);
isub      = [trlsdir(:).isdir]; %# returns logical vector of subdirectories
trlsNames = {trlsdir(isub).name}';
trlsNames(ismember(trlsNames,{'.','..', 'Figures'})) = [];
trlsNames(~cellfun(@isempty,(regexp(trlsNames,'SlowWalk*')))) = []; 
trlsNames(~cellfun(@isempty,(regexp(trlsNames,'FastWalk*')))) = [];
trlsNames(~cellfun(@isempty,(regexp(trlsNames,'SquatCal*')))) = [];
trlsNames(~cellfun(@isempty,(regexp(trlsNames,'Squat*')))) = [];
trials = trlsNames;