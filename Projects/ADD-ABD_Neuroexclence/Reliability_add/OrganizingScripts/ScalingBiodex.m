% this function rearanges the scaling factors for the biodex (check excel
% file "datasheet_HRR")
% INPUT 
%   Data = row vector with the maximum values for the biodex torque  
%   newVoltageWeight = voltage witht the 69 Nm weight on
%   newVoltageZero = voltage with no weight on



function NewData = ScalingBiodex (Data,newVoltageWeight,newVoltageZero,oldScalingFactor,oldZero)


newScalingFactor = 69 / (abs(newVoltageWeight - newVoltageZero));              

NewData = Data / oldScalingFactor - oldZero;
NewData = (NewData + newVoltageZero) * newScalingFactor;

