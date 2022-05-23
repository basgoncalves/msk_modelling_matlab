%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   muscles
%   GetMaxForce
%INPUT
%   CEINMSDir = mame of the CEINMS directory conatianing calirated subject XML 
%   muscles   = name of the muscles to output parameters
%-------------------------------------------------------------------------
%OUTPUT
%   MF = muscle parameters
%--------------------------------------------------------------------------

%% Function/Script name
function [MP] = getMP (CEINMSdir,muscles)


Para = xml_read([CEINMSdir]);
MP = struct;
for ii = 1:length(Para.mtuSet.mtu)
    if contains(Para.mtuSet.mtu(ii).name,muscles)&& isempty(fields(MP))
        MP = [Para.mtuSet.mtu(ii)];
    elseif contains(Para.mtuSet.mtu(ii).name,muscles)&& ~isempty(fields(MP))
        MP = [MP Para.mtuSet.mtu(ii)];
    end
end

