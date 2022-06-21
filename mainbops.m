% Before running this pipeline check the following scripts and update
% directories, trial names and demographics
%   setupbopstool
%   getTrials
%   CEINMSsetup
%   ..\setuptools\bopsSetup.xml
% Run section = CTRL + ENTER
% Run whole script = F5

% by Basilio Goncalves, basilio.goncalves7@gmail.com
%% Setup
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
bopsdir  = fileparts(activeFile.Filename);                                                                          
addpath(genpath(bopsdir));                                                                                          % add current folder to MATLAB path
bops = setupbopstool;                                                                                               % add "DataProcessing_master" pipeline
OsimDirDefine                                                                                                       % check if OpenSim set up is correct
% setupIK
% schemer_import('.\schemes\darksteel.prf');                                                                        % change theme to dark mode (not needed but I prefer it myself)

%% Move data from Visual3D structure to MOtoNMS friendly
Subjects = selectSubjects; 
Visual3DtoMotoNMS(Subjects)                                                                                     % use to move .c3ds automatically to the "InputFolder" 

%% Setup analysis 
Subjects = selectSubjects; 
sessions = selectSession(0);
selectedAnalysis = selectAnalysis;

%%
BatchAnalysis

%%
BatchPlotresults
checkEMGdata_simple (subject.directories.Input,bops.emg.Muscle,subject.trials.dynamicTrials)

Plot_Mean_CP


