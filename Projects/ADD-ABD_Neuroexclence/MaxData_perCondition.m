GroupData = struct;
Labels= struct;
Conditons = {'MVIC';'RFDmax';'RFD50';'RFD100';'RFD150';'RFD200'};
%% Loop Through all conditions
for cc = 1:length(Conditons)
    % merging columns
    trialName = Conditons(cc);
    [SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);
    
    GroupData.(trialName{1}) = [];
    Labels.(trialName{1}) = {};
    for ii = 1:2:length(SelectedLabels)
        MaxData = max(SelectedData(:,ii:ii+1),[],2);            % max of each row 
        GroupData.(trialName{1}) (:,end+1) = MaxData;
        Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
    end
    
end

save addDataMaxPerCondition GroupData Labels