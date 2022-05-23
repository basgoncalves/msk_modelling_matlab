

%% total work
cd(DirResults)
load ('MeanRunningBiomechanics.mat')
MainFig = figure;

StakedSpss=[];
Joints = {'hip_flexion','knee','ankle'};
for ii = Joints
    
 joint= ii{1};   
Power = MeanRun.(joint).JointPowers.trial_1;
Moments = MeanRun.(joint).Moments.trial_1;
AngVel = MeanRun.(joint).AngularVelocity.trial_1;

[PeakPowers, Labels] = SplitJointPower (Power,Moments,AngVel,fs);

Power = MeanRun.(joint).JointPowers.trial_2;
Moments = MeanRun.(joint).Moments.trial_2;
AngVel = MeanRun.(joint).AngularVelocity.trial_2;
[PeakPowers2, Labels] = SplitJointPower (Power,Moments,AngVel,fs);
%spssStacked
PeakPowers= [PeakPowers PeakPowers2]';


StakedSpss = [StakedSpss PeakPowers];

end






title('Hip joint work','FontWeight','Normal')
nfW_hip = abs(nfW_hip); neW_hip = abs(neW_hip);

p1 = gcf;

joint = 'knee';
[pfW_knee,nfW_knee, peW_knee, neW_knee] = PlotBarSplitWork (MeanRun,joint,fs);
title('Knee joint work','FontWeight','Normal')
nfW_knee = abs(nfW_knee); neW_knee = abs(neW_knee);

p2=gcf;

joint = 'ankle';
[pfW_ankle,nfW_ankle, peW_ankle, neW_ankle] = PlotBarSplitWork (MeanRun,joint,fs);
title('Ankle joint work','FontWeight','Normal')
nfW_ankle = abs(nfW_ankle); neW_ankle = abs(neW_ankle);

p3=gcf;

mergeFigures (p1, MainFig,[3,1],1)
mergeFigures (p2, MainFig,[3,1],2)
mergeFigures (p3, MainFig,[3,1],3)
fullscreenFig(0.4,0.8)

close(p1,p2,p3)
cd([DirFigure filesep 'External_Biomechanics'])
saveas(MainFig, sprintf('JointWork_split.jpeg'));

%%

for ii = 1: 18
    
    Data = Work(ii,:);
   p(1,:) = Data(1:2);
   p(2,:) = Data(3:4);
   p(3,:) = Data(5:6);

   bar(p)
   
    saveas(gcf, sprintf('IndVWork_%.f.jpeg',ii));
end