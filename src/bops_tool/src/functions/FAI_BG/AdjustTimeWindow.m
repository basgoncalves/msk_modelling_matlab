
function [TimeWindow,FramesWindow,FootContact] = AdjustTimeWindow...
    (Dir,SubjectInfo,Trials,trialName,TimeWindow,FramesWindow,FootContact)

fp = filesep;
s = lower (SubjectInfo.TestedLeg);
if contains(SubjectInfo.RunningPhase,'Stance')
    TimeWindow(1) = FootContact.time;
    FramesWindow(1) = FootContact.frame;
    FootContact_frame = FootContact.frame-FramesWindow(1)+1;
elseif contains(SubjectInfo.RunningPhase,'Swing')
    TimeWindow(2) = FootContact.time;
    FramesWindow(2) = FootContact.frame;
    FootContact_frame = FramesWindow(2)-FramesWindow(1);
elseif contains(SubjectInfo.RunningPhase,'PeakHipFlexion') && contains(trialName,Trials.RunStraight)
    Normalise = 0;
    [IK,LabelsIK] = LoadResults_BG ([Dir.IK fp trialName fp 'IK.mot'],...
        TimeWindow,{'time' ['hip_flexion_' s]},1,Normalise);
    [~,frame] = max(IK(:,2));
    TimeWindow(1) = IK(frame,1);
    FramesWindow(1) =  FramesWindow(1)+frame-1;
end