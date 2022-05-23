%% Description - Goncalves, BM (2019)
%
%-------------------------------------------------------------------------
%INPUT
%   data = vector columns with Force data
%   fs = sample frequency 
%-------------------------------------------------------------------------
%OUTPUT
%   ForceData = column of the force data
%   MaxForce = maxForce value
%   baselineForce = baseline force as the nin 1 sec moving average
%   peakForce = peak force as the max 1 sec moving average
%--------------------------------------------------------------------------

function [ForceData,MaxForce,baselineForce,peakForce,idxPeak] = GetMaxForce (data,fs)

%% filter settings

Fnyq = fs/2;
fcolow = 6;                                                                 % passband frequency
% calculate baseline force
baselineForce = min (movmean(data,fs));       

[b,a] = butter(2,fcolow*1.25/Fnyq,'low');
ForceData = filtfilt(b,a,data-baselineForce);                                             % low pass filter;
movingWindow = fs/2;

% Flip data verticaly if needed
ForceDataFlipped = 0-ForceData(:,1);                                       % flip data vertically

if max(ForceDataFlipped) > max (ForceData)                                 % if the max value of the flipped data is greater than the max of the initial filtered data
    ForceData = ForceDataFlipped;                                          % use the flipped data (because the data was
end

% calculate peak force 
[peakForce,idxPeak] = max (movmean(ForceData,movingWindow));                                   % peak force as the max  moving average

idxPeak = idxPeak-movingWindow/2:idxPeak+movingWindow/2;

% delete negative values 
if min (idxPeak) < 1
    idxPeak(idxPeak<1)=[];  
    warning on
    warning ('max force window starts before zero')
end

% delete values after the end of the force vector 
if max (idxPeak) > length (ForceData)
    idxPeak(idxPeak > length (ForceData))=[];  
    warning ('max force window ends outside the force vector')
end


% calculate baseline force
baselineForce = min (movmean(ForceData,movingWindow));                               % baseline force as the nin 1 sec moving average

MaxForce = peakForce - baselineForce;                                      % max force without the baseline value

