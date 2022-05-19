

function checkfilesExist(Dir,Temp,trialName,Analysis)

fp = filesep;



%  model
if ~exist(Dir.OSIM_LinearScaled)
    [modelFile,modelFilePath,~] = ...
        uigetfile(Dir.Elaborated,'*.osim','Choose the the scaled .osim model file to be used.');
    Dir.OSIM_LinearScaled = [modelFilePath modelFile];
end

% template IK
if ~exist(Temp.IKSetup)
    [filename,path] = uigetfile([fp '*.xml'],'Select template IK.xml file to load', pwd);
    Temp.IKSetup = [path filename];
end

% trc IK
if ~exist([Dir.dynamicElaborations fp trialName fp trialName '.trc'])
    [filename,path] = uigetfile([fp '*.xml'],'Select template IK.xml file to load', pwd);
    Temp.IKSetup = [path filename];
end