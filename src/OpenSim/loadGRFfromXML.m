% GRF = loadGRFfromXML (DirGRFxml,leg,normalise)
%   DirGRFxml: full path of the xml file 
%   leg: "R" for right OR "L" for left (lower case is fine too)
%   TimeWindow = define the time window (default = full trial)
%   timenormalise: 0 = do not time normalise; 1 (default) = time normalise data
% see also xml_read LoadResults_BG
function [APgrf,Vgrf,MLgrf,Labels] = loadGRFfromXML (DirGRFxml,leg,TimeWindow,timenormalise)
fp = filesep;

if nargin<4; timenormalise=1; end

OriginalDir = cd;
GRFxml = xml_read(DirGRFxml);

idx = find(contains({GRFxml.ExternalLoads.objects.ExternalForce.applied_to_body},['_' lower(leg)]));  % select the GRF associated with the defined leg
GRFvars = {GRFxml.ExternalLoads.objects.ExternalForce(idx).force_identifier};

cd(fileparts(DirGRFxml))                                                                  % cd into the folder of the GRF xml in case "datafile" is written in relative path
[GRF,Labels] = LoadResults_BG(GRFxml.ExternalLoads.datafile,TimeWindow,GRFvars,0,timenormalise); % load data      

APgrf = GRF(:,contains(Labels,'_vx'));
Vgrf = GRF(:,contains(Labels,'_vy'));
MLgrf = GRF(:,contains(Labels,'_vz'));

cd(OriginalDir)