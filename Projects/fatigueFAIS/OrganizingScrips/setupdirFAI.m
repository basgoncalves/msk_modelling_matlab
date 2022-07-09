function setupdirFAI(UseCurrentSessitngs)

if nargin < 1
   UseCurrentSessitngs = 0; 
end

MasterDir = MasterSetup;

bops = setupbopstool(UseCurrentSessitngs);

path_dataDir    = [MasterDir fp 'Projects\fatigueFAIS\data_directory.dat'];
dataDir         = char(importdata(path_dataDir));
if ~contains(dataDir,bops.directories.mainData)
    dataDir = bops.directories.mainData;
    writematrix(dataDir,path_dataDir)
end

