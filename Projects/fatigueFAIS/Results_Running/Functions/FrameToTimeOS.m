% convert GaitCycle (from IK_OpenSim_BG) to time in OpenSim

function GaitCycleSec = FrameToTimeOS

DirIK = uigetdir('','Select inverseKinematics Folder');
cd(DirIK)
folderIK = sprintf('%s\\%s',DirIK,'*.mat');
Files = dir(folderIK);
NFields =  length(Files);
GaitCycleSec = struct;
fs = 200;

for ii= 1:NFields
TrialName = Files(ii).name;

filename = [DirIK filesep TrialName];
load(filename)
GCfields = fields(GaitCycle);
NGaitCylceFields = length(fields(GaitCycle));
TrialName = erase(TrialName,'.mat');
TrialName = erase(TrialName,'GaitCycle-');
for gg = 1: NGaitCylceFields
    
GaitCycleSec.(TrialName).(GCfields{gg}) = GaitCycle.(GCfields{gg})/fs;
end

end