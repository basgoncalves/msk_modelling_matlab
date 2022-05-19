
function [IKdata,T] = importIK(DirElaborated,trialName,motion)

fp = filesep;
data = importdata([DirElaborated fp 'inverseKinematics' fp trialName fp 'IK.mot']);
fs = 1/(data.data(2,1)-data.data(1,1));
[IKdata,SelectedLabels,IDxData] = findData(data.data,data.colheaders,motion,1);
T = data.data(:,1);

