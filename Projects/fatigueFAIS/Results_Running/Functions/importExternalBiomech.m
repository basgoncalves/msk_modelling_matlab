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
%   G = Group data with angles, moments, emg and grf
%   W = joint work data
%   ST = spatio temporal
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% importExternalBiomech

function [G,W,ST] = importExternalBiomech(SubjectFoldersElaborated, sessionName,suffix,TrialList,savedir)

fp = filesep;
warning off


%% Motions, muscles and work to extract
motionsG = {['lumbar_extension'];['hip_flexion'];['hip_adduction'];['hip_rotation'];['knee_angle'];['ankle_angle']};
EMGmuscles = {'        VM','        VL','        RF','       GRA',...
    '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
    '        GL','       TFL','   GLUTMAX'}; % the spaces are part of the names

% ST = stance; SW = swing; p = positive; n = negative; f = flexor; e = extensor;
workVariables = {'STpfW','STnfW','STpeW','STneW','SWpfW','SWnfW','SWpeW','SWneW'};
% AP = anterio-posterior | ML = medio lateral | V = vertical
grfVariables = {'AP' 'ML' 'V'}; 
% 
stVariables = {'Vmax' 'Amax' 'StepTime' 'ContactTime' 'PosVmax' 'StepLength' 'StepFreq'};


%% Set up group struct for angles, mometns and EMG and work struct

Ncols = length(SubjectFoldersElaborated);
Nrows = 101; % time normalised data
if exist(savedir,'file')==2
    load(savedir)
    if  length(contains(fields(G.angles),motionsG)) == length(motionsG)
        skip = 1;
    else
        skip = 0;
    end
else
    [G,ST,W] = createResulsStruct_RSFAI(motionsG,EMGmuscles,workVariables,grfVariables,stVariables,TrialList,Ncols,Nrows);
    
end

%% loop through all participants 
for ff = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{ff},sessionName,suffix);
    
    if contains(SubjectInfo.ID,G.participants) && skip == 1
       cmdmsg(['Data for ' SubjectInfo.ID ' already extracted'])
       continue 
    end
    
    G.participants{ff} = SubjectInfo.ID;
    if ~exist([Dir.ID]) || length(dir([Dir.ID]))<3
        continue
    end
    
    % import moments and kinematics
    cmdmsg(['Importing data participant ' SubjectInfo.ID])
    % Motions to plot
    s = lower(SubjectInfo.TestedLeg);
    motions = {['lumbar_extension'];['hip_flexion_' s];['hip_adduction_' s];...
        ['hip_rotation_' s];['knee_angle_' s];['ankle_angle_' s]};
    moments = {['lumbar_extension_moment'];['hip_flexion_' s '_moment'];...
        ['hip_adduction_' s '_moment'];['hip_rotation_' s '_moment'];...
        ['knee_angle_' s '_moment'];['ankle_angle_' s '_moment']};
    
    %% delete trials that do not match the TrialList
     % get trial names all with same format (
    Strials = getstrials(Trials.Dynamic); 
    
    for tt = flip(1:length(Trials.Dynamic))
        trialName = Trials.Dynamic{tt};
        [osimFiles] = getosimfilesFAI(Dir,trialName); % also creates the directories
        if ~exist(osimFiles.IDresults) || ~exist(osimFiles.IKresults) || ...
               ~contains(Strials{tt},TrialList)
            Trials.Dynamic(tt) =[];
        end
    end
    % get trial names all with same format 
    Strials = getstrials(Trials.Dynamic); 
    %% loop through all trials in the list and store data in struct
    for tt = 1:length(Trials.Dynamic)%[length(Files)-1,length(Files)-2]
        
        trialName = Trials.Dynamic{tt};
        load([Dir.Elaborated fp 'sessionData' fp 'Rates.mat'])
        fs = Rates.VideoFrameRate;
        [TimeWindow, FramesWindow,FootContact] = TimeWindow_FatFAIS(Dir,trialName);
        MatchWord = 1; % 1 for "yes" (default) or 2 for "no";
        
        if length(TimeWindow)<2
           continue 
        end
        
        [TimeWindow,FramesWindow,FootContact] = AdjustTimeWindow(Dir,SubjectInfo,Trials,trialName,TimeWindow,FramesWindow,FootContact);
        
        Normalise = 1;
        % Import and time normalise data 
        % results = LoadResults_BG (DataDir,TimeWindow,FieldsOfInterest,fs)
        [IK,LabelsIK] = LoadResults_BG ([Dir.IK fp trialName fp 'IK.mot'],...
            TimeWindow,motions,MatchWord,Normalise);
        [ID,LabelsID] = LoadResults_BG ([Dir.ID fp trialName fp 'inverse_dynamics.sto'],...
            TimeWindow,moments,MatchWord,Normalise);
        [measuredEMG,LabelsEMG] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp 'emg.mot'],...
            TimeWindow,EMGmuscles,0,Normalise);
        
        [~,IK] = AdjustMissingGaitCyclePhases(Dir,SubjectInfo.RunningPhase,IK);
        [~,ID] = AdjustMissingGaitCyclePhases(Dir,SubjectInfo.RunningPhase,ID);
        [StartingFrame,measuredEMG] = AdjustMissingGaitCyclePhases(Dir,SubjectInfo.RunningPhase,measuredEMG);
        
        
        
       % find stance times
       % start of the GRF using "full sampled" data (use because the initial GRF may not be exactly
       % where the FootContact happens at the MOCAP sample frequency
        GRFWindow = [FootContact.time-0.05 TimeWindow(2)];
        [V,~] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp trialName '.mot'],...
            GRFWindow,{'time' '_vy'},0,0); % only stance
        t = V(find(sum(V(:,2:end),2)),1); % find the times where GRF exists
        GRFWindow = [t(1) t(end)];
        
        
        % GRF during stance
        [AP,~] = LoadResults_BG([Dir.dynamicElaborations fp trialName fp trialName '.mot'],...
            GRFWindow,{'_vx'},0); % only stance
        [ML,~] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp trialName '.mot'],...
            GRFWindow,{'_vz'},0); % only stance
        [V,~] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp trialName '.mot'],...
            GRFWindow,{'_vy'},0); % only stance
        
        [Work,PNorm] = jointworkcalc (Dir,SubjectInfo,Trials, trialName,motions,moments);
        
        
        % Sort data in a struct
        %  G = SortData(G,fld,Data,Labels,trialName,motionsG,col)
        G = SortData(G,'angles',IK,LabelsIK,Strials{tt},motionsG,ff); 
        G = SortData(G,'moments',ID,LabelsID,Strials{tt},motionsG,ff);
        G = SortData(G,'emg',measuredEMG,LabelsEMG,Strials{tt},strtrim(EMGmuscles),ff);
        %GRF
        G.grf.AP.(Strials{tt})(1:101,ff)= sum(AP,2);
        G.grf.ML.(Strials{tt})(1:101,ff)= sum(ML,2);
        G.grf.V.(Strials{tt})(1:101,ff)= sum(V,2);
        
        % sort work data
        W = SortData_work(W,Work,Strials{tt},motionsG,ff);
                
        % Spatio temporal data 
        IK_pelvis = LoadResults_BG ([Dir.IK fp trialName fp 'IK.mot'],...
            TimeWindow,{'time';['pelvis_tx'];['pelvis_ty'];['pelvis_tz']},MatchWord,0);
        
        FC = find(round(IK_pelvis(:,1),4)==round(FootContact.time,4));
       
        velocity = calcVelocity (IK_pelvis(:,2),fs);
        Acc = calcAcc (IK_pelvis(:,2),fs)./100;
        [ST.Vmax.(Strials{tt})(ff), idx]= max(movmean(velocity,fs/10));
        [ST.Amax.(Strials{tt})(ff), idx]= max(movmean(Acc,fs/10));
        ST.PosVmax.(Strials{tt})(ff) = IK_pelvis(idx,2); % the origin of the FP was at 8m from the straing line
        ST.StepTime.(Strials{tt})(ff) = TimeWindow(2)-TimeWindow(1);
        ST.ContactTime.(Strials{tt})(ff) = TimeWindow(2)-FootContact.time;
        DirC3DTrial = [Dir.Input fp trialName '.c3d'];
        [SL,SF] = GetStepLength(DirC3DTrial,FramesWindow,'MT',SubjectInfo.TestedLeg);
        ST.StepLength.(Strials{tt})(ff) = SL;
        ST.StepFreq.(Strials{tt})(ff) = SF;
    end
    
 save(savedir,'G','W','ST')
end



%%   ==============================================================================================================  %
%%   ================================================ CALLBACK FUCNTIONS ==========================================  %
%%   ==============================================================================================================  %

function [G,ST,W] = createResulsStruct_RSFAI(motionsG,EMGmuscles,workVariables,grfVariables,stVariables,TrialList,Ncols,Nrows)
%% create structs
G = struct;% group data
ST = struct; % spatio temppral data
for k = 1:length(motionsG)
    G.angles.(motionsG{k})= struct;
    G.moments.(motionsG{k})= struct;
    for kk = 1: length(TrialList)
        G.angles.(motionsG{k}).(TrialList{kk})= NaN(Nrows,Ncols);
        G.moments.(motionsG{k}).(TrialList{kk})= NaN(Nrows,Ncols);
        for k3 = 1:length(stVariables) 
          ST.(stVariables{k3}).(TrialList{kk})=NaN(1,Ncols);
        end       
    end
end

for k = 1:length(EMGmuscles)
    G.emg.(strtrim(EMGmuscles{k}))= struct;
       for kk = 1: length(TrialList)
        G.emg.(strtrim(EMGmuscles{k})).(TrialList{kk})= NaN(Nrows,Ncols);
    end
end


for k = 1:length(grfVariables)
    G.grf.(strtrim(grfVariables{k}))= struct;
    for kk = 1: length(TrialList)
        G.grf.(strtrim(grfVariables{k})).(TrialList{kk})= NaN(Nrows,Ncols);
    end
end

G.participants = {};

% Set up group strunct for work 

W = struct;% work data
for k = 1:length(motionsG)
    W.(motionsG{k})= struct;
    for kk = 1:length(workVariables)
        W.(motionsG{k}).(workVariables{kk})= struct;
        for k3 = 1: length(TrialList)
        W.(motionsG{k}).(workVariables{kk}).(TrialList{k3})= NaN(1,Ncols);
        end
    end
end
