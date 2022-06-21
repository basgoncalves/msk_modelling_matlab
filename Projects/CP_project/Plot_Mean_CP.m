
function Plot_Mean_CP

currentDir = fileparts(mfilename('fullpath'));

try DirElaboratedData = char(importdata([currentDir fp 'previousDirElaboratedData.dat'])); catch;end                % check if there is a file with previously loaded data directory (to start from there)

msg = 'select folder with elaborated session (e.g. ~\ElaboratedData\Subject1\Session1';
DirElaboratedData = uigetdir(DirElaboratedData,msg);                                                                % Escolher pasta session1_barefoot   

fileattrib([currentDir fp 'previousDirElaboratedData.dat'],'-h','','s')                                             % make .dat file visible so it can be loaded
writematrix(DirElaboratedData,[currentDir fp 'previousDirElaboratedData.dat'])                                      % save new loaded directory in the file
fileattrib([currentDir fp 'previousDirElaboratedData.dat'],'+h','','s')                                             % make file hidden (only for windows)

cd(DirElaboratedData)
dirIK = [DirElaboratedData fp 'inverseKinematics'];

[~,session_name] = DirUp(DirElaboratedData,1);
[~,subject] = DirUp(DirElaboratedData,2);
dirC3d = [DirUp(DirElaboratedData,3) fp 'InputData' fp subject fp session_name];

eventDir = [DirUp(DirElaboratedData,3) fp 'events.xlsx'];
events = importdata(eventDir);
event_labels = events(1,:);
col_trial   = contains(event_labels,'trial');
col_leg     = contains(event_labels,'leg');
col_start   = contains(event_labels,'start');
col_finish  = contains(event_labels,'finish');

events = events(2:end,:);                                                                                           % Tirar de comentário se já for a segunda vez a

Trials = dir(dirIK);
nTrials = length(Trials);

coor = {['hip_flexion'],['hip_adduction'],['hip_rotation'],['knee_angle'],['ankle_angle']};
groupData = struct;
data_column = struct;
for c = 1:length(coor)
    groupData.(coor{c}) = [];
    data_column.(coor{c}) = [];
end

trialName_all = {};
trial_leg = {};
for i = 3:nTrials
    
    trialName   = Trials(i).name;
    trial_data  = load_sto_file([dirIK fp trialName fp 'IK.mot']);
    
    row_trial = find(contains(events(:,col_trial),trialName));
    leg = events{row_trial,col_leg};
    
    if contains(leg,'-')
        continue                                                                                                     % segue para proxima iteracao
    end
    
    c3dfilepath = [dirC3d fp trialName '.c3d'];
    c3dfilepath = strrep(c3dfilepath,'__','_');
    
    try    data = btk_loadc3d(c3dfilepath);
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
    events{row_trial,col_start}  = round(t1,4);
    events{row_trial,col_finish} = round(t2,4);
    
    coor_trial = strcat(coor,['_' leg]);
    
    for c = 1:length(coor)
        data_column = trial_data.(coor_trial{c})(start:finish,1);
        groupData.(coor{c})(:,end+1) = TimeNorm(data_column,100);
    end
    
    trialName_all{end+1} = trialName;                                                                               % add names of trials to a single variable
    trial_leg{end+1}     = leg;
end

% xlswrite(eventDir,events)

ha = tight_subplotBG(1,5); % ha = handle axis

nTrials = length(trialName_all);
Colors = cell(nTrials,1);
Colors(contains(trial_leg,'r'),:) = {[1 0 0]};          % make colors for right leg = red
Colors(contains(trial_leg,'l'),:) = {[0 0 1]};          % make colors for left leg = blue
Colors = flip(Colors);

ha(1).Position = [0.03    0.05    0.2800    0.900];
axes(ha(1))
plot(groupData.hip_flexion)
colorPlot (ha(1),Colors)  
title('(extension -) hip sagittal (flexion +)')
ylabel('angle (deg)')
lg = legend(trialName_all);
lg.Position = [0.75    0.1    0.1397    0.2];

ha(2).Position = [0.35    0.05    0.2800    0.900];
axes(ha(2))
plot(groupData.knee_angle)
colorPlot (ha(2),Colors)  
title('(- extension) knee sagittal (flexion +)')

ha(3).Position = [0.68    0.4    0.2800    0.5500];                                                                 % [xPosition yPosition xSize ySize]
axes(ha(3))
plot(groupData.ankle_angle)
colorPlot (ha(3),Colors)  
title('(- plantarflex)   ankle flexion    (dorsiflex +)')

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


function colorPlot (ha,Colors)  
% ha = handle axes
hp = ha.Children;                       % plot handle

for i = 1:length(hp)
   hp(i).Color = (Colors{i}); 
end