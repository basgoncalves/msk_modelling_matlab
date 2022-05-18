% get directory of the funtion / script where this function is called
% (active directory)

function ad = getad


activeFile = matlab.desktop.editor.getActive;
ad  = fileparts(activeFile.Filename);