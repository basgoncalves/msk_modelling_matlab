

function calibrationTrials = findRunningCalibrationTrials (Dir,Trials)

fp = filesep;
trials ={};
V =[]; A=[];
% find max velocity for the running trials
for ii = 1: length(Trials.RunStraight)
    
    trialName = Trials.RunStraight{ii};
    if contains(trialName,{'baseline' 'runA'},'IgnoreCase',true)
        [V(:,end+1),A(:,end+1)] = getVelocity(Dir,trialName);
        trials{end+1} = trialName;
    end
end

% if there is only one running trial
if size(V,2) < 2
    
    [~,~,~,ContraLatLeg] = findLeg(Dir.Elaborated,Trials.RunStraight{1});
    
    V =[]; A=[];
    trials ={};
    for ii = 1: length(Trials.(['Cut' ContraLatLeg{1}]))
        trialName = Trials.(['Cut' ContraLatLeg{1}]){ii};
        if contains(trialName,'baseline','IgnoreCase',true)
            [V(:,end+1),A(:,end+1)] = getVelocity(Dir,trialName);
            trials{end+1} = trialName;
        end
    end
    
    [~,idx] = min(max(V)); % find the slowest speed
    calibrationTrials = [trials(idx)];
else
    
    [~,idx] = min(max(V)); % find the slowest speed
    calibrationTrials = [trials(idx)];
    
end

if length(Trials.Walking)>0
    calibrationTrials = [calibrationTrials  Trials.Walking(1)];
end

cmdmsg('Trials to use for calibration defined')
