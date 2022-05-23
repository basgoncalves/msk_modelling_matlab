%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Main script for PhD paper 2 results 
% from old analysis
% GaitCycleDetect             % in progres...
% PlotPowerBursts             % plot single participant power burst figure
% JointWorkPlots              % plot joint poisitive and negative works
% CorrelationsJointWork       
%-------------------------------------------------------------------------

%% Results OS Work paper - August 2020
% PHD_Paper2_results
Dir=getdirFAI; % EDIT THIS FUNCTION FOR a DIFFERENT PROJECT
[Subjects,Groups]=splitGroupsFAI(Dir.Main,'JointWork_RS');
[~,SubjectFoldersElaborated] = smfai(Subjects);

cmgmsg(['Directories created for ' Subject '- NOTE: these may need editing'])

DirResults = [Dir.Results_JointWorkRS fp 'PaperData&Figs'];
cd(DirResults)
Trials = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
    'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};
 % Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
[motions,GroupData] = ResultsJointWork_RS (SubjectFoldersElaborated,Trials,1);

Plot_ResultsJointWork_RS(DirResults,Trials);
CorrStrength_Speed(SubjectFoldersElaborated);