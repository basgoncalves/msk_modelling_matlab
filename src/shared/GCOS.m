
% GCOS
% GaitCycle Open Sim
function [FC, TO, GaitCycle,FCPercent] = GCOS(DirC3D,trialName,side)

fp = filesep;

if exist([DirC3D fp trialName '.c3d'])
       
    [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running ([DirC3D fp trialName '.c3d'],side,2);
    FC = GaitCycle.foot_contacts-GaitCycle.FirstFrameOpenSim;
    TO = GaitCycle.ToeOff-GaitCycle.FirstFrameOpenSim;
    if length(TO)>1
        FCPercent = (FC-TO(1))/(TO(2)-TO(1))*100;
    else
        FCPercent=[];
    end
    
    
    %time in seconds
    data = btk_loadc3d([DirC3D fp trialName '.c3d']);
    fs = data.marker_data.Info.frequency;
    GaitCycle.TO_time = GaitCycle.ToeOff / fs;
    GaitCycle.FC_time = GaitCycle.foot_contacts / fs;
  
else
    FC =[];
    TO =[];
    GaitCycle = [];
    FCPercent = [];
    disp([DirC3D fp trialName '.c3d' ' does not exisit'])
end

