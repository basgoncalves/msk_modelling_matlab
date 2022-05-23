%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Compare GRF data between trials 
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   smfai_InputData
%   OrganiseFAI
%   GetGRFfromC3D
%   
%   
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------
%% BatchGRF_FAI

function BatchGRF_FAI (SubjectFoldersInputData, sessionName)

smfai_InputData % select multiple FAI participants (InputData)
OrganiseFAI
GRF= struct;
for ff = 1:length(SubjectFoldersInputData)

    DirC3D = [SubjectFoldersInputData{ff} filesep SessionFolder];
    OrganiseFAI         % get folder directories and c3d files in the DirC3D folder
    GRF.(['s' Subject]) = struct;
    % loop through the c3d files 
    for ii = 1:length(Files)
        Dirfile = [Files(ii).folder filesep Files(ii).name];
        filename = strrep(Files(ii).name,'.c3d','');
        
        
        [GRF,c3dData] = GetGRFfromC3D (Dirfile);   % load grf data for one trial
        [events,motionDirection] = findHeelStrike_Running_multiple(c3dData)
        APgrf = GRFData(
        
        GRF.(['s' Subject]).(filename) = GRFData;
        
    end
end

