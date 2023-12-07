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

% credit Basilio Goncalves (2020) https://www.researchgate.net/profile/Basilio_Goncalves
%-------------------------------------------------------------------------

%% OsimDirDefine
function OsimDirDefine(CheckOsimVersion)
fp = filesep;
originalDir = cd;
bops = load_setup_bops;
osimVersionBops = num2str(bops.osimVersion);

if nargin < 1
    CheckOsimVersion = 0;
end

if CheckOsimVersion==0
    answer = questdlg(['Do you want to use the current OpenSim version: ' osimVersionBops]);
else
    answer = 'Yes';
end

if contains(answer,'No')
    selectOsimVersion
end

DirOpenSim = ['C:' fp 'OpenSim ' osimVersionBops];

DirOpenSimMatlab = '';
checkOSimVersion(osimVersionBops)

% NewPath = [getenv('PATH') [DirOpenSim fp 'bin' fp]];
% setenv('PATH', NewPath);

addpath(genpath(DirOpenSimMatlab));

try cd(DirOpenSimMatlab); catch; end

import org.opensim.modeling.*
try installedOsimVersion = char(org.opensim.modeling.opensimCommon.GetVersion());
catch
    try org.opensim.modeling.Model;
        installedOsimVersion = '3.3';
    catch; installedOsimVersion = '000';
    end
end

changeTxt(fullfile(prefdir, 'javaclasspath.txt'),[DirOpenSim fp 'sdk\Java\org-opensim-modeling.jar']);
changeTxt(fullfile(prefdir, 'javalibrarypath.txt'),[DirOpenSim fp 'bin']);

if ~contains(installedOsimVersion(1:3),osimVersionBops)
    
    if checkAdminOn == 0
        msg = msgbox(['Trying to configure OpenSim ' osimVersionBops '. Please run Matlab in Admin mode']);
        uiwait(msg)
        error('OpenSim not configured, please restar matlab in admin mode and run "OsimDirDefine.m" ')
    else
        msg = msgbox(['Configuring OpenSim ' osimVersionBops '...']);
        uiwait(msg)
    end
    configureOpenSim
    addpath(genpath(DirUp(bops.directories.bops,3)));
    
    msg = msgbox(['OpenSim ' osimVersionBops ' configured. Please add ' DirOpenSim fp 'bin to the System and Enviroment Path of Windows']);
    uiwait(msg)
    msg = msgbox(['Find instructions in ' fileparts(bops.directories.bops) fp 'OpenSim\Windows_Install_Guide']);
    uiwait(msg)
    winopen([fileparts(bops.directories.bops) fp 'OpenSim\Windows_Install_Guide'])
    error(['OpenSim ' osimVersionBops ' has been configured but API will not work  util "' DirOpenSim fp 'bin" is added to the System and User Path of Windows' ])
    
elseif ~exist('org.opensim.modeling.Model')
    warning on
    warning ([sprintf('OpensSim %s is not configured \n ',osimVersionBops), ...
        sprintf('OpenSim API will not run \n '),...
        sprintf('please see how to install OpenSim here \n '),...
        sprintf('https://simtk-confluence.stanford.edu:8443/display/OpenSim/Scripting+with+Matlab \n '),...
        sprintf('For configuration follow the steps (example for openSim %s): \n ',osimVersionBops),...
        sprintf(' \n'),...
        sprintf('1. edit(fullfile(prefdir, ''javaclasspath.txt'')) \n'),...
        sprintf('   add  "C:\\OpenSim %s\\sdk\\Java\\org-opensim-modeling.jar" \n',osimVersionBops),...
        sprintf('2. edit(fullfile(prefdir, ''javalibrarypath.txt'')) \n '),...
        sprintf('   add "C:\\OpenSim %s\\bin" (or equivalent) \n ',osimVersionBops),...
        sprintf('3. go to "%s" \n ',DirOpenSimMatlab),...
        sprintf('   run "configureOpenSim.m" (MATLAB may need to be started in admin mode) \n ')])
    
    edit(fullfile(prefdir, 'javalibrarypath.txt'))
    edit(fullfile(prefdir, 'javaclasspath.txt'))
    
else
    disp(['OpenSim v' osimVersionBops ' setup complete'])
    cd(originalDir)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Change text in the java paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isNewText = changeTxt(path,txt)
        
        try
            original_txt = char(importdata(path));
        catch
            writematrix([],path);
            original_txt = char(importdata(path));
        end
        
        isNewText = zeros(1,size(original_txt,1));
        if length(isNewText) < 1
            isNewText = 1;
        else
            for i = 1:size(original_txt,1)
                if contains(original_txt(i,:),txt)
                    isNewText(i) = 0;
                else
                    isNewText(i) = 1;
                end
            end
        end
        isNewText = min(isNewText);
        
        if isNewText == 1
            writematrix(txt,path)
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Change text in the java paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isAdmin = checkAdminOn
        
        isAdmin = System.Security.Principal.WindowsPrincipal(...
            System.Security.Principal.WindowsIdentity.GetCurrent()).IsInRole(...
            System.Security.Principal.WindowsBuiltInRole.Administrator);
        
    end
    function checkOSimVersion(osimVersionBops)
        
        DirOpenSim = ['C:' fp 'OpenSim ' osimVersionBops];
        
        if contains(DirOpenSim,'OpenSim 3.')
            DirOpenSimMatlab = [DirOpenSim fp 'Scripts\Matlab'];
        elseif contains(DirOpenSim,'OpenSim 4.')
            DirOpenSimMatlab = [fileparts(userpath) fp 'OpenSim' fp osimVersionBops fp 'Code\Matlab'];
            
            if ~isfolder(DirOpenSimMatlab)
                msg = msgbox ('Matlab OpenSim folder not found! Please ensure there is a folder ''Resources\Code\Matlab'' add to OPENSIM_INSTALL_DIR');
                uiwait(msg)
                selectOsimVersion
            end
            
        end
        
    end
    function selectOsimVersion
        
        FilesInC = cellstr(ls(['C:' fp ]));
        OpenSimFolders = FilesInC(contains(FilesInC,'OpenSim'));
        
        InstalledVersions = (strrep(OpenSimFolders,'OpenSim ',''));
        msg = 'These OpenSim versions are currently installed in "C:/", please seletect one';
        
        [indx,~] = listdlg('PromptString',msg,'ListString',InstalledVersions);
        osimVersionBops = InstalledVersions{indx};
        
        bops.osimVersion = str2double(osimVersionBops);
        
        xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);
        
    end

end

