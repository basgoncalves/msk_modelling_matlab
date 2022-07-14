
% trialName = cell vector with different names
% eg: trialName = {'HAB1','HAB2','HAD1','HAD2','HE1','HE2','HEAB1','HEAB2','HEABER1','HEABER2'}
function [trialType,trialNumber,groups] = getTrialType_multiple(trialNames,sep)


for i = 1:length(trialNames)
    if nargin < 2
        [trialType{i},trialNumber{i}] = getTrialType(trialNames{i});
    else
        [trialType{i},trialNumber{i}] = getTrialType(trialNames{i},sep);
    end
end

[~,~,groups] = unique(trialType);
groups = groups';