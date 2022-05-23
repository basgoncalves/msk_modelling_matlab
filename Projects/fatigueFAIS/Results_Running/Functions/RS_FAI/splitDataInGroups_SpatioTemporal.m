
function [M,SD,Ind,Participants] = splitDataInGroups_SpatioTemporal(GroupData,parameter,trial,Groups,Mass)


Gnames = fields(Groups); % group names
Participants = Gnames;
% check the columns for each group
for k = 1: length(Gnames)
    G{k} = find(contains(GroupData.participants ,Groups.(Gnames{k})'));
     idxW = find(contains(Groups.(Gnames{k})',GroupData.participants));
      Participants(k,2) = {Groups.(Gnames{k})(idxW)};
    if nargin ==5
       
        Mass.(Gnames{k})= Mass.(Gnames{k})(idxW);
       
    end
end

% mean and std for each group
Ind=[]; % individual data point
for k = 1: length(Gnames)
    
    SplitData = GroupData.(parameter).(trial)(:,G{k});
    if nargin ==5
        KG = cell2mat(Mass.(Gnames{k}))';
        SplitData = SplitData./KG; % normalise data to body mass
    end
    
    Ind(1:length(SplitData),k) = SplitData';
    n = size(SplitData,2);
    M(:,k) = nanmean(SplitData,2);
    SD(:,k) = nanstd(SplitData,0,2);
    
end

Ind(Ind==0) =NaN;
