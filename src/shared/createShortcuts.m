function createShortcuts(desktop, startMenu)
 
% createShortcuts(desktop, startMenu) 
% Adds missing shortcut to MATLAB on Windows desktop and/or a folder at the
% start menu with shortcuts to MATLAB and uninstallation of MATLAB. Tested
% for Windows 10 and MATLAB release 2020a.
%
% INPUT:
% desktop   - optional logic indicating if shortcuts should be added to the
%             Windows desktop. Default is true.
% startMenu - optional integer indicating if shortcuts should be added to
%             the Windows start menu.
%             0 - no shortcuts added
%             1 - shortcuts for current user added (default)
%             2 - shortcuts for all users added. Will raise an UAC warning
%                 as this requires administrator privileges. Will run in a
%                 separate console window.
%
% USAGE:
% 1) In the MATLAB command window browse to the folder where this file is 
%    located.
% 2) Run with desired options (see above)
%
% NOTE:
% - Preferably use the Windows Control panel to uninstall MATLAB. The uninstall
%   shortcut can be used if MATLAB is not found in the Control Panel (might 
%   happen if you uninstall MATLAB components). 
% - Uses the batch file "matlabshortcuts.bat" to create the shortcuts.
%   This program can also be run directly in a Windows console window. Type
%   matlabshortcuts /? there for help on how to supply the necessary
%   command line arguments. You might also supply the necessary parameter
%   directly in the file by editing it.
% - If you prefer to add shortcuts manually, or the program did not work,
%   you can do the following,
%   1. Type matlabroot in the MATLAB command window.
%   2. Go to the directory <matlabroot>\bin.
%   3. There should be a file "matlab.exe" there (if not look in
%      <matlabroot>\bin\win64 or <matlabroot>\bin\win32).
%   4. Right click on this file and select "Create shortcut". You will
%      probably be asked to place it on the desktop instead of in this
%      directory select Yes. If the shortcut was created in the directory
%      move it to the desktop.
%   5. You can rename the created shortcut if you like to.
%   6. If you would like to have a shortcut the uninstaller program 
%      "uninstall.exe" it can be found in,
%      <matlabroot>\uninstall\bin\win64 or <matlabroot>\uninstall\bin\win32
%      and you then do steps 4 and 5 above.
%   7. If you would like to have start menu items for the current user, the
%      created shortcuts can be copied/pasted in the start menu.
%
% VERSION 1.0
%
% See also <a href="matlab:help associateFiles">associateFiles</a>
 
% Author Patrik Forssén, Karlstad University
%
% VERSION HISTORY
% Version 1.0 (7 Oct 2020)
% - First release
 
% Default input
if (nargin < 1 || isempty(desktop))  , desktop   = true; end
if (nargin < 2 || isempty(startMenu)), startMenu = 1   ; end
 
% Sanity check
if ((~islogical(desktop) && ~isnumeric(desktop)) || ~isscalar(desktop) || ...
    ~isreal(desktop))
  error('createShortcuts:incorrectType', ['The desktop shortcut creation ', ...
    'flag must be a scalar logic (true/false)'])
else
  desktop = round(real(desktop)) ~= 0;
end
if (~isnumeric(startMenu) || ~isscalar(startMenu) || ~isreal(startMenu) || ...
    startMenu < 0 || startMenu > 2)
  error('createShortcuts:incorrectType', ['The start menu shortcut ', ...
    'creation flag must be 0, 1 or 2!'])
end
if (~desktop && startMenu==0), return, end
 
 
% MATLAB installation directory
instDir = ['"', matlabroot, '"'];
% Release
relStr  = ['R', version('-release')];
 
% Flags
flagStr = ' ';
switch startMenu
  case 1
    flagStr = [flagStr, '/S '];
  case 2
    flagStr = [flagStr, '/E /A '];
end
if (desktop)
  flagStr = [flagStr, '/R '];
end
flagStr = flagStr(1:end-1);
 
% Run string
runStr = ['matlabshortcuts ', relStr, ' ', instDir, flagStr];
 
% Info
if (startMenu == 2)
  disp(['Creation of start menu shortcuts for all users requires ', ...
    'administrator privileges!'])
  disp(['The program will therefor raise a UAC warning that you must ', ...
    'accept to continue.'])
  disp('Press any key to continue...')
  pause
end
 
% Run
[status, result] = dos(runStr, '-echo');
 
end