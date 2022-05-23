% plot kinematics FAI

%% Plot hip knee and ankle
OrganiseFAI

figure
TimeNormHipFlexion=[];
TimeNormKneeFlexion=[];
TimeNormAnkle=[];
Contact_percentage=[];


% tested Leg from "Organise FAI" script
if contains(TestedLeg,'R')
    NamesVariables = {'hip_flexion_r','knee_angle_r','ankle_angle_r'};
else
    NamesVariables = {'hip_flexion_l','knee_angle_l','ankle_angle_l'};
end

for i = 1:length(KinematicsRunning)
    
    % select hip data
    subplot(3,1,1)
    VariblePlot = NamesVariables(1);
    [dataPlot,labelPlot,IDxData] = findData (KinematicsRunning{i},SelectedLabels,VariblePlot);
    
%     %find gait cycles
%     DirGaitCycle = [DirIK filesep 'GaitCycle-' erase(KinematicsRunningLabels{i},'_IK') '.mat'];
%     load (DirGaitCycle)
%     ShiftData  = GaitCycle.foot_contacts(1)+GaitCycle.ToeOff - GaitCycle.foot_contacts(2);
%     % Ground contact in pecentage of gait cycle
%     Contact = GaitCycle.foot_contacts(2)-ShiftData;
%     Total_Cycle_abs = GaitCycle.ToeOff-ShiftData;
%     Contact_percentage(i) = round(Contact*100/Total_Cycle_abs);
%     Contact_avg = round(mean(Contact_percentage));
    
    TimeNormHipFlexion(:,i) = TimeNorm (dataPlot(:,1),200);
    p1 = plot(smooth((TimeNormHipFlexion(:,i))));                                         % hip flexion angles
     colourLine = get(p1, 'Color');
%     plot([Contact_percentage(i) Contact_percentage(i)], [min(ylim) max(ylim)],'color',colourLine)       % ground contact
    title ('Hip flexion angle')
    ylabel ('- extension/+ flexion')
    mmfn
    hold on
    
    % select knee data
    subplot(3,1,2)
    VariblePlot = NamesVariables(2);
    [dataPlot,labelPlot,IDxData] = findData (KinematicsRunning{i},SelectedLabels,VariblePlot);
    TimeNormKneeFlexion(:,i) = TimeNorm (dataPlot(:,1),200);
    plot(smooth((TimeNormKneeFlexion(:,i))));                               % Knee flexion angles
%      plot([Contact_percentage(i) Contact_percentage(i)], [min(ylim) max(ylim)],'color',colourLine)       % ground contact
    title ('Knee flexion angle')
    yhl = ylabel ('- extension/+ flexion');          % y label
    pos = get (yhl,'position');  pos(1) = -8;
    set (yhl,'position', pos)
    
    mmfn
    hold on
    
    % select ankle data
    subplot(3,1,3)
    VariblePlot = NamesVariables(3);
    [dataPlot,labelPlot,IDxData] = findData (KinematicsRunning{i},SelectedLabels,VariblePlot);
    TimeNormAnkle(:,i) = TimeNorm (dataPlot(:,1),200);
    plot(smooth((TimeNormAnkle(:,i))));                                          % ankle  angles
%     plot([Contact_percentage(i) Contact_percentage(i)], [min(ylim) max(ylim)],'color',colourLine)       % ground contact
    title ('Ankle angle')
    ylabel ('- plantarflexion/+ dorsiflexion')
    xlabel ('% gait cycle (heel strike to heel strike)')
    mmfn
    hold on
    
end
TitlePlot = sprintf('Kinematics subject %s',Subject);
suptitle(TitlePlot)
legend (KinematicsRunningLabels,'Interpreter','none')

% plot average heel strike
% Contact_avg = round(mean(Contact_percentage));
% for ii = 1:3
%     subplot(3,1,ii)
%     hold on
%     maxY = yaxis;
%     plotContact_avg
% end


%% Plot Pelvic tilt
figure
idxPeaks={};
VariblePlot ={'pelvis_list','pelvis_tilt','pelvis_rotation'};
for i = 1:length(KinematicsRunning)
    
    for pp = 1:3
        % select hip data
        subplot(3,1,pp)
        [dataPlot,labelPlot,IDxData] = findData (KinematicsRunning{i},SelectedLabels,VariblePlot(pp));
        TimeNormpelvic_tilt(:,i) = TimeNorm (dataPlot(:,1),200);
        plot(smooth(TimeNormpelvic_tilt(:,i))) % hip flexion angles
        title (VariblePlot{pp})
        xlabel('Gait Cycle(%) - Toe off to Toe off')
        mmfn
        hold on
    end
    
end
legend (KinematicsRunningLabels,'Interpreter','none')

%% Plot Hip vs knee angles
figure
LoopTrough = [11 12 13 14]; %1:length(KinematicsRunning)

for i = 1:length(KinematicsRunning)
    y=[]
    y(:,1) = TimeNormKneeFlexion(:,i);  %knee data
    y(:,2) = TimeNormHipFlexion(:,i);   % hip data
    y(:,3) = TimeNormAnkle(:,i);
    x = [1:101];
    plot (y(:,2), y(:,1))
    hold on
    mmfn
    TitlePlot = sprintf('Hip vs knee angles subject %s',Subject);
    title (TitlePlot)
    ylabel ('-Extension                       Knee angle                     + Flexion')
    xlabel ('-Flexion                                                      Hip angle                                               + Extension')
end

legend (KinematicsRunningLabels,'Interpreter','none')
