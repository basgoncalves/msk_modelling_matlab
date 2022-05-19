%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% GRF
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   btk_loadc3d 
%   combineForcePlates_multiple
%   
%INPUT
%   Dirfile
%-------------------------------------------------------------------------
%OUTPUT
%   GRF = double with all the GRF
%--------------------------------------------------------------------------

%% GetGRFfromC3D

function [GRF,c3dData] = GetGRFfromC3D (Dirfile)

c3dData = btk_loadc3d(Dirfile);
dataOutput = combineForcePlates_multiple(c3dData);
GRF = dataOutput.GRF.FP.F;









