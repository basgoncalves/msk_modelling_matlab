function associateFiles(action, userExtList, fileStr)
% associateFiles(action, extList, fileStr)
% Makes a registry files that can be used to set correct file associations on
% a windows platform. For supported extensions, see the list below.
%
% INPUT:
% action  - optional string,
%           '-add'       - (default) adds/rewrites the selected file 
%                          association registry entries.
%           '-delete'    - deletes all MATLAB file association registry
%                          entries (including "old style" ones).
%           '-deleteadd' - is the same as 'delete' followed by 'add'
% extList - optional string or cell array of strings containing the file
%           extensions that should be associated with this version. Can
%           also be a string,
%           '-installed' - (default) associate files for all installed 
%                           products.
%           '-all'       - associate all file types, also file types for 
%                          products that are not installed.
% fileStr - optional string with the name of the registry file to be written
%           (possibly including path). Default is the file
%           'MatlabFileAssocFix.reg' in the current directory.
%
% USAGE:
% 1) In the MATLAB command window browse to the folder where this file is
%    located.
% 2) Run with desired options (see above). A registry file should have been
%    created.
% 3) Exit all running instances of MATLAB.
% 4) Make a backup copy of the windows registry if you need to restore the
%    changes, see https://support.microsoft.com/en-us/kb/322756
% 5) Double click on the created file (possibly need to enter a password) and
%    confirm.
% 6) Restart Windows (or explorer.exe).
% 7) The MATLAB files should now be associated with the MATLAB version that the
%    registry file was created in and e.g. m-files should be opened in an
%    already running instance of MATLAB.
%
% EXAMPLES:
% * associateFiles('-deleteadd') - Makes a registry files that deletes all
%   previous MATLAB file association registry keys and write new ones that
%   associates MATLAB files, for installed products, with the MATLAB version 
%   that the registry file was created in.
% * associateFiles('', {'.m', '.mat', '.fig'}, 'myFile') - Makes a
%   registry file "myFile.reg" that associates m-, mat- and fig-files with
%   the MATLAB version that the registry file was created in.
%
% NOTE:
% - Changes the default behaviour for DDE open action on .m files for newer
%   versions of MATLAB. Default is always open in a new editor instance,
%   now the .m file is opened in a new tab in the editor if an instance
%   already exist.
% - Not all defined DDE actions might be work for the used MATLAB
%   version.
% - Once created the registry file might be used across several machines
%   (provided the MATLAB installation on these is the same).
%
% SUPPORTED EXTENSIONS:
% MATLAB,
% .fig          - MATLAB Figure
% .m            - MATLAB Code
% .mat          - MATLAB Data
% .mexw64       - MATLAB MEX
% .mlapp        - MATLAB App
% .mlappinstall - MATLAB App Installer
% .mlpkginstall - MATLAB Support Package Installer
% .mlproj       - MATLAB Project Archive
% .mltbx        - MATLAB Toolbox
% .mlx          - MATLAB Live Script
% .p            - MATLAB P-code
% .prj          - MATLAB Project
% Grandfathered extensions (R2020a), kept for backward compatibility
% .mn           - MuPAD Notebook (no longer supported, converted to MATLAB
%                 Live Script on newer versions)
% .mexw32       - MATLAB MEX (32-bit no longer supported)
% .mlprj        - MATLAB Project (renamed .mlproj?)
%
% Simulink,
% .mldatx       - Simulink Scenario
% .mdl          - Simulink Model
% .mdlp         - Simulink Protected Model
% .req          - Simulink Requirements Link
% .sldd         - Simulink Data Dictionary
% .slddc        - Simulink Data Dictionary Cache
% .slmx         - Simulink Traceability File
% .slreqx       - Simulink Requirements Data
% .sltx         - Simulink Template
% .slx          - Simulink Model
% .slxc         - Simulink Cache
% .slxp         - Simulink Protected Model
%
% Simulink Coder/Real-Time Workshop,
% .rtw          - Simulink Coder Model
% .tlc          - Simulink Target Compiler File
% .tmf          - Simulink Template Makefile
%
% Stateflow,
% .sfx          - Stateflow Chart
% If Simulink Coder/Real-Time Workshop or Embedded Coder in installed also,
% .cdr          - Stateflow Coder File
%
% HDL Coder and Filter Design HDL Coder,
% .v            - Verilog Code
% .vhd          - VHDL Code
%
% Simscape,
% .ssc          - Simscape Model
%
% SimBiology,
% .sbproj       - SimBiology Project
%
% MATLAB Report Generator,
% .rpt          - MATLAB Report
%
% Symbolic Math Toolbox,
% Grandfathered MuPAD Notebook (replaced by MATLAB Live Script) extensions, 
% kept for backward compatibility
% .mu           - MuPAD Code
% .muphlp       - MuPAD Help
% .xvc          - MuPAD Graphics
% .xvz          - MuPAD Graphics
%
% Exentensions that optionally might be associated with MATLAB
% .ads          - Ada Specification File
% .adb          - Ada Body File
% .c            - C Source
% .cpp          - C++ Source
% .h            - C/C++ Header
% .mk           - Makefile
% Might be used if a "coder" toolbox is installed. These have to be given 
% explicitly in the "extList", se above. For example,
% associateFiles('', {'.ads', '.adb', '.c', '.cpp', '.h', '.mk'})
% associate all the files above with MATLAB.
%
% VERSION 2.12
%
% See also <a href="matlab:help createShortcuts">createShortcuts</a>
 
% Author Patrik Forssén, Karlstad University
%
% VERSION HISTORY
% Version 1.0 (11 Jun 2015)
% - First realase
%
% Version 2.0 (7 Oct 2020)
% - File type names updated.
% - Added support for .mlproj, .mlx, .sbproj, .sfx, .slmx, .slreqx, .slxc
%   files.
% - DDE action for .mdl updated
% - DDE actions for .mlapp, .mlappinstall, .mldatx, .mlpkginstall, .mltbx,
%   .sldd, .sltx added
% - Icons from DLL files used if present
% - Added "AppUserModelId" registry key used by later versions of MATLAB
% - Added DDE change to MATLAB for later versions. When a file is opened
%   in Explorer, whitout a running instance of MATLAB, the current
%   directory in MATLAB is changed to that of the file.
%
% Version 2.1 (19 Nov 2020)
% - Added support for .rtw, .tlc, .tmf .cdr, .prj, .rpt, .v and .vhd files
%   and optionally for .ads, .adb, .c, .cpp, .h, .mk files.
% - As default only files related to installed products are now associated
%   with MATLAB.
% - Waitbars added.
% - Uses string for "FriendlyTypeName" instead of matlab.exe resource if
%   no DLL for the file type.
% - Old MATLAB file association keys are now always deleted for files that are 
%   going to be associated with this version of MATLAB.   
% - Key deletion is not done now if the file type is not associated with
%   MATLAB and is not going to be.
%
% Version 2.11 (17 March 2021)
% - Bug fixed for '-delete' option
%
% Version 2.12 (18 March 2021)
% - Bug fixed for old style keys
% Defualt input
if (nargin < 1 || isempty(action))     , action      = '-add'      ; end
if (nargin < 2 || isempty(userExtList)), userExtList = '-installed'; end
if (nargin < 3)                        , fileStr     = ''          ; end
% Sanity check
if (ischar(action)), action = lower(strtrim(action)); end
if (~ischar(action) || (~strcmp(action, '-add') && ...
    ~strcmp(action, '-delete') && ~strcmp(action, '-deleteadd')))
  error('associateFiles:incorrectValue', ['The action to perform must ', ...
    'be a string ''-add'', ''-delete'' or ''-deleteadd''!'])
end
if (~ischar(userExtList) && ~iscell(userExtList))
  error('associateFiles:incorrectType', ['The file extension list must ', ...
    'be a string or a cell array of strings!'])
end
if (iscell(userExtList) && ~min(cellfun(@ischar, userExtList(:)')))
  error('associateFiles:incorrectType', ['The file extension list must ', ...
    'be a string or a cell array of strings!'])
end
if (~ischar(fileStr))
  error('associateFiles:incorrectType', ...
    'The file to write to must be a string!')
end
% Get installed products
try
  instProd = getFeatureName('-installed');
  instProd = instProd(:, 2);
catch
  disp('WARNING! Failed to get installed products')
  instProd = {};
end
% Get mode for addition of file extensions
% 0 = none
% 1 = for all extensions
% 2 = extensions for installed products
% 3 = user defined
userExtList = lower(strtrim(userExtList(:)'));
if (ischar(userExtList)), userExtList = {userExtList}; end
if (numel(userExtList) == 1)
  modeStr = userExtList{1};
  if (isempty(modeStr)), modeStr = '-installed'; end
  switch modeStr
    case '-all'
      addMode     = 1;
      userExtList = {};
    case '-installed'
      addMode     = 2;
      if (isempty(instProd))
        % Safeguard, use all products
        addMode   = 1;
      end
      userExtList = {};
    otherwise
      % User defined
      addMode     = 3;
  end
else
  % User defined
  addMode = 3;
end
if (strcmp(action, '-delete'))
  % Do not add any associations
  addMode = 0;
end
 
% Get the currently running MATLAB version
verStr = regexp(version, '(\d*?\.\d*?\.\d*?)\.', 'tokens');
verStr = verStr{1}{1};
verNum = str2double(regexprep(verStr, '(\d*?\.\d*)[\x0000-\xffff]*', '$1'));
verHex = sprintf('%04x', str2double(regexprep(verStr, ...
  '(\d*?)\.[\x0000-\xffff]*', '$1')), str2double(regexprep(verStr, ...
  '\d*?\.(\d*?)\.[\x0000-\xffff]*', '$1')));
% Release
relStr = ['R', version('-release')];
 
% Get 32/64-bit
arch = computer;
switch arch
  case 'PCWIN'
    binFolder = 'win32';  % Older versions!
  case 'PCWIN64'
    binFolder = 'win64';
  otherwise
    error('Sorry, only windows platform supported!')
end
binPath = fullfile(matlabroot, 'bin', binFolder);
% DLL plugins present?
dllPath = fullfile(binPath, 'osintegplugins', 'osintegplugins');
if (~exist(dllPath, 'dir'))
  dllPath = [];
end
 
 
% Known files with possible DDE actions
% MATLAB
mExtCell = {...
  'fig'         , 'MATLAB Figure'                   , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'm'           , 'MATLAB Code'                     , ...
  {'Open', 'uiopen(''%1'',1)'}      , {'Run', 'run(''%1'')'}; ...
  'mat'         , 'MATLAB Data'                     , ...
  {'Load', 'load(''%1'')'}          , {'Open', 'uiimport(''%1'')'}; ...
  'mexw64'      , 'MATLAB MEX'                      , ...
  []                                , []; ...
  'mlapp'       , 'MATLAB App'                      , ...
  {'Edit', 'uiopen(''%1'',1)'}      , {'Open', 'run(''%1'')'}; ...
  'mlappinstall', 'MATLAB App Installer'            , ...
  {'Install', 'uiopen(''%1'',1)'}   , []; ...
  'mlpkginstall', 'MATLAB Support Package Installer', ...
  {'Install', 'uiopen(''%1'',1)'} , {'Open', 'uiopen(''%1'',1)'}; ...
  'mlproj'      , 'MATLAB Project Archive'          , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'mltbx'       , 'MATLAB Toolbox'                  , ...
  {'Install', 'uiopen(''%1'',1)'}   , []; ...
  'mlx'         , 'MATLAB Live Script'              , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'mn'          , 'MuPAD Notebook'                  , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'p'           , 'MATLAB P-code'                   , ...
  []                                , []; ...
  'prj'         , 'MATLAB Project'                  , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'mexw32'      , 'MATLAB MEX'                      , ...
  []                                , []; ...
  'mlprj'       , 'MATLAB Project'                  , ...
  []                                , []};
% Simulink
slExtCell = {...
  'mldatx'      , 'Simulink Scenario'               , ...
  {'Open', 'uiopen(''%1'',1)'}      , ...
  {'Run' , 'matlabshared.mldatx.internal.run(''%1'')'}; ...
  'mdl'         , 'Simulink Model'                  , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'mdlp'        , 'Simulink Protected Model'        , ...
  []                                , []; ...
  'req'         , 'Simulink Requirements Link'      , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'sldd'        , 'Simulink Data Dictionary'        , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'slddc'       , 'Simulink Data Dictionary Cache'  , ...
  []                                , []; ...
  'slmx'        , 'Simulink Traceability File'      , ...
  []                                , []; ...
  'slreqx'      , 'Simulink Requirements File'      , ...
  []                                , []; ...
  'sltx'        , 'Simulink Template'               , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'slx'         , 'Simulink Model'                  , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'slxc'        , 'Simulink Cache'                  , ...
  []                                , []; ...
  'slxp'        , 'Simulink Protected Model'        , ...
  []                                , []};
% Simulink Coder
slcExtCell = {...
  'rtw'         , 'Simulink Coder Model'            , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'tlc'         , 'Simulink Target Compiler File'   , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'tmf'         , 'Simulink Template Makefile'      , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Stateflow
sfExtList  = {...
  'sfx'         , 'Stateflow Chart'                 , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Stateflow + coder
sfcExtList = {...
  'cdr'         , 'Stateflow Coder File'            , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Filter Design HDL Coder
fdExtList  = {...
  'v'           , 'Verilog Code'                    , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'vhd'         , 'VHDL Code'                       , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Simscape
ssExtList  = {...
  'ssc'         , 'Simscape Model'                  , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% SimBiology
sbExtList  = {...
  'sbproj'      , 'SimBiology Project'              , ...
  {'Open', 'simbiology(''%1'')'}    , []};
% MATLAB Report Generator
rpExtList  = {...
  'rpt'         , 'MATLAB Report'                   , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Symbolic Math Toolbox, grandfathered extensions (R2020a)
symExtList = {...
  'mu'          , 'MuPAD Code'                      , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'muphlp'      , 'MuPAD Help'                      , ...
  {'Open', 'doc(symengine, ''%1'')'}, []; ...
  'xvc'         , 'MuPAD Graphics'                  , ...
  {'Open', 'mupad(''%1'')'}         , []; ...
  'xvz'         , 'MuPAD Graphics'                  , ...
  {'Open', 'mupad(''%1'')'}         , []};
% Optional files
optExtList = {...
  'ads'         , 'Ada Specification File'          , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'adb'         , 'Ada Body File'                   , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'c'           , 'C Source'                        , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'cpp'         , 'C++ Source'                      , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'h'           , 'C/C++ Header'                    , ...
  {'Open', 'uiopen(''%1'',1)'}      , []; ...
  'mk'          , 'Makefile'                        , ...
  {'Open', 'uiopen(''%1'',1)'}      , []};
% Merge lists
switch addMode
  case 0
    % Do not add any extensions
    addExtList = cell(0, 4);
    % Delete all extensions associated with MATLAB
    delExtList = [mExtCell; slExtCell; slcExtCell; sfExtList; sfcExtList; ...
      fdExtList; ssExtList; sbExtList; rpExtList; symExtList; optExtList];
    
  case 2
    % Only for installed products
    addExtList = mExtCell;
    if (ismember('SIMULINK', instProd))
      addExtList = [addExtList; slExtCell];
    end
    if (ismember('Real-Time_Workshop', instProd))
      addExtList = [addExtList; slcExtCell];
    end
    if (ismember('Stateflow', instProd))
      addExtList = [addExtList; sfExtList];
      if (ismember('Real-Time_Workshop', instProd) || ...
          ismember('RTW_Embedded_Coder', instProd))
        addExtList = [addExtList; sfcExtList];
      end
    end
    if (ismember('Simulink_HDL_Coder', instProd) || ...
        ismember('Filter_Design_HDL_Coder', instProd))
      addExtList = [addExtList; fdExtList];
    end
    if (ismember('Simscape', instProd))
      addExtList = [addExtList; ssExtList];
    end
    if (ismember('SimBiology', instProd))
      addExtList = [addExtList; sbExtList];
    end
    if (ismember('MATLAB_Report_Gen', instProd))
      addExtList = [addExtList; rpExtList];
    end
    if (ismember('Symbolic_Toolbox', instProd))
      addExtList = [addExtList; symExtList];
    end
  
  case {1, 3}
    % For all products or user defined extensions
    addExtList = mExtCell;
    addExtList = [addExtList; slExtCell; slcExtCell; sfExtList; sfcExtList; ...
      fdExtList; ssExtList; sbExtList; rpExtList; symExtList];
    if (addMode == 3)
      % User defined extensions, include optional extensions
      addExtList = [addExtList; optExtList];
      % Trim
      addExtList = addExtList(ismember(addExtList(:, 1), ...
        regexprep(userExtList, '\.', '')), :);
    end
end
switch action
  case '-add'
    % Only delete for files that are going to be associated
    delExtList = addExtList(:, 1);
  case {'-deleteadd', '-delete'}
    % Delete for all extensions associated with MATLAB or extensions for files
    % that are going to be associated
    delExtList = [mExtCell; slExtCell; slcExtCell; sfExtList; sfcExtList; ...
      fdExtList; ssExtList; sbExtList; rpExtList; symExtList; optExtList];
    delExtList = delExtList(:, 1);
end
% Make registry file
if (~isempty(fileStr))
  % Possibly add/change file extension
  [filePath, fileName] = fileparts(fileStr);
  fileStr = fullfile(filePath, [fileName, '.reg']);
  fid     = fopen(fileStr, 'w');
else
  fid     = fopen('MatlabFileAssocFix.reg', 'w');
end
if (fid == -1)
  error('associateFiles:openFile', 'Failed to create registry file!')
end
% Write initial lines
fprintf(fid, '%s\r\n\r\n', 'Windows Registry Editor Version 5.00');
fprintf(fid, '%s\r\n\r\n', ';FIXES MATLAB FILE ASSOCIATIONS');
 
 
% REMOVE OLD KEYS
explorerKey = ['HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\', ...
  'CurrentVersion\Explorer\FileExts'];
% Iterate over file extensions
oldMex = false;
h      = waitbar(0, 'Writing Deletion Keys...');
for fileExtNo = 1 : size(delExtList, 1)
  waitbar(fileExtNo/size(delExtList, 1), h)
  fileExt  = delExtList{fileExtNo};
  rmKey    = false;
  oldStyle = false;
  
  % File extension definition keys
  defKey   = '';
  specLink = '';
  [status, ~] = dos(['reg query HKEY_CLASSES_ROOT /f .', fileExt, ...
    ' /k /e']);
  if (~status)
    % The defintion key exist
    tmpKey = ['HKEY_CLASSES_ROOT\.', fileExt];
    % Check specification link
    [status, result] = dos(['reg query ', tmpKey, ' /ve']);
    if (~status)
      specLink = regexp(strtrim(result), ['[\x0000-\xffff]*?\(Default\)', ...
        '[ ]+[\x0021-\xffff]*?[ ]+([\x0000-\xffff]*)'], 'tokens');
      if (~isempty(specLink))
        specLink = specLink{1}{1};
      else
        specLink = '';
      end
    end
    % Check old style
    [status, ~] = dos(['reg query HKEY_CLASSES_ROOT\.', fileExt, ...
      '\OpenWithList /f matlab.exe /k /e']);
    if (~status), oldStyle = true; end
    if (~ismember(fileExt, addExtList(:, 1)))
      % Only delete if file is associated with MATLAB 
      if (~isempty(specLink) && ~isempty(strfind(upper(specLink), 'MATLAB')))
        % New style associated with MATLAB
        defKey = tmpKey;
        rmKey  = true;
      elseif (oldStyle)
        % Old style associated with MATLAB
        defKey = tmpKey;
        rmKey  = true;
      end
    else
      % Always delete (will be rewritten)
      defKey   = tmpKey;
      rmKey    = true;
    end
  end
  
  % Delete old style specification key without version numbers
  oldSpecKey = '';
  if (oldStyle)
    fileExtTmp = fileExt;
    if ((strcmpi(fileExt, 'mexw64') || strcmpi(fileExt, 'mexw32')) && ~oldMex)
      % Uses single DDE key for mex files
      fileExtTmp = 'mex';
      oldMex     = true;
    end
    [status, ~] = dos(['reg query HKEY_CLASSES_ROOT /f ', ...
      fileExtTmp, 'file /k /e']);
    if (~status)
      % Old specification key exist
      oldSpecKey = ['HKEY_CLASSES_ROOT\', fileExtTmp, 'file'];
      rmKey      = true;
    end
  end
  
  % New style keys with version number, remove keys related to ALL version
  newSpecKey = '';
  [status, result] = dos(['reg query HKEY_CLASSES_ROOT /f MATLAB.', ...
    fileExt, '. /k']);
  if (~status)
    newSpecKey = regexp(result, '(HKEY_CLASSES_ROOT[\x0000-\xffff]*?)\n', ...
      'tokens');
    rmKey      = true;
  end
  
  % Explorer key, only remove if file is associated with MATLAB
  exKey = '';
  if (~isempty(defKey))
    [status, ~] = dos(['reg query ', explorerKey, ' /f .', fileExt, ...
      ' /k /e']);
    if (~status)
      exKey = [explorerKey, '\.', fileExt];
    end
  end
  
  % Write to file
  if (rmKey)
    fprintf(fid, '%s\r\n\r\n', [';REMOVES ', upper(fileExt), ...
      ' FILE ASSOCIATIONS']);
    if (~isempty(defKey))
      fprintf(fid, '%s\r\n\r\n', ['[-', defKey, ']']);
    end
    if (~isempty(oldSpecKey))
      fprintf(fid, '%s\r\n\r\n', ['[-', oldSpecKey, ']']);
    end
    if (~isempty(newSpecKey))
      for keyNo = 1 : length(newSpecKey)
        key = newSpecKey{keyNo}{1};
        fprintf(fid, '%s\r\n\r\n', ['[-', key, ']']);
      end
    end
    if (~isempty(exKey))
      fprintf(fid, '%s\r\n\r\n', ['[-', exKey, ']']);
    end
  end
end
delete(h)
 
 
% ADD KEYS
if (~strcmpi(action, 'delete'))
  % Get text Persistent Handler
  [status, result] = dos(...
    'reg query HKEY_CLASSES_ROOT\.txt\PersistentHandler /ve');
  if (~status)
    PersistentHandler = regexp(result, '\{[\x0000-\xffff]*?\}', 'match');
    PersistentHandler = PersistentHandler{1};
  else
    PersistentHandler = '';
  end
  % DDE call
  ddeCall = 'ShellVerbs.Matlab';
  if (verNum > 8)
    % Changed from R2013a
    ddeCall = [ddeCall, '.', verStr];
  end
  % DDE change directory string
  if (verNum >= 9.8)
    % Changes MATLAB directory to the files ones when DDE action is applied
    % without a running MATLAB instance. Don't know the version when this
    % was changed, but at least from release 2020a.
    ddeDirStr = [' -r  \"eval(''[WinReg_path,WinReg_name,WinReg_ext]=', ...
      'fileparts(''''%1'''');cd(WinReg_path);clear WinReg_path ', ...
      'WinReg_name WinReg_ext'');\""'];
  else
    ddeDirStr = '"';
  end
  % Path with \\
  binPathStr = regexprep(binPath, '\\', '\\\\');
  % Default icon
  defIconStr  = [];
  defIconFile = fullfile(binPath, 'm.ico');
  if (exist(defIconFile, 'file'))
    defIconStr = ['"', binPathStr, 'm.ico,0"'];
  end
  if (~isempty(dllPath))
    defIconDLL = fullfile(dllPath, 'm', 'mwmfaplugin.dll');
    if (exist(defIconDLL, 'file'))
      defIconStr = ['"\"', regexprep(defIconDLL, '\\', '\\\\'), '\",0"'];
    end
  end
  % Default icon for .mex32
  defMex32IconStr  = [];
  defMex32IconFile = fullfile(binPath, 'mexw32.ico');
  if (~exist(defMex32IconFile, 'file'))
    % Use same as for mexw64 if it exist
    mex64IconFile = fullfile(binPath, 'mexw64.ico');
    if (exist(mex64IconFile, 'file'))
      defMex32IconStr = ['"', binPathStr, 'mexw64.ico,0"'];
    end
  end
  if (~isempty(dllPath))
    defMex32DLL = fullfile(dllPath, 'mexw32', 'mwmexw32faplugin.dll');
    if (~exist(defMex32DLL, 'file'))
      % Use same as for mexw64 if it exist
      mex64DLL = fullfile(dllPath, 'mexw64', 'mwmexw64faplugin.dll');
      if (exist(mex64DLL, 'file'))
        defMex32IconStr = ['"\"', regexprep(mex64DLL, '\\', '\\\\'), '\",0"'];
      end
    end
  end
  
  % Key for newer version
  appUserModelId = ['"Mathworks.MATLAB.MATLAB.', relStr, '"'];
  
  % Write Shell Open key
  key = ['[HKEY_CLASSES_ROOT\Applications\MATLAB.exe\shell\open', ...
    '\command]%r', '@="\"', binPathStr, '\\MATLAB.exe\" \"%1\""%r%r'];
  fprintf(fid, '%s\r\n\r\n', ';ADD SHELL OPEN');
  lines = regexp(key, '([\x0000-\xffff]*?)%r', 'tokens');
  for lineNo = 1 : length(lines)
    fprintf(fid, '%s\r\n', lines{lineNo}{1});
  end
  
  % Iterate over file types
  h = waitbar(0, 'Writing Addition Keys...');
  for fileExtNo = 1 : size(addExtList, 1)
    waitbar(fileExtNo/size(addExtList, 1), h)
    ddeData = addExtList(fileExtNo, :);
    fileExt = ddeData{1};
    
    % File extension keys
    key  = ['[HKEY_CLASSES_ROOT\.', fileExt, ']%r@="MATLAB.', ...
      fileExt, '.', verStr, '"%r'];
    if (strcmpi(fileExt, 'm') && ~isempty(PersistentHandler))
      % Add some values
      key = [key, '"Content Type"="text/plain"%r', ...
        '"PerceivedType"="Text"%r'];
    end
    key = [key, '%r'];
    % Not present on newer versions
    key = [key, '[HKEY_CLASSES_ROOT\.', fileExt, ...
      '\OpenWithProgids]%r"MATLAB.', fileExt, '.', verStr, '"=""%r%r'];
    if (strcmpi(fileExt, 'm') && ~isempty(PersistentHandler))
      key = [key, '[HKEY_CLASSES_ROOT\.', fileExt, ...
        '\PersistentHandler]%r@="', PersistentHandler, '"%r%r'];
    end
    % Not present on newer versions
    key = [key, '[HKEY_CLASSES_ROOT\.', fileExt, ...
      '\Versions\MATLAB.', fileExt, '.' verStr, ...
      ']%r"FileVersionMS"=dword:', verHex, ...
      '%r"FileVersionLS"=dword:00000000%r%r'];
    
    % DDE keys
    key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
      ']%r@="', ddeData{2}, '"%r'];
    dllFlag = 0;
    if (~isempty(dllPath))
      currDLL = fullfile(dllPath, fileExt, ['mw', fileExt, 'faplugin.dll']);
      if (exist(currDLL, 'file')), dllFlag = 1; end
    end
    if (~dllFlag)
      % Older style or no DLL, use string NOT matlab.exe resource!
      key = [key, '"FriendlyTypeName"="', ddeData{2}, '"%r'];
    else
      % New DLL resource style
      key = [key, '"FriendlyTypeName"="@', ...
        regexprep(currDLL, '\\', '\\\\'), ',0"%r'];
    end
    % Only present on newer version and when we have DDE action
    if (~isempty(ddeData{3}))
      key = [key, '"AppUserModelId"=', appUserModelId, '%r'];
    end
    key = [key, '%r'];
    
    % Icon
    if (~dllFlag)
      icon = fileExt;
      if (~exist(fullfile(binPath, [icon, '.ico']), 'file'))
        if (strcmpi(fileExt, 'mexw32') && ~isempty(defMex32IconStr))
          % Special case for mex32
          key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.', verStr, ...
            '\DefaultIcon]%r'];
          key = [key, '@=', defMex32IconStr, '%r%r'];
        elseif (~isempty(defIconStr))
          key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.', verStr, ...
            '\DefaultIcon]%r'];
          key = [key, '@=', defIconStr, '%r%r'];
        end
      else
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.', verStr, ...
          '\DefaultIcon]%r'];
        key = [key, '@="', binPathStr, '\\', icon, '.ico,0"%r%r'];
      end
    else
      key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.', verStr, ...
        '\DefaultIcon]%r'];
      key = [key, '@="\"', regexprep(currDLL, '\\', '\\\\'), '\",0"%r%r'];
    end
    % Shell actions
    for shellActionNo = 3:4
      ddePar = ddeData{shellActionNo};
      if (~isempty(ddePar))
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
          '\Shell\', ddePar{1}, ']%r@="', ddePar{1}, '"%r%r'];
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
          '\Shell\', ddePar{1}, '\command]%r@="\"', binPathStr, ...
          '\\matlab.exe\"', ddeDirStr, '%r%r'];
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
          '\Shell\', ddePar{1}, '\ddeexec]%r@="', ddePar{2}, '"%r%r'];
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
          '\Shell\', ddePar{1},'\ddeexec\application]%r@="', ...
          ddeCall, '"%r%r'];
        key = [key, '[HKEY_CLASSES_ROOT\MATLAB.', fileExt, '.' verStr, ...
          '\Shell\', ddePar{1},'\ddeexec\topic]%r@="system"%r%r'];
      end
    end
    
    % Explorer keys, not set on newer version of the installer...
    key = [key, '[', explorerKey, '\.', fileExt, '\OpenWithProgids]%r'];
    if (strcmpi(fileExt, 'm'))
      key = [key, '"m_auto_file"=hex(0):%r'];
    end
    key = [key, '"MATLAB.', fileExt, '.',  verStr, '"=hex(0):%r%r'];
    if (~isempty(ddeData{3}))
      % Add key
      key = [key, '[', explorerKey, '\.', fileExt, ...
        '\OpenWithList]%r"a"="MATLAB.exe"%r"MRUList"="a"%r%r'];
    else
      key = [key, '[', explorerKey, '\.', fileExt, '\OpenWithList]%r%r'];
    end
    
    % Write to file
    fprintf(fid, '%s\r\n\r\n', [';ADD ', upper(fileExt), ...
      ' FILE ASSOCIATIONS']);
    lines = regexp(key, '([\x0000-\xffff]*?)%r', 'tokens');
    for lineNo = 1 : length(lines)
      fprintf(fid, '%s\r\n', lines{lineNo}{1});
    end
  end
  delete(h)
end
 
% Close file
status = fclose(fid);
if (status == -1)
  warning('associateFiles:closeFile', 'Failed to close registry file')
end
 
end
function OUT = getFeatureName(fullname)
% getFeatureName - translates a toolbox name from 'ver' into
% a feature name and vice versa, also checks license availability
%
% Syntax:
%   getFeatureName(fullname)
%
% Inputs:
%   fullname:       character vector of toolbox name as listed in ver
%                   output (optional, if none given all features are
%                   listed)
%
% Outputs:
%   translation:    cell array with clear name, feature name and license
%                   availability
%
%-------------------------------------------------------------------------
% Version 1.1
% 2018.09.04        Julian Hapke
% 2020.05.05        checks all features known to current release
%-------------------------------------------------------------------------
assert(nargin < 2, 'Too many input arguments')
% defaults
checkAll = true;
installedOnly = false;
if nargin
  checkAll = false;
  installedOnly = strcmp(fullname, '-installed');
end
if checkAll || installedOnly
  allToolboxes = com.mathworks.product.util.ProductIdentifier.values;
  nToolboxes = numel(allToolboxes);
  out = cell(nToolboxes, 3);
  for iToolbox = 1:nToolboxes
    marketingName = char(allToolboxes(iToolbox).getName());
    flexName = char(allToolboxes(iToolbox).getFlexName());
    out{iToolbox, 1} = marketingName;
    out{iToolbox, 2} = flexName;
    out{iToolbox, 3} = license('test', flexName);
  end
  if installedOnly
    installedToolboxes = ver;
    installedToolboxes = {installedToolboxes.Name}';
    out = out(ismember(out(:,1), installedToolboxes),:);
  end
  if nargout
    OUT = out;
  else
    out = [{'Name', 'FlexLM Name', 'License Available'}; out];
    disp(out)
  end
else
  productidentifier = com.mathworks.product.util.ProductIdentifier.get(fullname);
  if (isempty(productidentifier))
    warning('"%s" not found.', fullname)
    OUT = cell(1,3);
    return
  end
  feature = char(productidentifier.getFlexName());
  OUT = [{char(productidentifier.getName())} {feature} {license('test', feature)}];
end
end