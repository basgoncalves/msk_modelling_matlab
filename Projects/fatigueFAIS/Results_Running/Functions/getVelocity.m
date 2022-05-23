
% horizontal velocity and acceleration from the IK file

function [V,A] = getVelocity(Dir,trialName)

fp =filesep;
DataDir = [Dir.IK fp trialName fp 'IK.mot'];
Rates = getrates(Dir.Elaborated);
coordinates = {['pelvis_tx']};
TimeWindow = TimeWindow_FatFAIS(Dir,trialName);
MatchWholeWord = 0;
[IK,Labels] = LoadResults_BG (DataDir,TimeWindow,coordinates,MatchWholeWord);

% find max velocity
V = calcVelocity (IK,Rates.VideoFrameRate);
Vmax = max(V);

% find max acceleration
A =  calcVelocity (V,Rates.VideoFrameRate);
Amax = max(A);