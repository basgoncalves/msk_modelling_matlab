
% uses GCOS to get GaitCycle Open Sim and CEINMS

function TimeWindow = TimeWindow_FatFAIS_RRA(DirC3D,trialName,side)

fp = filesep;
if contains (trialName, 'run','IgnoreCase',1) && contains (trialName,'1') 
    [FC, TO, GaitCycle,FCPercent] = GCOS(DirC3D,trialName,side);
    TimeWindow(1) = GaitCycle.FC_time;
    TimeWindow(2) = GaitCycle.TO_time(2);
elseif contains (trialName, 'run','IgnoreCase',1) && contains (trialName,'2') 
    [FC, TO, GaitCycle,FCPercent] = GCOS(DirC3D,trialName,{'R'});
    TimeWindow(1) = GaitCycle.FC_time;
    TimeWindow(2) = GaitCycle.TO_time;
elseif contains (trialName, 'run','IgnoreCase',1) && contains (trialName,'3') 
    [FC, TO, GaitCycle,FCPercent] = GCOS(DirC3D,trialName,{'L'});
    TimeWindow(1) = GaitCycle.FC_time;
    TimeWindow(2) = GaitCycle.TO_time;
elseif contains(trialName,'SJ','IgnoreCase',1) ||  contains(trialName,'Squat','IgnoreCase',1)  
    
    TrialDir = [DirC3D fp trialName '.c3d'];
    Task = trialName;
    Events = findSquatEvents (TrialDir,Task);
    TimeWindow = Events.CEINMS; 
end
