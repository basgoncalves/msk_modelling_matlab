%% Description - Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this function filters and plots .
%
% INPUT
%   oldData = vector column to rescale in Newtons/ Nm 

%-------------------------------------------------------------------------
%OUTPUT
%   NewData = rescaled data
%

%% start fucntion
function NewData = RescaleForce (oldData)
    
    OldScalingFacor =str2double (inputdlg('Type old scaling factor'));
    OldZero = str2double(inputdlg('Type old ZERO level'));
    newVoltageWeight = str2double(inputdlg('Type new voltage with Calibration Weight'));
    newVoltageZero = str2double(inputdlg('Type new ZERO voltage'));
    
    NewData = ScalingBiodex (oldData,newVoltageWeight,...
        newVoltageZero, OldScalingFacor, OldZero);                             %  NewData = ScalingBiodex (Data,newVoltageWeight,newVoltageZero,oldScalingFactor,oldZero)
 
    
