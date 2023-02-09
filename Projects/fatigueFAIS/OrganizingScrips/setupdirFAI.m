function setupdirFAI

disp('Setup FAI directories...')

MasterDir = MasterSetup;

bops = setupbopstool;

path_dataDir    = [MasterDir fp 'Projects\fatigueFAIS\data_directory.dat'];
dataDir         = char(importdata(path_dataDir));
if ~contains(dataDir,bops.directories.mainData)
    dataDir = bops.directories.mainData;
    writematrix(dataDir,path_dataDir)
end

if ~isfolder([bops.directories.InputData])
    cmdmsg([bops.directories.InputData ' does not exist,check data folder name or update "getdirFAI.m" ']);         % check if the folder and sessions exist
end

