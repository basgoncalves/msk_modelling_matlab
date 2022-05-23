%% stoToMatOsim(Subjects,GroupsOfTrials,IndividualPlots)
%   import and plot openSim results for external biomechanics (inverse
%   kinematics and dynamics)
%INPUTS
%   Subjects = cell vector with codes of participants (eg {'001','002'...}
%   GroupsOfTrials =   cell vector containing some or all of {'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'}
%   IndividualPlots =   Logical 1 or 0 for yes or no

% Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves

function ResultsDir = stoToMatOsim(Subjects,GroupsOfTrials,savedir)

fp = filesep;
warning off
MatchWholeWord = 1;
Normalise = 1;
Results = struct;
Results.Subjects = {};

if nargin<2 || isempty (GroupsOfTrials)
    GroupsOfTrials = {'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'};
elseif ~any(contains(GroupsOfTrials,{'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'}))
    GroupsOfTrials = {'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'};
    cmdmsg(['Trial name used does not exist in "Trials" struct. Trial names should contain one of: ' strjoin(GroupsOfTrials)])
    return
end

for subjectIdx = 1:length(Subjects)
    
    % load directories and subject data
    [Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{subjectIdx});
    Results.Subjects{end+1} = SubjectInfo.ID;
    
    if isempty(Trials.Dynamic) || isempty(fields(SubjectInfo))
        continue
    end
    
    % update log file (not needed, can be commeneted)
    updateLogAnalysis(Dir,['Inspect External biomechanics'],SubjectInfo,'start')
    disp(['import ' SubjectInfo.ID])
    
    % import varibales for this subject
    s = lower(SubjectInfo.TestedLeg);
    dofList = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
    Var = getOSIMVariablesFAI(SubjectInfo.TestedLeg,Dir.OSIM_LinearScaled,dofList);
    Strials = getstrials(Trials.ID,SubjectInfo.TestedLeg);
    % import data for each trial
    for  groupIdx = 1:length(GroupsOfTrials)
        for trialIdx = 1:length(Strials)
            trialName_recorded = Trials.ID{trialIdx};
            trialName_global = Strials{trialIdx};
            CurrentTrialGroup = GroupsOfTrials{groupIdx};
            CurrentTrialsIdx = contains(trialName_recorded,Trials.(CurrentTrialGroup));
            
            if CurrentTrialsIdx == 0
                continue
            end
            
            [osimFiles] = getosimfilesFAI(Dir,trialName_recorded);
            [IKdata,~] = LoadResults_BG (osimFiles.IKresults,[],Var.coordinates,MatchWholeWord,Normalise);
            [IDdata,~] = LoadResults_BG (osimFiles.IDresults,[],Var.moments,MatchWholeWord,Normalise);
            
            for dof = 1:length(Var.dofsimple)
                dofsimple = Var.dofsimple{dof};
                Results.IK.(dofsimple).(trialName_global)(:,subjectIdx) = IKdata(:,dof);
                Results.ID.(dofsimple).(trialName_global)(:,subjectIdx) = IDdata(:,dof);
            end
        end
    end
end
cd(savedir)
save Results Results
ResultsDir = [savedir fp 'Results.mat'];