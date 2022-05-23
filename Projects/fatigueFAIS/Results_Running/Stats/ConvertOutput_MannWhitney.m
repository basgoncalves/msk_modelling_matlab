%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% After exporting the data from Mann-Whitney analysis from SPSS to xlsx (multiple analyises
% possible) re arranged the data to a friendly word format
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%INPUT
%   chose by the user the xlsx file
%-------------------------------------------------------------------------
%OUTPUT
%   Table with the data for descriptive, estimated and pairwise comparisons
%   txt = text to place in the results section
%--------------------------------------------------------------------------

%% ConvertOutputSPSS
function [Z,P,ES] = ConvertOutput_MannWhitney

% column 1 = mean
% column 2 = standard deviation
SPSSoutput=[];
PairwiseComparisons = [];
OutputLabels={};
Table={};
[filename,filepath,~] = uigetfile('*.xls');
cd(filepath)
[NUM,TXT,RAW] = xlsread([filepath filename]);

%index of each output
Outputdx = find(strcmp(RAW(:,1),{'Output Created'}));
Outputdx(end+1) = length(RAW);  % add one at the end to use as the end of the last output

%index for descriptive
DesciptiveIdx = find(strcmp(RAW(:,1),'Descriptive Statistics'));
%index for stats
StatsIdx = find(strcmp(RAW(:,1),'Test Statisticsa'));

% get Z scores
Z = struct;
P = struct;
ES = struct;
for k = 1:length(StatsIdx)
    for kk = 2:size(RAW,2)
        z = RAW{StatsIdx(k)+4,kk}; % check Z score
        p = RAW{StatsIdx(k)+5,kk};  % check p value
        for k3 = DesciptiveIdx(k):size(RAW,1)   % check total N
            if contains(RAW{k3,1},RAW{StatsIdx(k)+1,kk})
                n = RAW{k3,2};
                break
            end
        end
       Z.(['Test' num2str(k)]).(RAW{StatsIdx(k)+1,kk})= z;
       P.(['Test' num2str(k)]).(RAW{StatsIdx(k)+1,kk})= p;
       ES.(['Test' num2str(k)]).(RAW{StatsIdx(k)+1,kk})= ES_Mann_Whitney (z,n);
   end
end


