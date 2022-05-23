% 
% rearrangeJointBiomechancis  
% 


TrialNames = {'Run_baselineA1';'Run_baselineB1';'RunA1';'RunB1';'RunC1';'RunD1';'RunE1';'RunF1';...
    'RunG1';'RunH1';'RunI1';'RunJ1';'RunK1';'RunL1'};

LRFAI


if ~exist('JointMotion') || sum(contains(fields(IDresults),JointMotion))~=1
    Variables = fields(IDresults);
    % select only one Joint
    [idx,~] = listdlg('PromptString',{'Choose the joint to plot'},'ListString',Variables,'SelectionMode','single');
    JointMotion = Variables (idx);
elseif sum(contains(fields(IDresults),JointMotion))==1
    Variables = fields(IDresults);
    JointMotion = Variables(contains(fields(IDresults),JointMotion));
end
%% rearrange 
Variables = fields(IDresults);

% Angle
Var = IKresults;
FieldName = Variables(contains(fields(Var),JointMotion));
Angle = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

% ang vel
Var = AngularVelocity;
FieldName = Variables(contains(fields(Var),JointMotion));
AngVel = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

% moment
Var = IDresults;
FieldName = Variables(contains(fields(Var),JointMotion));
Moment = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

% Power
Var = JointPowers;
FieldName = Variables(contains(fields(Var),JointMotion));
Power = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

%PosWork
Var = JointPosWork;
FieldName = Variables(contains(fields(Var),JointMotion));
PosWork = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

%Neg work
Var = JointNegWork;
FieldName = Variables(contains(fields(Var),JointMotion));
NegWork = rearrangeData (Var.(FieldName{1}),Labels,TrialNames);

%FootContacts
Var = GaitCycle.PercentageHeelStrike;
FootContact = rearrangeData (Var,Labels,TrialNames);

% mean Data

c3dData = btk_loadc3d([DirC3D filesep Labels{1} '.c3d']);
fs = c3dData.marker_data.Info.frequency;

[~,x] = size(Angle);  % number of columns 
Angle = TimeNorm (Angle,fs);
MeanAngle(1:101,end+1:end+x) = Angle;
MeanAngle(MeanAngle==0) = NaN;

AngVel = TimeNorm (AngVel,fs);
MeanAngVel(1:101,end+1:end+x) = AngVel;
MeanAngVel(MeanAngVel==0) = NaN;

Moment = TimeNorm (Moment,fs);
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
MeanFootContact(end+1,1:Nrows) = FootContact;


