%BG 2020

% sort data in a struct based on the labels and the subject code

% Labels = cell vector with the names of each data column
function G = SortData(G,fld,Data,trialName,motionsG,col)

for k = 1:size(Data,2)
    if ~isfield(G.(fld).(motionsG{k}),[trialName])
        G.(fld).(motionsG{k}).([trialName])=[];
    end
    G.(fld).(motionsG{k}).([trialName])(:,col)=Data(:,k);
    
end
end