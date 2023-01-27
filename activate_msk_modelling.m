
% by Basilio Goncalves, basilio.goncalves7@gmail.com, https://github.com/basgoncalves
function activate_msk_modelling
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)

try
    isbopsactive;    % check if the pipeline is in the path 
catch

    activeFile = [mfilename('fullpath') '.m'];                                                                          % get dir of the current file
    msk_dir  = fileparts(activeFile);
    addpath(genpath(msk_dir));                                                                                          % add current folder to MATLAB path

    disp([msk_dir ' activated'])

    bops = load_setup_bops;

    DirOpenSim = ['C:' fp 'OpenSim ' num2str(bops.osimVersion) fp 'Resources\Code\Matlab'];
    addpath(genpath(DirOpenSim));

    disp([DirOpenSim ' activated'])
end