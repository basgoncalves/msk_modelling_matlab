function  deactivate_msk_modelling

% get dir of the current file
activeFile = matlab.desktop.editor.getActive;
msk_dir  = fileparts(activeFile.Filename);
rmpath(genpath(msk_dir));

disp(['"' msk_dir '" deactivated'])