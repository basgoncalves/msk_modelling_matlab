
function compareIKwithRRA (DirElaborated,trialName,motion,RRAinteration)

fp = filesep;
% 

%RRA data
data = importdata([DirElaborated fp 'residualReductionAnalysis' fp ...
    trialName fp RRAinteration fp trialName '_Kinematics_q.sto']);
fs = 1/(data.data(2,1)-data.data(1,1));
Ti = data.data(1,1); % initial time 
Tf = data.data(end,1); % final time
[RRAdata,SelectedLabels,IDxData] = findData(data.data,data.colheaders,motion,1);
RRAdata = TimeNorm(RRAdata,fs);

data = importdata([DirElaborated fp 'inverseKinematics' fp trialName fp 'IK.mot']);
fs = 1/(data.data(2,1)-data.data(1,1));

FirstFrame = find(data.data(:,1) == round(Ti,2));
LastFrame = find(data.data(:,1) == round(Tf,2));
[IKdata,SelectedLabels,IDxData] = findData(data.data(FirstFrame:LastFrame,:),data.colheaders,motion,1);
IKdata = TimeNorm(IKdata,fs);

figure
hold on
plot(IKdata)
plot(RRAdata)
legend ('IK','RRA')
xlabel('GaitCycle (%)')
ylabel('angle')
title (motion)
mmfn



