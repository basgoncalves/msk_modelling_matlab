
function bops = load_setup_bops

setupDir    = fileparts(mfilename('fullpath'));
bopsDir     = fileparts(fileparts(setupDir));

dataDir = char(importdata([setupDir fp 'data_directory.dat']));

try cd(dataDir); catch; setupbopstool; end                                                                          % if data folder doesnt exist setup project again 

setupfileDir = [dataDir fp 'bopsSettings.xml'];

Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
try
    bops = xml_read(setupfileDir,Pref);                                                                             % load "setup.xml"
catch
    delete(setupfileDir);
    setupbopstool;
end

bops.directories.bops = bopsDir;
bops.directories.mainData = dataDir;
bops.directories.setupbopsXML = setupfileDir;

try bops.subjects = cellstr(bops.subjects); catch; end                                                              % conver to cell if needed
try bops.sessions = cellstr(bops.sessions); catch; end


