function  deactivate_msk_modelling

activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
msk_dir  = fileparts(activeFile.Filename);
rmpath(genpath(msk_dir));

disp(['"' msk_dir '" deactivated'])