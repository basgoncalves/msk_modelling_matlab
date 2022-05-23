D% Ricardo Mesquita 
% MainDemuse 

close all; clear; clc;
path = fileparts (matlab.desktop.editor.getActiveFilename); % path of the current script
addpath(genpath(path));
cd(path)

Files  = uigetmultiple('','Select all the mat files to run analysis');

for ii = 1:length(Files) 
    
   FrequencySpikes_Demuse(Files{ii},5); %run the function for polynomials

end

