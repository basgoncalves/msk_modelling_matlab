
function bops = load_setup_bops

setupDir    = fileparts(mfilename('fullpath'));
bopsDir     = fileparts(fileparts(setupDir));

try dataDir = char(importdata([setupDir fp 'data_directory.dat'])); catch; end

if ~isfolder(dataDir)
    dataDir = uigetdir(cd);
    writematrix(dataDir,[setupDir fp 'data_directory.dat'])
end

setupfileDir = [dataDir fp 'bopsSettings.xml'];

Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
bops = xml_read(setupfileDir,Pref);                                                                                 % load "setup.xml"


bops.directories.bops = bopsDir;
bops.directories.mainData = dataDir;
bops.directories.setupbopsXML = setupfileDir;

try bops.subjects = cellstr(bops.subjects); catch; end                                                              % conver to cell if needed
try bops.sessions = cellstr(bops.sessions); catch; end


