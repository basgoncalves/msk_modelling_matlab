%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Main script for PhD paper 2 results 
%-------------------------------------------------------------------------

%% Results OS Work paper (old analysis) - April/May 2020

GaitCycleDetect             % in progres...
PlotPowerBursts             % plot single participant power burst figure
JointWorkPlots              % plot joint poisitive and negative works
CorrelationsJointWork       %

[DirElaborated,Joints,IndivData,Labels] = MeanAllResults_1to14 (SubjectFoldersElaborated, sessionName,{'hip_flexion','knee','ankle'});
BatchResultsOS_FAI_BG_NoPlots (SubjectFoldersElaborated, SessionFolder)    %crop kinematics and kinectics, calculate power and work

MeanJB (SubjectFoldersElaborated, sessionName, {'hip_flexion','knee','ankle'})
StepLength_BG

% [DirElaborated,Joints,TrialNames,MeanRun,Labels] = MeanAllResults (SubjectFoldersElaborated,{'hip_flexion','knee','ankle'},{'','RunD1','RunL1'});
[DirElaborated,Joints,IndivData,Labels] = MeanAllResults_1to14 (SubjectFoldersElaborated,S{'hip_flexion','knee','ankle'});
cd(DirResults)
save MeanRunningBiomechanics MeanRun fs

% plots for single participants Kinemetics, Kinetics and Powers
RunningBiomechPlots_BG

% plot ensamble means and SD of angle, angle velocity, joint moments and joint powers
PlotMeanBiomech
