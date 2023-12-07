
% by Basilio Goncalves, basilio.goncalves7@gmail.com, https://github.com/basgoncalves
function activate_msk_modelling()
clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)

activeFile = [mfilename('fullpath') '.m'];                                                                          % get dir of the current file
msk_dir  = fileparts(activeFile);


try
    isbopsactive;    % check if the pipeline is in the path
    addpath(genpath([msk_dir fp 'src' fp 'OpenSim']));
    cd(msk_dir)
    disp([msk_dir ' is already in the path'])
catch

    addpath(genpath(msk_dir));                                                                                          % add current folder to MATLAB path
    disp([msk_dir ' activated'])
    
    bops = load_setup_bops;
    
    DirOpenSim = ['C:' fp 'OpenSim ' num2str(bops.osimVersion) fp 'Resources\Code\Matlab'];
    addpath(genpath(DirOpenSim));

    cd(msk_dir)
    disp([DirOpenSim ' activated'])

end

