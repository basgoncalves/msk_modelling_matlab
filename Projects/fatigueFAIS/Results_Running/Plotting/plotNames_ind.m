% find data mean run to match plots single participant

function [Angle, AngVel, Moments,Powers,FootContact] =  plotNames_ind (RunsStruc,joint,Cols)
Variables = fields(RunsStruc);
joint = Variables(contains(fields(RunsStruc),joint));
joint=joint{1};
% angle 
Angle = RunsStruc.(joint).Angle(:,Cols);

% angular velocity
AngVel = RunsStruc.(joint).AngularVelocity(:,Cols);

% Moments 
Moments = RunsStruc.(joint).Moments(:,Cols);

% Powers
Powers = RunsStruc.(joint).JointPowers(:,Cols);

FootContact = RunsStruc.GaitCycle.PercentageHeelStrike(:,Cols);
