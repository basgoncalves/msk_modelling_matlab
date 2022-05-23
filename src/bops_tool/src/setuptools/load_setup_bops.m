
function bops = load_setup_bops

setupDir    = fileparts(mfilename('fullpath'));
bopsDir     = fileparts(fileparts(setupDir));
dataDir     = char(importdata([setupDir fp 'data_directory.dat']));

if ~isfolder(dataDir)
    dataDir = uigetdir(cd); 
    writematrix(dataDir,[setupDir fp 'data_directory.dat'])
end

setupfileDir = [dataDir fp 'bopsSettings.xml'];
try bops = xml_read(setupfileDir); end                                                                              % load "setup.xml"

bops.directories.bops = bopsDir;
bops.directories.mainData = dataDir;
bops.directories.setupbopsXML = setupfileDir;

try bops.subjects = cellstr(bops.subjects); end                                                                     % conver to cell if needed
try bops.sessions = cellstr(bops.sessions); end


