%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
%  Create a GRF xml based on the force plates steps from the acquisition
%   xml
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%INPUT
%   AcqDir = full directory of the Acquisition xml
%   genericExtLoadFullPath = full directory of the external load xml
%   template
%-------------------------------------------------------------------------
%OUTPUT
%   GRFxml = struct with the info for the GRF to use in opensim
%--------------------------------------------------------------------------


function GRFxml = writeGRFxml (AcqDir,genericExtLoadFullPath,CurrentTrial)

GRFxml = xml_read(genericExtLoadFullPath);
AcqXml = xml_read([AcqDir]);

nForcePlates = length(GRFxml.ExternalLoads.objects.ExternalForce);

for aa = 1:length(AcqXml.Trials.Trial)
    if contains(CurrentTrial,AcqXml.Trials.Trial(aa).Type)
        idxAcq = aa;
        break
    end
end

deletePlate=[];
for fp = 1:nForcePlates
    
    LegOnPlate = AcqXml.Trials.Trial(idxAcq).StancesOnForcePlatforms.StanceOnFP(fp).leg;
    GRFxml.ExternalLoads.objects.ExternalForce(fp).ATTRIBUTE.name = LegOnPlate;
    if contains(LegOnPlate,'Right')
        GRFxml.ExternalLoads.objects.ExternalForce(fp).ATTRIBUTE.name = 'Right';
        GRFxml.ExternalLoads.objects.ExternalForce(fp).applied_to_body = 'calcn_r';
    elseif contains(LegOnPlate,'Left')
        GRFxml.ExternalLoads.objects.ExternalForce(fp).ATTRIBUTE.name = 'Left';
        GRFxml.ExternalLoads.objects.ExternalForce(fp).applied_to_body = 'calcn_l';
    else
        deletePlate(end+1) = fp;
    end
    
end
% delete those that are not used
GRFxml.ExternalLoads.objects.ExternalForce(deletePlate)=[];