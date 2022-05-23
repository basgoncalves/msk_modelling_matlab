

OrganiseFAI


DirIDResults = [DirElaborated filesep 'inverseDynamics' filesep 'results'];
DirIKResults = [DirElaborated filesep 'inverseKinematics' filesep 'results'];
FilesID = dir([DirIDResults filesep '*.sto']);
FilesIK = dir([DirIKResults filesep '*.mot']);

if contains(TestedLeg,'R','IgnoreCase',1)
    Leg = 1;
    
elseif contains(TestedLeg,'L','IgnoreCase',1)
    Leg = 2;
else
    error ('tested leg not specified')
end

cd(DirIDResults)

%% Hip Flexion
figure
    title (sprintf('Hip Extension Moment(Nm) vs angle-%s ',Subject))
    ylabel ('- flexion                      Hip Extension Moment(Nm)                            + extension')
    mmfn
    
 
startColor = cool;
IDresults= struct;
IKresults = struct;
JointWork = struct;
LegendNames = {};
loops = size(FilesID,1);
for ff = 1:loops
    CurrentTrial = [erase(FilesID(ff).name, '_inverse_dynamics.sto')];
    IDresults.(CurrentTrial) = importdata ([FilesID(ff).folder filesep FilesID(ff).name]);
    IKresults.(CurrentTrial) = importdata ([FilesIK(ff).folder filesep FilesIK(ff).name]);
    LabelsID = IDresults.(CurrentTrial).colheaders;
    LabelsIK = IKresults.(CurrentTrial).colheaders;
        
    
    HipFlexMom=[];
    HipFlexionAngle=[];
    HipAddMom=[];
    HipRotMom=[];
    KneeMom=[];
    AnkleMom=[];
    
    % Hip Flexion moments
    Moment(:,1) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'hip_flexion_r_moment'));   % right
    Moment(:,2) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'hip_flexion_l_moment'));   % left
    Angle (:,1) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'hip_flexion_r'));   % right
    Angle (:,2) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'hip_flexion_l'));   % left
    Moment = Moment(:,Leg);
    Angle = Angle(:,Leg);
    [~,GaitCycle]= findpeaks(Angle);
    
    if length(GaitCycle)~=2
        continue
    end
    GaitCycle = GaitCycle(1):GaitCycle(2);           % from peak hip extension to peak hip extension
    Moment = TimeNorm (Moment(GaitCycle),2000);
    Angle = TimeNorm(Angle(GaitCycle),2000);
    
    hold on  
 
    p1 = plot (Moment,'Color', (startColor(round(ff*length (startColor)/loops),:)));
    xlabel ('- extension                               Hip Flexion Angle                                    + flexion')

    LegendNames{count}= CurrentTrial;
    count
end

legend (LegendNames,'Interpreter','none')

%% Hip adduction
figure
    title (sprintf('Hip Adduction Moment(Nm) vs angle - %s',Subject))
    ylabel ('- adduction                        Hip Adduction External Moment(Nm)                              + abduction')
    mmfn
    
 

IDresults= struct;
IKresults = struct;
JointWork = struct;
LegendNames = {};
for ff = 1:size(FilesID,1)
    CurrentTrial = erase(FilesID(ff).name, '_inverse_dynamics.sto');
    IDresults.(CurrentTrial) = importdata ([FilesID(ff).folder filesep FilesID(ff).name]);
    IKresults.(CurrentTrial) = importdata ([FilesIK(ff).folder filesep FilesIK(ff).name]);
    LabelsID = IDresults.(CurrentTrial).colheaders;
    LabelsIK = IKresults.(CurrentTrial).colheaders;
    HipFlexMom=[];
    HipFlexionAngle=[];
    HipAddMom=[];
    HipRotMom=[];
    KneeMom=[];
    AnkleMom=[];
    
    % Hip Flexion moments
    HipFlexMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'hip_adduction_r_moment'));   % right
    HipFlexMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'hip_adduction_l_moment'));   % left
    HipFlexionAngle (:,1) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'hip_adduction_r'));   % right
    HipFlexionAngle (:,2) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'hip_adduction_l'));   % left
    HipFlexMom = TimeNorm (HipFlexMom,2000);
    HipFlexionAngle = TimeNorm(HipFlexionAngle,2000);
    Moment = HipFlexMom(:,Leg);
    Angle = HipFlexionAngle(:,Leg);
    [~,GaitCycle]= findpeaks(Angle);
    if length(GaitCycle)~=2
        continue
    end
    GaitCycle = GaitCycle(1):GaitCycle(2);           % from peak hip extension to peak hip extension
    Moment = TimeNorm (Moment(GaitCycle),2000);
    Angle = TimeNorm(Angle(GaitCycle),2000);
    
    hold on  
 
    p1 = plot (Angle,Moment,'Color', (startColor(round(ff*length (startColor)/loops),:)));
    
    hold on
    
    xlabel ('- adduction                        Hip Adduction Angle                              + abduction')

    LegendNames{ff}= CurrentTrial;
end
    
legend (LegendNames,'Interpreter','none')


%% Knee
figure
     title ('Knee Flexion Moment (Nm)')
    ylabel('- flexion                   Knee Flexion Moment(Nm)                          + extension')
    mmfn


IDresults= struct;
IKresults = struct;
JointWork = struct;
for ff = 1:size(FilesID,1)
    CurrentTrial = erase(FilesID(ff).name, '_inverse_dynamics.sto');
    IDresults.(CurrentTrial) = importdata ([FilesID(ff).folder filesep FilesID(ff).name]);
    IKresults.(CurrentTrial) = importdata ([FilesIK(ff).folder filesep FilesIK(ff).name]);
    LabelsID = IDresults.(CurrentTrial).colheaders;
    LabelsIK = IKresults.(CurrentTrial).colheaders;
    HipFlexMom=[];
    HipFlexionAngle=[];
    HipAddMom=[];
    HipRotMom=[];
    KneeMom=[];
    AnkleMom=[];
    
    % Hip Flexion moments
    HipFlexMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'knee_angle_r_moment'));   % right
    HipFlexMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(LabelsID,'knee_angle_l_moment'));   % left
    HipFlexionAngle (:,1) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'knee_angle_r'));   % right
    HipFlexionAngle (:,2) = IKresults.(CurrentTrial).data(:,strcmp(LabelsIK,'knee_angle_l'));   % left
    HipFlexMom = TimeNorm (HipFlexMom,2000);
    HipFlexionAngle = TimeNorm(HipFlexionAngle,2000);
    
    
    hold on
    Moment = HipFlexMom(:,Leg);
    Angle = HipFlexionAngle(:,Leg);
    p1 = plot (Angle,Moment);
    xlabel ('- extension                        Knee Flexion Angle                              + flexion')

    LegendNames{ff}= CurrentTrial;
end
    
legend (LegendNames,'Interpreter','none')
%% ankle   
    subplot(3,1,3)
    title ('Ankle Moment (Nm)')
    ylabel ('- dorsiflexion/+ plantarflexion')
    mmfn
    xlabel ('% gait cycle (toe off to toe off)') 
    
       % Knee Flexion moments
    KneeMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'knee_angle_r_moment'));
    KneeMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'knee_angle_l_moment'));
    KneeMom = TimeNorm (KneeMom,2000);
    
    
       % Ankle moments
    AnkleMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'ankle_angle_r_moment'));
    AnkleMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'ankle_angle_l_moment'));
    AnkleMom = TimeNorm (AnkleMom,2000);
    
    % Hip Adduction moments
    HipAddMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'hip_adduction_r_moment'));
    HipAddMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'hip_adduction_l_moment'));
    HipAddMom = TimeNorm (HipAddMom,2000);
    
    
    % Hip Rotation moments
    HipRotMom(:,1) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'hip_rotation_r_moment'));
    HipRotMom(:,2) = IDresults.(CurrentTrial).data(:,strcmp(Labels,'hip_rotation_l_moment'));
    HipRotMom = TimeNorm (HipRotMom,2000);
%    
%      %find gait cycles
%     DirGaitCycle = [DirIK filesep 'GaitCycle-' CurrentTrial '.mat'];
%     load (DirGaitCycle)
%     ShiftData  = GaitCycle.ToeOff(1)+GaitCycle.foot_contacts - GaitCycle.ToeOff(2);
%     % Ground contact in pecentage of gait cycle
%     Contact = GaitCycle.foot_contacts(2)-ShiftData;
%     Total_Cycle_abs = GaitCycle.ToeOff-ShiftData;
%     Contact_percentage(i) = round(Contact*100/Total_Cycle_abs);
%     Contact_avg = round(mean(Contact_percentage));
%     
   
   
    hold(Figure.Plot(1),'on')
    DataPlot = HipFlexMom(:,1);
    p1 = plot (Figure.Plot(1),DataPlot);
    colourLine = get(p1, 'Color');
    plot(Figure.Plot(1),[Contact_percentage(i) Contact_percentage(i)], [min(DataPlot) max(DataPlot)],'color',colourLine)       % ground contact
   
  
    

    hold(Figure.Plot(2),'on')
    DataPlot = KneeMom(:,1);
    plot (Figure.Plot(2),DataPlot);
    plot(Figure.Plot(2),[Contact_percentage(i) Contact_percentage(i)], [min(DataPlot) max(DataPlot)],'color',colourLine)       % ground contact
 

   hold(Figure.Plot(3),'on')
   DataPlot = AnkleMom(:,1);
    plot (Figure.Plot(3),DataPlot);
    plot(Figure.Plot(3),[Contact_percentage(i) Contact_percentage(i)], [min(DataPlot) max(DataPlot)],'color',colourLine)       % ground contact
    
    TitlePlot = sprintf('Joint moments subject %s',Subject);
    suptitle(TitlePlot) 
    
  


    
     


    
 mkdir([DirFigure filesep 'InverseDynamics_Running'])
    cd([DirFigure filesep 'InverseDynamics_Running']);
    saveas(gcf, sprintf('JointMoments-%s.jpeg',Subject,CurrentTrial))
    cd(DirIDResults)
    
%% Angle vs Moment Plots




