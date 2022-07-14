function setupdirFAI(UseCurrentSessitngs)

disp('Setup FAI directories...')
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

if ~isfolder([bops.directories.InputData])
    cmdmsg([bops.directories.InputData ' does not exist,check data folder name or update "getdirFAI.m" ']);         % check if the folder and sessions exist
end

