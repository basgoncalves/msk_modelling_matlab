% find data Basilio Goncalves 2019
%
% INPUT
%   data = double
%   labels = cell 
%   trialNames = cell
%   MatchWholeWord = 1 for "yes" (default) or 2 for "no"; 

function [SelectedData,SelectedLabels,IDxData] = findData (data,labels,trialNames,MatchWholeWord)

SelectedData=[];SelectedLabels={};IDxData =[];

if isempty(trialNames);trialNames=labels;end

if contains(class(trialNames),'char');trialNames=cellstr(trialNames);
elseif ~contains(class(trialNames),'cell'); error('trialNames should be of cell or char type'); end

if size(data,2)==0;   error ('data and labels should have the same number of columns')
elseif size(data,2)~=size(labels,2);   error ('data and labels should have the same number of columns'); end

if ~exist('MatchWholeWord') || MatchWholeWord==1
    c = 1;
    for ff = 1:length (labels)
        for tt= 1:length(trialNames)
            if  strcmp(labels{ff},trialNames{tt})       % compare string 
                SelectedData(:,c) = data(:,ff);
                SelectedLabels(:,c) = labels(ff);
                IDxData (c) = ff;
                c= c+1;
            end
        end
    end
else
    colsToExtract = find(contains(labels,trialNames));  % compare string 
    for c = 1:length(colsToExtract)
        SelectedData(:,c) = data(:,colsToExtract(c));
        SelectedLabels(:,c) = labels(:,colsToExtract(c));
    end
end

if isempty(SelectedLabels)
    List = '';
    for ii = 1: length(labels)
       name = sprintf('%s',labels{ii});
       name = strtrim(name);
       List = [List ',' name];
    end
    List(1) =[];    % remove first comma
    error (['Labels should contain' List]) 
end
