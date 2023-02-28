function [interpData] = shrinkEmgData2(emgFrames, first,last)
%Shrink the EMG data so that it fits with acquisition data (1000Hz)
%   Input the EMG channel data, the number of frames of the EMG data, and
%   the actual frames that you want to shrink to

interpData = emgFrames(first:last, :);

end

