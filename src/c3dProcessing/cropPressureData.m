function [] = cropPressureData(pressureData, times)
%Crop the pressure pad data into consecutive heel-strikes using the times
%defined from the full data capture
%   Input the pressureData as a column vector and times as a n x 2 array
%   and crop the pressure data into gait cycles.

% Define some variables here
videoSamplingRate = 100;
pressureSamplingRate = 50;

% First we need to change the times from the motion capture data so it
% matches the pressure data

v2p = videoSamplingRate/pressureSamplingRate;

times4Pressure = times * v2p;

for i = 1:length(times)
     
     pressure = 

end


end

