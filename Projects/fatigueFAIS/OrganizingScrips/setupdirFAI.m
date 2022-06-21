function setupdirFAI

MasterDir = MasterSetup;
path_dataDir    = [MasterDir fp 'Projects\fatigueFAIS\data_directory.dat'];
dataDir         = char(importdata(path_dataDir));
if exist(dataDir,'dir')
    answer = questdlg(sprintf('do you want to use data directory: "\n" %s',dataDir));
    
    if ~isfolder(dataDir) || isequal(answer,'No')                                                                       % check data folder
        dataDir = uigetdir(fileparts(dataDir));
        writematrix(dataDir,path_dataDir)
    end
    
elseif ~exist(dataDir,'dir')
    m = msgbox(sprintf('current directory does not exist: \n "%s" \n please select another one',dataDir));
    uiwait(m)
    dataDir = uigetdir(fileparts(dataDir));
    writematrix(dataDir,path_dataDir)
end

