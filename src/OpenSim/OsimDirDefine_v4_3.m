% Assign directories of Matlab scripts and OpenSim instalation files
%
% Windows 10 search for "Advanced system settings" -> Environment Variables
% Under  "System Variables" -> edit "Path" -> add OPENSIM_INSTALL_DIR and  OPENSIM_INSTALL_DIR/bin - https://www.java.com/en/download/help/path.xml
%
% MANUAL EDITING
%   https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab
%   pathtool
%   edit(fullfile(prefdir, 'javaclasspath.txt'))
%   add  C:\OpenSim 3.3\sdk\Java\org-opensim-modeling.jar
%   edit(fullfile(prefdir, 'javalibrarypath.txt'))
%   add C:\OpenSim 3.3\bin (or equivalent)
% 
%   Basilio Goncalves (2020)
%   https://www.researchgate.net/profile/Basilio_Goncalves
%-------------------------------------------------------------------------

%% OsimDirDefine_v4_3
originalDir = cd;
DirOpenSimMatlab='C:\OpenSim 4.3\Code\Matlab';
addpath(genpath(fileparts(fileparts(DirOpenSimMatlab))));
cd(DirOpenSimMatlab)
import org.opensim.modeling.*
if ~exist('org.opensim.modeling.Model')
    warning on
    warning ([sprintf('OpensSim 4.3 is not configured \n '), ...
        sprintf('OpenSim API will not run \n '),...
        sprintf('please see how to install OpenSim here \n '),...
        sprintf('https://simtk-confluence.stanford.edu:8443/display/OpenSim/Scripting+with+Matlab \n '),...
        sprintf('For configuration follow the steps (example for openSim 3.3): \n '),...
        sprintf(' \n'),...
        sprintf('1. edit(fullfile(prefdir, ''javaclasspath.txt'')) \n'),...
        sprintf('   add  "C:\\OpenSim 4.3\\sdk\\Java\\org-opensim-modeling.jar" \n'),...
        sprintf('2. edit(fullfile(prefdir, ''javalibrarypath.txt'')) \n '),...
        sprintf('   add "C:\\OpenSim 4.3\\bin" (or equivalent) \n '),...
        sprintf('3. go to "C:\\OpenSim 4.3\\Code\\Matlab" \n '),...
        sprintf('   run "configureOpenSim.m" (MATLAB may need to be started in admin mode) \n ')])
    
    edit(fullfile(prefdir, 'javaclasspath.txt'))
    edit(fullfile(prefdir, 'javalibrarypath.txt'))
else
    disp('OpenSim setup complete')
    cd(originalDir)
end




