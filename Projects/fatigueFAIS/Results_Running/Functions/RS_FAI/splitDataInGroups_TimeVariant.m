
function [M,SD,Ind,N,Participants] = splitDataInGroups_TimeVariant(GroupData,parameter,coordinate,trial,Groups,Mass)


Gnames = fields(Groups); % group names
Participants = Gnames;

% check the columns for each group
for k = 1: length(Gnames)
    G{k} = find(contains(GroupData.participants ,Groups.(Gnames{k})'));
     idxW = find(contains(Groups.(Gnames{k})',GroupData.participants));
     Participants(k,2) = {Groups.(Gnames{k})(idxW)};
    if nargin ==6
       
        Mass.(Gnames{k})= Mass.(Gnames{k})(idxW);
    end
     
end

% mean and std for each group
Ind={}; % individual data point
for k = 1: length(Gnames)
    
    SplitData = GroupData.(parameter).(coordinate).(trial)(:,G{k});
    if nargin ==6
        KG = cell2mat(Mass.(Gnames{k}))';
        SplitData = SplitData./KG; % normalise data to body mass
    end
    
   
    cols = ~all(isnan(SplitData)); % https://au.mathworks.com/matlabcentral/answers/68510-remove-rows-or-cols-whose-elements-are-all-nan
    SplitData= SplitData(:,cols);
    N(k) = size(SplitData,2);
    M(:,k) = nanmean(SplitData,2);
    SD(:,k) = nanstd(SplitData,0,2);
    SplitData(SplitData==0) =NaN;
    Ind{k} = SplitData;
    Participants{k,2} = Participants{k,2}(cols);
end


