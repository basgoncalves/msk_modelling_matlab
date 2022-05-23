% POSD
%plot opnesim data
[OSIMdata,ext] = IOSD % import openSim Data
if contains (ext,'.c3d')
    figure
    hold on
    plot(OSIMdata.fp_data.GRF_data(1).F(:,end))
    plot(OSIMdata.fp_data.GRF_data(2).F(:,end))
    plot(OSIMdata.fp_data.GRF_data(3).F(:,end))
    plot(OSIMdata.fp_data.GRF_data(4).F(:,end))
    Lh = {'FP1','FP2','FP3','FP4'};
else
    VariablesOsim = OSIMdata.colheaders;
    [idx,~] = listdlg('PromptString',{'Choose the varibales to plot kinematics'},'ListString',VariablesOsim);
    JointMotions = VariablesOsim (idx);
    
    [SelectedData,SelectedLabels,IDxData] = findData (OSIMdata.data,VariablesOsim,JointMotions);        %select data based on labels
    
    figure
    plot(SelectedData)
    legend (SelectedLabels, 'Interpreter','none')
    mmfn
    Lh = {TrialName};
end

if exist('NewSubject')
    title(sprintf('%s-%s',NewSubject,TrialName),'Interpreter','none')
end

NewDirIK = strrep(DirIK, [filesep Subject], [filesep NewSubject]);


if exist([NewDirIK filesep 'GaitCycle-' TrialName '.mat'])
    load ([NewDirIK filesep 'GaitCycle-' TrialName '.mat'])
    openvar ('GaitCycle')
    GCOS
    plotVert (ToeOff)
    plotVert (foot_contacts)
    legend([Lh,{'TO1','FC','TO2'}])
    
end