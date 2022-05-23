
function Plot_Mean_CP

fp = filesep;

elaboratedData = uigetdir;                                                                                          % directory elaborated data
dirIK = [elaboratedData fp 'inverseKinematics'];
events = importdata([DirUp(elaboratedData,3) fp 'events.xlsx']);

Trials = dir(dirIK);
nTrials = length(Trials);

coor = {['hip_flexion'],['knee_angle'],['ankle_angle']};
groupData = struct;
for c = 1:length(coor)
    groupData.(coor{c}) = [];
end

trialName_all = {};

for i = 3:nTrials
    
    trialName = Trials(i).name;
    trial_data = load_sto_file([dirIK fp trialName fp 'IK.mot']);
    
    row = find(contains(events(:,2),trialName));
    leg = events{row,3};
    
    if contains(leg,'-')
        continue                                                                                                     % segue para proxima iteracao
    end
    
    coor_trial = strcat(coor,['_' leg]);
    
    for c = 1:length(coor)
        groupData.(coor{c})(:,end+1) = TimeNorm(trial_data.(coor_trial{c}),100);
    end
    trialName_all{end+1} = trialName;                                                                               % add names of trials to a single variable 
end


ha = tight_subplotBG(1,3); % ha = handle axis 

axes(ha(1))
plot(groupData.hip_flexion)
title('hip flexion')
ylabel('angle (deg)')
lg = legend(trialName_all);
lg.Position = [0.8542    0.3830    0.1397    0.2690];

ha(3).Position = [0.5    0.0400    0.2800    0.9200];   % [xPosition yPosition xSize ySize]

axes(ha(2))
plot(groupData.knee_angle)

% add plot for ankle

mmfn_inspect

function TimeNormalizedData = TimeNorm (Data,fs)

TimeNormalizedData=[];

for col = 1: size (Data,2)
    
    currentData = Data(:,col);
    currentData(isnan(currentData))=[];
    if length(currentData)<3
        TimeNormalizedData(1:101,col)= NaN;
        continue
    end
    
    
    timeTrial = 0:1/fs:size(currentData,1)/fs;
    timeTrial(end)=[];
    Tnorm = timeTrial(end)/101:timeTrial(end)/101:timeTrial(end);
    
    TimeNormalizedData(1:101,col)= interp1(timeTrial,currentData,Tnorm)';
end