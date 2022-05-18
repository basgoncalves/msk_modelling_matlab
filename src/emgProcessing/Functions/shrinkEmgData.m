function [interpData] = shrinkEmgData(emgFrames, Channel, actualFrames)
%Shrink the EMG data so that it fits with acquisition data (1000Hz)
%   Input the EMG channel data, the number of frames of the EMG data, and
%   the actual frames that you want to shrink to

interpData = interp1(emgFrames, Channel, actualFrames, 'spline');

end

