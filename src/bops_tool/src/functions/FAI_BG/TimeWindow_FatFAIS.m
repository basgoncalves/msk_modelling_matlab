
%get tgait cycles for FAI fatigue project

function [TimeWindow,FramesWindow,SplitEvent] = TimeWindow_FatFAIS(Dir,trialName)

fp = filesep;
initialDir = cd;
TimeWindow =[];FramesWindow =[];
SplitEvent=struct; SplitEvent.time = [];SplitEvent.frame = [];
%
if ~exist([Dir.sessionData fp trialName])
    disp([Dir.sessionData fp trialName ' does not exisit'])
    disp(['creating Session folder...'])
    if ~exist([Dir.Input fp trialName '.c3d'])
        disp([Dir.Input fp trialName '.c3d' ' does not exisit'])
        return
    end
    C3D2MAT_BG(Dir.Input,{trialName})
end

[~,~,Leg,ContraLeg] = findLeg(Dir.Elaborated,trialName);
Leg = Leg{1};
[events,FPNumber,~] = findGaitCycle_FAIS(Dir.Elaborated,trialName);

if ~isempty(FPNumber) && contains (trialName,{'run'},'IgnoreCase',1) && contains(trialName,'1')
    
    TimeWindow = events.forceplateTimes.([Leg '_Foot_Off']);
    FramesWindow = events.forceplateEvents.([Leg '_Foot_Off']);
    SplitEvent.time = events.forceplateTimes.([Leg '_Foot_Strike']);
    SplitEvent.frame = events.forceplateEvents.([Leg '_Foot_Strike']);
    
elseif ~isempty(FPNumber) && contains(trialName,'run','IgnoreCase',1) && contains(trialName,{'2' '3'})
    
    TimeWindow = events.forceplateTimes.([Leg '_Foot_Strike']);
    TimeWindow(2) = events.forceplateTimes.([Leg '_Foot_Off']);
    
    FramesWindow = events.forceplateEvents.([Leg '_Foot_Strike']);
    FramesWindow(2) = events.forceplateEvents.([Leg '_Foot_Off']);
    
    SplitEvent.time = events.forceplateTimes.([Leg '_Foot_Strike']);
    SplitEvent.frame = events.forceplateEvents.([Leg '_Foot_Strike']);
    
elseif contains(trialName,'SJ','IgnoreCase',1) ||  contains(trialName,'Squat','IgnoreCase',1)
    
    TrialDir = [Dir.Input fp trialName '.c3d'];
    Task = trialName;
    Events = findSquatEvents (TrialDir,Task);
    TimeWindow = Events.CEINMS;
    
    FramesWindow(1) = Events.TakeOffFrame /10; % devide by 10 to match the frame in the markers
    FramesWindow(2) = Events.LandingFrame /10;
end

FramesWindow = round(FramesWindow,4);
TimeWindow = round(TimeWindow,4);
SplitEvent.time = round(SplitEvent.time,4);
SplitEvent.frame = round(SplitEvent.frame,4);


if contains (trialName,{'walk'},'IgnoreCase',1)
    [trialType,trialNumber] = getTrialType(trialName);
    [~,SubjectID] = DirUp(Dir.sessionData,3);
    [AcqTrial,TimeWindow,FramesWindow] = walkingStepForceplates_FAIS(SubjectID,trialType,trialNumber);
    
    Fplate = find(contains({AcqTrial.StancesOnForcePlatforms.StanceOnFP.leg},Leg));
    FP = load([Dir.sessionData fp trialName fp 'FPdata.mat']);
    R = load([Dir.sessionData fp 'Rates.mat']);
    fsratio = R.Rates.AnalogFrameRate/R.Rates.VideoFrameRate;
    Frames = FramesWindow - FP.FPdata.FirstFrame+1;
    Force = FP.FPdata.RawData([Frames(1)*fsratio:Frames(2)*fsratio],:);
    for k=1:length(Fplate); col(k)=find(contains(FP.FPdata.Labels,['Force.Fz' num2str(Fplate(k))])); end
    SumForce = sum(Force(:,col),2);
    fistForceValue = find(SumForce,1);      % ignore the first few frames if they are zero in case the detected foot contact time might be a little off (e.g. due to conversion from time to frames)
    ToeOff=find(SumForce(fistForceValue:end)==0,1);
    SplitEvent.frame=ToeOff(end)/fsratio + FramesWindow(1);
    SplitEvent.time=ToeOff(end)/FP.FPdata.Rate + TimeWindow(1);
end

cd(initialDir)