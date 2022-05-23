% LRFAI
% load results FAI for a single participant

cd(DirElaborated)
if exist('IDresults.mat') 
load ('IDresults.mat');
else
disp('IDresults.mat does not exist')
end

if exist('IKresults.mat') 
load ('IKresults.mat');
else
disp('IKresults.mat does not exist')
end

if exist('maxRunningVelocity.mat') 
load (['maxRunningVelocity.mat']);
else
disp('maxRunningVelocity.mat does not exist')
end

if exist('RunningBiomechanics.mat') 
load ('RunningBiomechanics.mat');
else
disp('JointWork.mat does not exist.Variable  "Run" created')
Run = struct;
end


load([DirElaborated filesep 'sessionData\Rates.mat'])
fs_markers = Rates.VideoFrameRate;
fs_analog = Rates.AnalogFrameRate;