%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% External biomechanics before and after RS in FAIS,FAIM and CON
%-------------------------------------------------------------------------
% see also:
%   splitGroupsFAI.m
%   plotExternalBiomech.m

% updated April 2021
%% Results PHD_RS_FAIS_results
function PHD_RS_FAIS_results
fp = filesep;
[Dir,~,~,~] = getdirFAI;[Subjects,Groups,Weights,~] = splitGroupsFAI(Dir.Main,'RS_FAI');
[~,SubjectFoldersElaborated] = smfai(Subjects);
cd(Dir.Results_RSFAI)

%% import / load data
% get group data for IK and ID
TrialList = {'Run_baselineA1','Run_baselineB1','RunA1','RunD1','RunE1','RunF1','RunG1',...
    'RunH1','RunI1','RunJ1','RunK1','RunL1','RunM1','RunN1','RunO1','RunP1'};

% load([Dir.Results_RSFAI fp 'ExternalBiomechanics.mat'], 'G','W','ST') 
% G.participants{12} = 'Re-do';save([Dir.Results_RSFAI fp 'ExternalBiomechanics.mat'], 'G','W','ST')

[~,sessionName] = filesep(Dir.Input); suffix = '_FAI';
[GroupData,Work,ST] = importExternalBiomech(SubjectFoldersElaborated(1:end),sessionName,suffix,TrialList);

% find max velocity from baseline
[GroupData,Work,ST,BestRun] = findMaxBaselineTrial (GroupData,Work,ST);
% find data for "last round"
[GroupData,Work,ST,LastRun] = findLastTrial (GroupData,Work,ST,SubjectFoldersElaborated, sessionName,suffix);

% Foot contact percentage (mean)
FC_pre = (nanmean(ST.StepTime.Run_baseline)- nanmean(ST.ContactTime.Run_baseline))/nanmean(ST.StepTime.Run_baseline)*100;
FC_post = (nanmean(ST.StepTime.Run_final)- nanmean(ST.ContactTime.Run_final))/nanmean(ST.StepTime.Run_final)*100;

cd(Dir.Results_RSFAI)
save IKandID GroupData Work ST Groups Weights BestRun LastRun FC_pre FC_post

%% relaibility hip extension Evy
load([Dir.Main fp 'Reliability_Reliability_190507.mat'])
sprintf('ICC(95%%)=%.2f (%.2f - %.2f)',Reliability.ICC.r(3),Reliability.ICC.UB(3),Reliability.ICC.LB(3))
sprintf('MDC(%%)=%.2f (%.2f)',Reliability.MDC.MDC(3),Reliability.MDC.MDC_perc(3))
