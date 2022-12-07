
% by Basilio Goncalves, basilio.goncalves7@gmail.com, https://github.com/basgoncalves
function activate_msk_modelling
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)
activeFile = [mfilename('fullpath') '.m'];                                                                          % get dir of the current file
msk_dir  = fileparts(activeFile);                                                                          
addpath(genpath(msk_dir));                                                                                          % add current folder to MATLAB path

disp([msk_dir ' activated'])
