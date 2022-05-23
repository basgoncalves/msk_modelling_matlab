%% Description - Basilio Goncalves (2020)
% IsometricTorqueEMG
% https://www.researchgate.net/profile/Basilio_Goncalves
%
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   copyTrials_FAI
%   MaxStrengthPerSubject_FAI
%   reaclibrateForce
%   MaxEMG_FAI
%   PlotsMaxStrength_FAI
%   PlotMeanStrengthDiff_FAI
%   copyTrials_FAI                      

function IsometricTorqueEMG(Dir,SubjectInfo)

fp = filesep;
saveDir=[Dir.Elaborated fp 'StrengthData'];

%% Max strength
fprintf('Calculating max torque for subject "%s" \n',SubjectInfo.ID)
MaxStrengthPerSubject_FAI           % callback

% reaclibrateForce

%% Max EMG
% EMG analyis - callback EMGanalysis_FAI

fprintf('Calculating max EMG for subject "%s" \n',SubjectInfo.ID)

StrengthFolder = ([Dir.Elaborated fp 'StrengthData']);
% name of the trials that should be in each folder
Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
EMGdataAll = EMGanalysis_FAI(2,Dir.Input,Isometrics_pre,Dir,SubjectInfo);

%Plot individual tirals EMG and get max EMG & Order EMG + Pre EMGs only & Max EMG Trials saved
[MaxEMGTrials,IdxMaxEMG] = MaxEMG_FAI(Dir.Elaborated,EMGdataAll,Dir,SubjectInfo);

%% Get Plots EMG channels for all tasks

[Nrow,Ncol] = size (MaxEMGTrials);
GroupData = cell2mat(MaxEMGTrials(2:Nrow,2:Ncol));
labels = MaxEMGTrials (2:end,1);
YLabel = 'EMG(mV)';
Channels = MaxEMGTrials (1,2:end);
TextBar = cell2mat(IdxMaxEMG(2:Nrow,2:Ncol));

% bar plot EMGs per muscle
MultiBarPlot (GroupData,Channels,labels,YLabel,TextBar);

% bar plot EMGs per task
% MultiBarPlot (GroupData',labels,Channels,YLabel);

source = sprintf('%s\\BarPlots.mat',cd);
destination = sprintf('%s\\Plot_Max_EMG-Isometrics.mat',Dir.StrengthData);
movefile(source, destination)

fprintf ('Max EMG data plots saved \n')

close all
fprintf ('data for %.f participant(s) has been analysed \n',...
    length(SubjectFoldersInputData))