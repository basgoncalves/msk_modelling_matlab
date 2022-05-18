%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% plot EMG for a single trial from the c3d file
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------

%% faiemg

%plot data

cd(DirC3D)
[filename FilePath] = uigetfile ('*.c3d','select the .mot file');
filename = ([FilePath filename]);
ChannelNames = {'Voltage_1_VM';'Voltage_2_VL';'Voltage_3_RF';'Voltage_4_GRA';'Voltage_5_TA';...
    'Voltage_6_AL';'Voltage_7_ST';'Voltage_8_BF';'Voltage_9_MG';'Voltage_10_LG';...
    'Voltage_11_TFL';'Voltage_12_Gmax';'Voltage_13_Gmed_intra';'Voltage_14_PIR_intra';...
    'Voltage_15_OI_intra';'Voltage_16_QF_intra';'Force_Rig'};

[filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename,ChannelNames);

VariablesOsim = ChannelNames;
[idx,~] = listdlg('PromptString',{'Choose the varibales to plot kinematics'},'ListString',VariablesOsim);
SelectedNames = VariablesOsim (idx);

fcolow = 6;
fcohigh = 50;
[filter_EMG1,FFT_EMG] = emgAnalysis_noplots(EMGdata(:,idx), Fs, fcolow, fcohigh);

figure
hold on
plot(filter_EMG1)
plot(EMGdata(:,idx))
ylabel('EMG (mV)')
yyaxis right
plot(EMGdata(:,end))
ylabel('Force (N)')

Lh = erase(filename,'.c3d');
title(Lh,'Interpreter','none')
legend(SelectedNames,'Interpreter','none')

mmfn

