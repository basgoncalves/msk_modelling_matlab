% OSimPower_NoPlots
% power and work calculations

OrganiseFAI
RunNames = {'Run_baselineA1';'Run_baselineB1';'RunA1';'RunB1';'RunC1';'RunD1';'RunE1';'RunF1';...
    'RunG1';'RunH1';'RunI1';'RunJ1';'RunK1';'RunL1'};
DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);


LRFAI % load results FAI for one single participant

Joints= fields(IDresults);
Njoints = length(Joints);

cd(DirElaborated)
Run = struct;



for ii = 1:length(Joints)         %loop through joints  / Joints(1) = Labels
    
    
    MomName = Joints{ii};
    Run.(MomName)= struct;
    
    Angle =  IKresults.(MomName);
    AngVel = calcVelocity(Angle,fs_markers);
    Moments = IDresults.(MomName)/MassKG;
    Power = AngVel.*Moments;
    Stiffness = diff(IDresults.(MomName))./diff((Angle*180/pi));
    [Wpos,Wneg] = jointworkcalc (Power,fs_markers);
    
    [pfW,nfW,peW,neW] = SplitJointWork (Power,Moments,AngVel,fs_markers);         %split joint works based on muscle active
    
    Run.(MomName).Angle = Angle;
    Run.(MomName).Moments = Moments;
    Run.(MomName).AngularVelocity = AngVel;
    Run.(MomName).JointPowers = Power;
    Run.(MomName).JointPosWork = Wpos;
    Run.(MomName).JointNegWork = Wneg;
    Run.(MomName).Stiffness = Stiffness;
end



%% Plots to help troubleshooting
PlotTrial = 2;%size(Angle,2);
Nrows = length(find(~isnan(Angle(:,PlotTrial))));
FC = round(GaitCycle.PercentageHeelStrike(PlotTrial)*Nrows/100);

figure

subplot(511)
plot (Angle(:,PlotTrial))
plotVert(FC)
title('Angle')
mmfn

subplot(512)
plot(AngVel(:,PlotTrial))
plotVert(FC)
title('AgularVelocity')
mmfn

subplot(513)
plot(Moments(:,PlotTrial))
plotVert(FC)
title('Moments')
mmfn

subplot(514)
plot(Power(:,PlotTrial))
plotVert(FC)
title('Power')
mmfn

subplot(515)
plot(Stiffness(:,PlotTrial))
plotVert(FC)
title('Power')
mmfn

fullscreenFig(0.4,0.8)
