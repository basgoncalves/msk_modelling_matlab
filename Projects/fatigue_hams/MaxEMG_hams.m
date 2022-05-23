%% Description - Goncalves, BM (2019)
% Gets max EMG for all the channels in all the .c3d files in one folder
%
% CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   emgAnalysis
%   emgAnalysis_noplots
%   getMaxTrials
%-------------------------------------------------------------------------
%INTPUT
%   logic - 1(Default) = plot graphs; 2 = don't plot 
%-------------------------------------------------------------------------


fp = filesep;

tmp = matlab.desktop.editor.getActive;
pwd = fileparts(fileparts(fileparts(tmp.Filename))); cd(pwd);
addpath(genpath(pwd));

% create directories 
DirEMGdata = 'E:\2-Fatigue_hams\EMGdata';
if ~exist(DirEMGdata)
    DirEMGdata = uigetdir('','select Folder with trials with EMG ".mat" ');
end

RearrangeEMG_hams % script (EMG)

MeanEMG_perSubject % script (MeanEMG_perSubj  RelativeForce)

NormaliseEMG_hams %

PlotEMG_hams % script