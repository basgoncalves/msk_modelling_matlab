% calculate positive and negative works for each data column

function [Work,Pnorm,P,LabelsWork] = jointworkcalc (Dir,SubjectInfo,Trials,trialName,motions,moments,IDanalysis)

fp = filesep;

osimFiles = getosimfilesFAI(Dir,trialName); % load paths for this trial 
 
[TimeWindow,FramesWindow,FootContact] = TimeWindow_FatFAIS(Dir,trialName);
[TimeWindow,FramesWindow,FootContact] = AdjustTimeWindow(Dir,SubjectInfo,Trials,trialName,TimeWindow,FramesWindow,FootContact);
FootContact_frame = FootContact.frame-FramesWindow(1);
if FootContact_frame==0; FootContact_frame=1;end
MatchWord = 1; % 1 for "yes" (default) or 2 for "no";
Normalise = 0; % 1 for "yes" (default) or 2 for "no";

% results = LoadResults_BG (DataDir,TimeWindow,FieldsOfInterest,fs)
[IK,LabelsIK] = LoadResults_BG (osimFiles.IKresults,TimeWindow,['time'; motions],MatchWord,Normalise);
fs = Rates.VideoFrameRate;
LabelsWork = LabelsIK(2:end);
tIK = IK(:,1);
IK(:,1) =[];
if exist('IDanalysis') && contains(IDanalysis,'RRA')
    [ID,LabelsID] = LoadResults_BG (osimFiles.IDRRAresults,TimeWindow,['time'; moments],MatchWord,Normalise);
else
    [ID,LabelsID] = LoadResults_BG (osimFiles.IDresults,TimeWindow,['time'; moments],MatchWord,Normalise);
end
tID = ID(:,1);
ID(:,1) =[];

idx = find(ismember(round(tIK,3),round(tID,3)));
IK = IK(idx,:);
idx = find(ismember(round(tID,3),round(tIK,3)));
ID = ID(idx,:);

% angular velocity in rad/sec
AV = calcVelocity(IK,fs);
AV = AV.*pi./180;
% power
P = AV.*ID;

% time Normalise
IKnorm = TimeNorm(IK,fs);
IDnorm = TimeNorm(ID,fs);
AVnorm = TimeNorm(AV,fs);
Pnorm =  TimeNorm(P,fs);

% joint work calculation
[pfW,nfW,peW,neW] = SplitJointWork (P,ID,AV,fs);
Work.TotalPosWork = sum(pfW + peW);
Work.TotalNegWork = sum(nfW + neW);


% Stance phase
P_stance = P(FootContact_frame:end,:);
ID_stance = ID(FootContact_frame:end,:);
AV_stance = AV(FootContact_frame:end,:);
% Swing phase
P_swing = P(1:FootContact_frame,:);
ID_swing = ID(1:FootContact_frame,:);
AV_swing = AV(1:FootContact_frame,:);

%split joint works based on joint power, moment and angular velocity
% (ST = stance; positive(p)/negative(n) flexion(f)/extension(e) work (W))
% (SW = swing; positive(p)/negative(n) flexion(f)/extension(e) work (W))
if contains(SubjectInfo.RunningPhase,'Stance')
    [Work.STpfW,Work.STnfW,Work.STpeW,Work.STneW] = SplitJointWork (P_stance,ID_stance,AV_stance,fs);
    Work.SWpfW = 0;Work.SWnfW = 0;Work.SWpeW = 0;Work.SWneW = 0;
elseif contains(SubjectInfo.RunningPhase,'Swing')
    Work.STpfW = 0;Work.STnfW = 0;Work.STpeW = 0;Work.STneW = 0;
    [Work.SWpfW,Work.SWnfW,Work.SWpeW,Work.SWneW] = SplitJointWork (P_swing,ID_swing,AV_swing,fs);
else
    [Work.STpfW,Work.STnfW,Work.STpeW,Work.STneW] = SplitJointWork (P_stance,ID_stance,AV_stance,fs);
    [Work.SWpfW,Work.SWnfW,Work.SWpeW,Work.SWneW] = SplitJointWork (P_swing,ID_swing,AV_swing,fs);
end
