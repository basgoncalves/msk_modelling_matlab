% Before running this pipeline check the following scripts and update
% directories, trial names and demographics
%   setupbopstool
%   getTrials
%   CEINMSsetup
%   ..\setuptools\bopsSetup.xml
% 
% MatlabAppearance_BG

% by Basilio Goncalves, basilio.goncalves7@gmail.com, https://github.com/basgoncalves
function mainbops
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
bopsdir  = fileparts(activeFile.Filename);                                                                          
addpath(genpath(bopsdir));                                                                                          % add current folder to MATLAB path
setupbopstool;                                                                                                      % add "DataProcessing_master" pipeline
OsimDirDefine                                                                                                       % check if OpenSim set up is correct

PipelineSteps = {'Convert Visual3D' 'Select subjects' 'Select Session' 'Select Analysis' ...
    'Setup InverseKinematics' 'Batch Analysis' 'Plot results'};
[OutValues,out] = BopsCheckbox(PipelineSteps,[],'Which elements of the pipeline do you want to edit?');             % Setup analysis 

if any(contains(out,'Convert Visual3D'));            Visual3DtoMotoNMS;  end
if any(contains(out,'Select subjects'));             selectSubjects;     end
if any(contains(out,'Select Session'));              selectSession(0);   end
if any(contains(out,'Select Analysis'));             selectAnalysis;     end
if any(contains(out,'Setup InverseKinematics'));     setupIK;            end

if any(contains(out,'Batch Analysis'));              BatchAnalysis;      end

if any(contains(out,'Plot results'));                BatchPlotresults;   end




