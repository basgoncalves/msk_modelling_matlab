

function MaxVelocity = CalcVelocity_OpenSimPelvis(Dir,trialName,TimeWindow,MovingAverageFsRatio)

fp = filesep;
load([Dir.sessionData fp 'Rates.mat'])
fs = Rates.VideoFrameRate;

if~exist('TimeWindow')
    TimeWindow=[];
end

if~exist('MovingAverageFsRatio')
    MovingAverageFsRatio = 2;
end

IK_pelvis = LoadResults_BG ([Dir.IK fp trialName fp 'IK.mot'],...
            TimeWindow,{'time';['pelvis_tx']},1,0); 
        
MaxVelocity = round(max(movmean(calcVelocity (IK_pelvis(:,2),fs),fs/MovingAverageFsRatio)),2);
