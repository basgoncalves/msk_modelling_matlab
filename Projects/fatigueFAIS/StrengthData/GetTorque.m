%% Description - Goncalves, BM (2019)
%
%
%-------------------------------------------------------------------------
%INPUT
%   dataDir  - directory of the data as output from C3D3MAT
%
%-------------------------------------------------------------------------
%OUTPUT
%   TorqueData = maxForce value
%
%--------------------------------------------------------------------------

function [ForceData,MaxForce] = GetTorque (dataDir)

%% filter settings

fs = 2000;                                                                  % sample frequency
PB = 6;                                                                     % passband frequency
%% find the folder of the subject to analyse IF not specified

if nargin <1
    dataDir = uigetdir('E:\1-PhD\3-FatigueFAI\Testing','Select data folder');
end


%% Max force
cd(dataDir);

load AnalogData.mat AnalogData;

data = AnalogData.RawData(:,33);
ForceData = lowpass(data,PB,fs);                                           % low pass filter;

% Flip data verticaly if needed
ForceDataFlipped = 0-ForceData(:,1);                                       % flip data vertically

if max(ForceDataFlipped) > max (ForceData)                         % if the max value of the flipped data is greater than the max of the initial filtered data
    ForceData = ForceDataFlipped;                                          % use the flipped data (because the data was
end

% calculate peak force 
peakForce = max (movmean(ForceData,fs));                                   % peak force as the max 1 sec moving average

% calculate baseline force
baselineForce = min (movmean(ForceData,fs));                               % peak force as the max 1 sec moving average

MaxForce = peakForce - baselineForce;

save ForceData ForceData peakForce baselineForce MaxForce

