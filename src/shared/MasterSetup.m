
function MasterDir=MasterSetup(Reset)

fp = filesep;
tmp = matlab.desktop.editor.getActive;pwd=fileparts(tmp.Filename);cd(pwd)
CD='';while ~contains(CD,'MSKmodelling'); [pwd,CD]=fileparts(pwd);end
MasterDir = [pwd fp 'MSKmodelling'];

if nargin < 1
   Reset = false; 
end

if ~any(strcmp(split(path,';'),MasterDir)) || Reset == 1
    addpath(genpath(MasterDir));
    cmdmsg(['MasterDir: ' MasterDir]);
end