% [OrderedResults,OrderedLabels] = LoadResults_BG (DataDir,TimeWindow,FieldsOfInterest,MatchWholeWord,Normalise,ConvertToStruct)
%
% Load results from "OpenSimPipeline_FatFAI" and time normalise data
%-------------------------------------------------------------------------
%INPUT
%   DataDir = [char] directory of the results for one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\IK\Trial\IK.mot'
%   TimeWindow = time window (in seconds) to crop the data
%   FieldsOfInterest = [N,1]cell vector with the names of the fields to be
%   extracted from Data
%   MatchWholeWord = 1 for "yes" (default) or other for "no";
%   Nomralise (optional) =  1 for "yes" (default) or other for "no";
%   ConvertToStruct (optional) = 1 for "yes" or 0 for "no" (default) 
%-------------------------------------------------------------------------
%OUTPUT
%   results = time normalised data within target time window
%   Labels = labesl of the extracted Data
%--------------------------------------------------------------------------
% see also: importdata  findData  TimeNorm
%
% written by Basilio Goncalves (2020), https://www.researchgate.net/profile/Basilio_Goncalves
%% LoadResults_BG
function [OrderedResults,OrderedLabels] = LoadResults_BG (DataDir,TimeWindow,FieldsOfInterest,MatchWholeWord,Normalise,ConvertToStruct)

warning off

try Data = importdata(DataDir);
catch 
    OrderedResults  = [];
    OrderedLabels   = {};
    disp(['data could not be loaded for:' DataDir])
    return
end
    
if isempty(Data)||~isstruct(Data)
    OrderedResults=[];
    OrderedLabels=[];
    return
end        % if file is empty or is not struct print empty outputs

Data.data = round(Data.data,4); 
[~,uniqueRows]=unique(Data.data(:,1));
Data.data = Data.data(uniqueRows,:);
fs =1/(Data.data(2,1)-Data.data(1,1));  

if nargin<2||isempty(TimeWindow)                                                        % if time window is empty get data from beginning till the end
    t = 1; t(2) = size(Data.data,1);
else
    TimeWindow=round(TimeWindow,4);
    [~, closestIndex] = min(abs(Data.data(:,1)-TimeWindow(1))); t =closestIndex;        % initial time
    [~, closestIndex] = min(abs(Data.data(:,1)-TimeWindow(2))); t(2) = closestIndex;    % final time
end

if nargin<3; FieldsOfInterest={};end
if nargin<4; MatchWholeWord = 1;end                                                     % 1 for "yes" (default) or other for "no";
if nargin<5; Normalise=1;end
if nargin<6; ConvertToStruct=0;end

[results,Labels]=findData(Data.data(t(1):t(2),:),Data.colheaders,FieldsOfInterest,MatchWholeWord);      %LoadData

if Normalise==1; results = TimeNorm(results,fs);end                             % time normalise if required
                                
% re order columns
OrderedResults=[];OrderedLabels={};c = 1;
if ~isempty(FieldsOfInterest)
    for i = 1:length(FieldsOfInterest)
        col = find(contains(Labels,FieldsOfInterest{i}));
        if isempty(col)
            OrderedResults(:,c) =NaN;
            OrderedLabels{c} =NaN;
            c=c+1;
            continue
        else
            for ii = 1:length(col)
                OrderedResults(:,c) = results(:,col(ii));
                OrderedLabels{c} = Labels{col(ii)};
                c =c+1;
            end
        end
    end
else
    OrderedResults = results;OrderedLabels =Labels;
end

if ConvertToStruct==1
    S = struct;
    for i =1:length(OrderedLabels)
        S.(OrderedLabels{i}) = OrderedResults(:,i);
    end
    OrderedResults = S;
end


