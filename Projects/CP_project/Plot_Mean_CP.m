
function Plot_Mean_CP

fp = filesep;

elaboratedData = uigetdir; %Escolher pasta session1_barefoot               % directory elaborated data
dirIK = [elaboratedData fp 'inverseKinematics'];
dirSession = [elaboratedData fp 'session_data'];
m = 0;
%}events = importdata([DirUp(elaboratedData,3) fp 'events.xlsx']);
eventDir = [DirUp(elaboratedData,1) fp 'events.xlsx'];
events = importdata(eventDir);
events = events.textdata; %Tirar de comentário se já for a segunda vez a
%correr
Trials = dir(dirIK);
nTrials = length(Trials);

coor = {['hip_flexion'],['knee_angle'],['ankle_angle']};
groupData = struct;
data_column = struct;
for c = 1:length(coor)
    groupData.(coor{c}) = [];
    data_column.(coor{c}) = [];
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
    
    dirc3d =[dirSession fp trialName '.c3d'];
    dirc3d = strrep(dirc3d,'__','_');
    
    try    data = btk_loadc3d(dirc3d);
    catch; continue
    end
    
    if contains(leg,'r')
        event_1 = 'Right_Foot_Strike';
        event_2 = 'Right_Foot_Off';
    elseif contains(leg,'l')
        event_1 = 'Left_Foot_Strike';
        event_2 = 'Left_Foot_Off';
    end
    
    t1 = data.Events.Events.(event_1);
    t2 = data.Events.Events.(event_2);
    
    start = find(round(trial_data.time,4)==round(t1,4));
    finish = find(round(trial_data.time,4)==round(t2,4));
    
    % add to events.xlsx
    events{row,4} = round(t1,4);
    events{row,5} = round(t2,4);
    
    coor_trial = strcat(coor,['_' leg]);
    
    for c = 1:3 %length(coor)
        data_column.(coor{c})(:,end+1) = trial_data.(coor_trial{c})(start:finish,1);
        %groupData.(coor{c})(:,end+1) = TimeNorm(trial_data.(coor_trial{c}),100);
        groupData.(coor{c})(:,end+1) = TimeNorm(data_column.(coor{c}),50);
    end
    
    trialName_all{end+1} = trialName;                                                                               % add names of trials to a single variable
end

xlswrite(eventDir,events)


ha = tight_subplotBG(1,3); % ha = handle axis

ha(1).Position = [0.03    0.05    0.2800    0.900];

axes(ha(1))
plot(groupData.hip_flexion)
title('hip flexion')
ylabel('angle (deg)')
lg = legend(trialName_all);
lg.Position = [0.75    0.1    0.1397    0.2];

ha(2).Position = [0.35    0.05    0.2800    0.900];

axes(ha(2))
plot(groupData.knee_angle)
title('knee flexion')
ylabel('angle (deg)')

ha(3).Position = [0.68    0.4    0.2800    0.5500];   % [xPosition yPosition xSize ySize]

axes(ha(3))
plot(groupData.ankle_angle)
title('ankle flexion')
ylabel('angle (deg)')

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