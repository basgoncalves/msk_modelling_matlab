% 
% rearrangeJointBiomechancis_manual
% manually select individual trials in case a participant does not have all
% the trials 
% 


LRFAI

%% rearrange 
Variables = fields(IDresults);

TrialNames = {'Run_baselineA1' 'RunL1'}; 
AllNames = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
    'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};

TrialNames = findClosedText (Labels,TrialNames,AllNames);

if ~exist('TrialNames')||isempty(TrialNames)
    [DirElaborated,Joint,TrialNames,Motions,FootContact,Angle,Moment,AngVel,Power,PosWork,NegWork]...
    = JointBiomechPerAction (DirElaborated,JointMotion,{},1,'No'); 
else
    [DirElaborated,Joint,TrialNames,Motions,FootContact,Angle,Moment,AngVel,Power,PosWork,NegWork]...
    = JointBiomechPerAction (DirElaborated,JointMotion,TrialNames,1,'No') ;
end

[DirElaborated,Joints,TrialNames,BiomechData,Labels] = JointBiomechPerTrial (DirElaborated,Joints,TrialNames);

% mean Data

c3dData = btk_loadc3d([DirC3D filesep Labels{1} '.c3d']); 
fs = c3dData.marker_data.Info.frequency; 

[~,x] = size(Angle);   % number of columns 
Angle = TimeNorm (Angle,fs); 
MeanAngle(1:101,end+1:end+x) = Angle; 
MeanAngle(MeanAngle==0) = NaN; 

AngVel = TimeNorm (AngVel,fs); 
MeanAngVel(1:101,end+1:end+x) = AngVel; 
MeanAngVel(MeanAngVel==0) = NaN; 

Moment = TimeNorm (Moment/MassKG,fs); 
MeanMoment(1:101,end+1:end+x) = Moment; 
MeanMoment(MeanMoment==0) = NaN; 

Power = TimeNorm (Power,fs); 
MeanPowers(1:101,end+1:end+x) = Power;
MeanPowers(MeanPowers==0) = NaN; 

% joint work: col = Trial , row = particpant
Nrows = length(TrialNames);
MeanPosWork(end+1,1:Nrows) = PosWork;

Nrows = length(TrialNames);
MeanNegWork(end+1,1:Nrows) = NegWork;


% foot contact
[FootContact,SelectedLabels,IDxData] = findData (GaitCycle.PercentageHeelStrike,Labels,TrialNames);
MeanFootContact(end+1,1:Nrows) = FootContact;


