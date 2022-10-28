
% by Basilio Goncalves, basilio.goncalves7@gmail.com, https://github.com/basgoncalves
function activate_msk_modelling
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
bopsdir  = fileparts(activeFile.Filename);                                                                          
addpath(genpath(bopsdir));                                                                                          % add current folder to MATLAB path
