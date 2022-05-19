
% trialName = cell vector with different names
% eg: trialName = {'HAB1','HAB2','HAD1','HAD2','HE1','HE2','HEAB1','HEAB2','HEABER1','HEABER2'}
function [trialType,trialNumber,groups] = getTrialType_multiple(trialNames)

for i = 1:length(trialNames)
    [trialType{i},trialNumber{i}] = getTrialType(trialNames{i});
end

[~,~,groups] = unique(trialType);

differentTypes = unique(groups);

for i = 1:length(differentTypes)
   idx = find(groups==differentTypes(i));
end