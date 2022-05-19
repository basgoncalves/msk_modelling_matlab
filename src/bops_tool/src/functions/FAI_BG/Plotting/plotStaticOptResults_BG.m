%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% plot single trial JRA to check
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%INPUT
%   Dir = struct containing all directories for the subject
%   CEINMSSettings
%   SubjectInfo,osimFiles
%-------------------------------------------------------------------------
%OUTPUT
%  
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% plotStaticOptResults_BG

function plotStaticOptResults_BG(Dir,CEINMSSettings,SubjectInfo,trialName,dofList)

fp = filesep;

%% Plotting settings
PlotSet = struct;
PlotSet.figSize = [60 60 1700 900];
PlotSet.FontSize = 12;
PlotSet.FontName = 'Times New Roman';
PlotSet.Xlab = 'GaitCycle (%)';

%% save dir
savedir = [Dir.Results_StOpt  fp trialName];
if exist(savedir)
    n = num2str(sum(contains(cellstr(ls(Dir.Results_CEINMS)),trialName)))+1;
    savedir = [Dir.Results_StOpt fp trialName '_' n];
end
mkdir(savedir);

%% Dof and names of the variables to plot
osimFiles = getosimfilesFAI(Dir,trialName); 
ceinmsFiles = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);

copyfile(osimFiles.SOsetup,savedir)

S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,Dir.OSIM_LO,dofList);
TimeWindow = TimeWindow_FatFAIS(Dir,trialName);
muscles = S.AllMuscles;

MatchWord = 1; % 1= match names / 0 = don't match full name
[ID,~] = LoadResults_BG (osimFiles.IDresults,TimeWindow,[S.moments],MatchWord);
[IK,~] = LoadResults_BG (osimFiles.IKresults,TimeWindow,S.coordinates,MatchWord);
[MeasuredEMG,~] = LoadResults_BG (osimFiles.emg,TimeWindow,S.RecordedEMG,MatchWord);
[SOactivation,~] = LoadResults_BG (osimFiles.SOactivationResults,TimeWindow,muscles,MatchWord);
[SOforce,~] = LoadResults_BG (osimFiles.SOforceResults,TimeWindow,muscles,MatchWord);
[CEINMSforce,~] = LoadResults_BG (ceinmsFiles.MuscleForces,TimeWindow,muscles,MatchWord);
[CEINMSactivations,~] = LoadResults_BG (ceinmsFiles.Activations,TimeWindow,muscles,MatchWord);

[ha, pos,FirstCol,LastRow,LastCol]  = tight_subplotBG(length(muscles),0);
for i = 1:length(muscles)
    axes(ha(i)); hold on
    plot(SOforce(:,i))
    plot(CEINMSforce(:,i))
    title(muscles{i})
end
axes(ha(1));legend({'Static Opt', 'CEINMS'})
tight_subplot_ticks(ha,LastRow,0)
mmfn_inspect
saveas(gcf,[savedir fp 'muscleForces.jpeg']); close all

[ha, pos,FirstCol,LastRow,LastCol]  = tight_subplotBG(length(muscles),0);
for i = 1:length(muscles)
    axes(ha(i)); hold on
    plot(SOactivation(:,i))
    plot(CEINMSactivations(:,i))
    title(muscles{i})
end
axes(ha(1));legend({'Static Opt', 'CEINMS'})
tight_subplot_ticks(ha,LastRow,0)
mmfn_inspect
saveas(gcf,[savedir fp 'activations.jpeg']); close all
disp(['results saved in' savedir])

