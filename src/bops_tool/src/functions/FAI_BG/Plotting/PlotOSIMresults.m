%% PlotOSIMresults(Subjects,GroupsOfTrials,IndividualPlots)
%   import and plot openSim results for external biomechanics (inverse
%   kinematics and dynamics)
%INPUTS
%   Subjects = cell vector with codes of participants (eg {'001','002'...}
%   GroupsOfTrials =   cell vector containing some or all of {'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'}
%   IndividualPlots =   Logical 1 or 0 for yes or no

% Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves

function PlotOSIMresults(ResultsDir,IndividualPlots)

fp = filesep;warning off
if nargin<2
    IndividualPlots=1;
end
load(ResultsDir)
savedir = fileparts(ResultsDir);
dofs = fields(Results.IK);
AllImportedTrials = fields(Results.IK.(dofs{1}));
Subjects = Results.Subjects;

% plot data for indiviudal trials and particioants
if IndividualPlots==1
    for trialIdx = 1:length(AllImportedTrials)
        trialName = AllImportedTrials{trialIdx};
        plotIndividualTraces(Results,'IK',trialName,Subjects,savedir)
        plotIndividualTraces(Results,'ID',trialName,Subjects,savedir)
    end
end

function plotIndividualTraces(Results,Analysis,trialName,Subjects,savedir)

fp=filesep;
Nrows = length(Subjects);
Ncols = 0;

dofs = fields(Results.IK);
for d = 1:length(dofs)
    currentDof = dofs{d};
    [ha, ~] = tight_subplotBG(Nrows,Ncols,[],[],[],0.99);
    suptitle([trialName ' - ' Analysis ' - ' currentDof])
    mmfn_inspect
    meanValue = mean(Results.(Analysis).(currentDof).(trialName),2);
    
    for subjectIdx = 1:length(Subjects)
        axes(ha(subjectIdx))
        hold on
        plot(Results.(Analysis).(currentDof).(trialName)(:,subjectIdx));
        plot(meanValue)
        title(Subjects(subjectIdx),'Interpreter','none')
    end
    
    axes(ha(1))
    legend({'individual subject' 'mean all subjects'})
    
    saveas(gcf,[savedir fp trialName ' - ' Analysis ' - ' currentDof '.jpeg'])
    close(gcf)
end