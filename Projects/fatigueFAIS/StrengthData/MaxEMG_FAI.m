% Goncalves,BG (2019)
%
%INPUT
%   SubjFolder = directory of the subject
%   EMGdataAll = NxM cell matrix with max/mean EMG values for indiviudal
%   trials
%       N = individual trials trials (eg. Jump1 Jump2 Run1 Run2)
%       M =  individual EMG channels (eg. VM VL ... or 1 2 3)
%
%CALLBACK FUNCTIONS
%   getMaxTrials
%   MultiBarPlot
%

function [MaxEMGTrials,IdxMaxEMG] = MaxEMG_FAI(SubjFolder,EMGdataAll,Dir,SubjectInfo)
fp = filesep;
DirStrengthData = Dir.StrengthData;

%% check if participant had intramuscular EMG based on Participant information data
if strcmp(SubjectInfo.Intramuscular,'NO')
    EMGdataAll(14:17,2:end)={0};                  % rows of intrmauscular EMG
end

%% organise data
cd(SubjFolder)

EMGdataAll = EMGdataAll';                  % flip data to place muscle names in first row
[Nrow,Ncol] = size (EMGdataAll);
GroupData = cell2mat(EMGdataAll(2:Nrow,2:Ncol));
labels = EMGdataAll (2:end,1);
channels = EMGdataAll (1,2:end);

%% find the max for each condition (e.g. HE1,HE2,HE3...)
[MaxEMGTrials,IdxMaxEMG] = getMaxTrials (GroupData,labels);

%bar plot all the trials
MultiBarPlot (GroupData,channels,labels,'EMG (mv)');
movefile([cd fp 'BarPlots.mat'], [DirStrengthData fp 'Plot_Individuals_EMG-Isometrics.mat'])
close all

EMGdataAll = EMGdataAll';                  % flip data to place muscle names in first column

%% Order EMG

Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post','KE_post','KF_post','PF_post'};
DynamicTrials = {'SJ','SLSback','SLSfront','RestrictSquat','SquatNorm'};

OrderEMG        %script to organise EMG

%% -%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
%        Pre EMGs only & Max EMG Trials saved                 %
%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%

PreTrials = (size (MaxEMGTrials,1)-1)/2;                                    % number of pre trials = (all trials - first row)/2
MaxEMGPre = MaxEMGTrials (1,:);
MaxEMGPre (2:PreTrials+1,:) = MaxEMGTrials (2:2:end,:);

TrialMaxEMG = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF'};
MaxEMGTrials (1,2:end)=TrialMaxEMG;

% max for each channel
[Nrow,Ncol] = size (MaxEMGTrials);
MaxData_EMG = cell2mat(MaxEMGTrials(2:Nrow,2:Ncol));
% max for only the pre trials
[Nrow,Ncol] = size (MaxEMGPre);
MaxEMG_permuscle = cell2mat(MaxEMGPre(2:Nrow,2:Ncol));
[MaxEMG_permuscle, idx] = max(MaxEMG_permuscle,[],1);
labels = MaxEMGPre(2:end,1);

for i = 1:length(idx)
    TrialMaxEMG{2,i} = labels(idx(i));
end

% pre post diff
EMG_Diff={};
[Nrow, Ncol] = size(MaxEMGTrials);
for mm = 2:Ncol
    for ii = 2:2:Nrow-1
        idx = strcmpi(Isometrics_pre{1},MaxEMGTrials(:,1));
        EMG_Diff{ii,1} = MaxEMGTrials{ii,1};
        EMG_Diff{ii,mm} = (MaxEMGTrials{ii+1,2}-MaxEMGTrials{ii,2})/MaxEMGTrials{ii,2}*100;
    end
end
% delete every second row
for ii = flip(1:2:Nrow-1)
    EMG_Diff(ii,:)=[];
end
EMG_Diff(10:12,:)=[];


% FAI_Organizer.maxEMG_running = MaxEMGTrials;
%% save EMG trials
saveDir = Dir.StrengthData;
mkdir(saveDir)
cd(saveDir)
save maxEMG EMGdataAll MaxEMGTrials MaxEMGPre TrialMaxEMG TrialMaxEMG labels MaxEMG_permuscle IdxMaxEMG EMG_Diff
fprintf ('Max EMG data saved \nIndividual EMG plots and Max EMGs - done\n')