
function MasterDir=MasterSetup

fp = filesep;
tmp = matlab.desktop.editor.getActive;pwd=fileparts(tmp.Filename);cd(pwd)
CD='';while ~contains(CD,'MSKmodelling'); [pwd,CD]=fileparts(pwd);end
MasterDir = [pwd fp 'MSKmodelling'];

if ~any(strcmp(split(path,';'),MasterDir))
    addpath(genpath(MasterDir));
    cmdmsg(['MasterDir: ' MasterDir]);
end