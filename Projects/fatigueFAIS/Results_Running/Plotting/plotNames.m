% find data mean run to match plots
function [MeanAngle,SDAngle, MeanAngVel,SDAngVel, MeanMoments,SDMoments,MeanPowers,SDPowers,MeanFootContact,SDFootContact] =  plotNames (MeanRun,joint)


% angle 
MeanAngle = MeanRun.(joint).Angle.Mean;
SDAngle = MeanRun.(joint).Angle.SD;

% angular velocity
MeanAngVel = MeanRun.(joint).AngularVelocity.Mean;
SDAngVel = MeanRun.(joint).AngularVelocity.SD;


% Moments 
MeanMoments = MeanRun.(joint).Moments.Mean;
SDMoments = MeanRun.(joint).Moments.SD;

% Powers
MeanPowers = MeanRun.(joint).JointPowers.Mean;
SDPowers = MeanRun.(joint).JointPowers.SD;

% Powers
MeanFootContact = mean(MeanRun.FootContacts);
SDFootContact = std(MeanRun.FootContacts);