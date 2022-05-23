GroupData = struct;
Labels= struct;
%% MVIC

% merging columns 
trialName = {'MVIC'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);            % compile two columns in one
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% RFDmax

% merging columns 
trialName = {'RFDmax'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% RFD50

% merging columns 
trialName = {'RFD50'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% RFD100
% merging columns 
trialName = {'RFD100'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% RFD150
% merging columns 
trialName = {'RFD150'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% RFD200
% merging columns 
trialName = {'RFD200'};
[SelectedData,SelectedLabels,IDxData] = findData (addData,description,trialName);

GroupData.(trialName{1}) = [];
Labels.(trialName{1}) = {};
for ii = 1:2:length(SelectedLabels)
StackedData = reshape(SelectedData(:,ii:ii+1),[],1);
GroupData.(trialName{1}) (:,end+1) = StackedData;
Labels.(trialName{1}) {end+1}=SelectedLabels{ii};
end

%% save

save addDataPerPosition GroupData Labels