%% Description - Goncalves, BM (2019)
%
% INPUT 
%   GorupData: 
% -----------------------------------------
% OUTPUT 
%   
%   MaxTrials: NxM cell matrix with N = number of groups of trials & M =
%   number of analog channels 
%
%   []  []  []  []  []
%   'DF'0.5 0.4 0.6 0.6
%   'HE'0.1 0.9  1  0.5
%% START FUNCTION
function [MaxTrials,IdxMax] = getMaxTrials (GroupData,labels)

[Nrow,Ncol] = size (GroupData);
Groups = 1;
for Trial = 2 : length (labels)
    
    % the full name of 1st trial witout the numbers, eg.: HE1 => HE
    TrialName = labels{Trial-1};
    Numbers = regexp(TrialName,'\d*','Match');
    Compare_1 = erase(TrialName,Numbers);
    
    % the full name of 2nd trial witout the numbers, eg.: HE1 => HE 
    TrialName = labels{Trial};
    Numbers = regexp(TrialName,'\d*','Match');
    Compare_2 = erase(TrialName,Numbers);                             
    
    N = max([length(Compare_1),length(Compare_2)]);
                          
   if strncmp(Compare_1,Compare_2,N)==0      % comapre the current Trial name with the previous one
   Groups (end+1) = Trial; 
   end
end
Groups(end+1) = length(labels);                             % last group of trials 

MaxTrials = {};
IdxMax = {};
for ii = 2:length(Groups)
    TrialName = labels{Groups(ii)-1}(1:end-1);                                % name of the trial without the last character (e.g DF1 = DF)
    Numbers = regexp(TrialName,'\d*','Match');
    TrialName = erase(TrialName,Numbers);
    
    Trials = (Groups(ii-1):Groups(ii)-1);                                     % index of each trial with the same name 
    data = GroupData(Trials,1:Ncol);
    [MaxData, idx] = max(data,[],1);                                           % max for each column. For rows -> max(data,[],2)
    
    MaxTrials{ii,1} = TrialName;
    MaxTrials(ii,2:Ncol+1)= num2cell(MaxData);
    
    IdxMax{ii,1} = TrialName;
    IdxMax (ii,2:Ncol+1) = num2cell(idx);
end