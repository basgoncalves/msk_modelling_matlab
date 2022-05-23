%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   FindGaitCycle_Running
%   LoadResults_BG
%   findData
%   getMP
%   mmfn
%   TimeNorm
%   fullscreenFig
%
%INPUT
%   CEINMSdir = [char] directory of the your ceinms dta for one subject
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms'
%-------------------------------------------------------------------------
%OUTPUT
%   G = Group data with angles, moments and
%   E = errors struct 
%   BG = best gamma and errors per trial
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% importExternalBiomech

function [G] = importJCFImpulse(SubjectFoldersElaborated, sessionName,suffix, TrialList)


fp = filesep;
warning off
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{1},sessionName,suffix);
savedir = [Dir.Results_JCFFAI fp 'CEINMSResults.mat'];

CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
dofList = split(CEINMSSettings.dofList ,' ')';
S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);

%% Motions, muscles and work to extract
MuscleVariables = {'Impulse' 'Activation' 'NormFibreLength' 'NormFibreVelocities' 'PassiveForce' 'ActiveForce'};
l = lower(SubjectInfo.TestedLeg);
JointVariables = strrep(strrep(S.moments,['_' l '_moment'],''),'_angle','');
ContactForceVariables = {'hip_x' 'hip_y' 'hip_z' 'knee_x' 'knee_y' 'knee_z' 'ankle_x' 'ankle_y' 'ankle_z'};

%% Set up group struct for angles, mometns and EMG and work struct
Ncols = length(SubjectFoldersElaborated);
Nrows = 101; % time normalised data

[G,E] = createResulsStruct_JCFFAI(S.RecordedEMG,TrialList,MuscleVariables,...
    JointVariables,ContactForceVariables, Ncols,Nrows);
BG = {'Subj' 'trialName' 'OptimalGamma'};
%% loop through all participants
for Subj = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{Subj},sessionName,suffix);
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    G.participants{Subj} = SubjectInfo.ID;
    if ~exist([Dir.CEINMSsimulations]) || length(Trials.CEINMS)<1
        continue
    end
    
    % import moments and kinematics
    cmdmsg(['Importing data participant ' SubjectInfo.ID])
    
    dofList = split(CEINMSSettings.dofList ,' ')';
    S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);
    
    %% delete trials that do not match the TrialList
    % get trial names all with same format (
    Strials = getstrials(Trials.CEINMS);
    
    for tt = flip(1:length(Trials.CEINMS))
        trialName = Trials.Dynamic{tt};
        [osimFiles] = getosimfilesFAI(Dir,trialName); % also creates the directories
        if ~exist(osimFiles.IDresults) || ~exist(osimFiles.IKresults) || ...
                ~contains(Strials{tt},TrialList)
            Trials.Dynamic(tt) =[];
        end
    end
    % get trial names all with same format
    Strials = getstrials(Trials.CEINMS);
    %% loop through all trials in the list and store data in struct
    for tt = 1:length(Trials.CEINMS)%[length(Files)-1,length(Files)-2]
        
        trialName = Trials.CEINMS{tt};
        osimFiles = getosimfilesFAI(Dir,trialName); % also creates the directories
        SimulationDir = [Dir.CEINMSsimulations fp trialName];
        
        if length(dir(SimulationDir))<3 || ~contains(Strials{tt},TrialList)
            continue
        end
        warning off
        JCFStruct = importdata(osimFiles.JRAresults);
        JointNames = S.Joints;
        [~,LabelsCF] = findData(JCFStruct.data,JCFStruct.colheaders,JointNames,0);
        deleteCols = contains(LabelsCF,{'mz' 'my' 'mx' 'pz' 'py' 'px'});
        LabelsCF(:,deleteCols)=[];
        
        Time = JCFStruct.data(:,1);
        TimeWindow = [JCFStruct.data(1,1) JCFStruct.data(end,1)];
        
        [ContactForces,LabelsCF] = LoadResults_BG (osimFiles.JRAresults,TimeWindow,LabelsCF,1,0);
        if contains(SubjectInfo.TestedLeg,'L')
            ContactForces(:,[3,6,9]) =  -ContactForces(:,[3,6,9]);
        end
            
        TotJFC = [sum(abs(ContactForces(:,1:3)),2) sum(abs(ContactForces(:,4:6)),2) sum(abs(ContactForces(:,7:9)),2)];
        G.Impulse = trapz(Time,TotJFC);

        % Sort data in a struct
        %  G = SortData(G,fld,Data,Labels,trialName,motionsG,col)
        G = SortData(G,'MTUforce',MTUforce,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),Subj);
        G = SortData(G,'Activation',Activation,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),Subj);
%         G = SortData(G,'MeasuredEMG',MeasuredEMG,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),Subj);        
        G = SortData(G,'NormFibreLength',NormFibreLength,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),Subj);
        G = SortData(G,'NormFibreVelocities',NormFibreVelocities,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),Subj);
        G = SortData(G,'ContactForces',ContactForces,LabelsCF,Strials{tt},ContactForceVariables,Subj);
%         G = SortData(G,'PassiveForce',PassiveForce,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),ff);
%         G = SortData(G,'ActiveForce',ActiveForce,LabelsMuscles_post,Strials{tt},strtrim(S.RecordedEMG),ff);
        G = SortData(G,'IK',IK,LabelsIK,Strials{tt},JointVariables,Subj);
        G = SortData(G,'ID',ID,LabelsID,Strials{tt},JointVariables,Subj);
    end  
    save(savedir,'G','E')
end
