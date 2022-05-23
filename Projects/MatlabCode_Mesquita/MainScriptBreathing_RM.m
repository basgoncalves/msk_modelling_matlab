% Ricardo Mesquita 
% MainDemuse 

close all; clear; clc;

path = matlab.desktop.editor.getActiveFilename; % path of the current script
path = fileparts (path);
addpath(genpath(path));                  % add current folder and sub folders to path

Files  = uigetmultiple('','Select all the mat files to run analysis');
cd(fileparts(Files{1}))

for ii = 1:length(Files) 
    EMGdownsample = 1;                                         % 1 = downsample EMGrms data; 0 = upsample volume data
    FiringFrequencyPlot_Breathing(Files{ii},5,EMGdownsample);  % run the function for polynomials 
end


