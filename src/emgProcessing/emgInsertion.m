function [acq, emgImport] = emgInsertion(textFile, acquisitionFile)
% Puts text file containing raw EMG into c3d file with empty analog channels
%   Input text file containing raw EMG and c3d file with empty analog
%   channels. This downsamples the EMG data from 45000 frames to the same
%   size as the other analog frames in the c3d file.

[Times, Channel1, Channel3, Channel4, Channel6, Channel7, Channel8,...
     Channel9, Channel10, Channel11] = importEmgTextFile(textFile); % Import EMG

ChannelData = [Channel1 Channel3 Channel4 Channel6 Channel7 Channel8...
     Channel9 Channel10 Channel11];

% Load c3d file with btk
acq = btkReadAcquisition(acquisitionFile);


%% Extract info from trial
analogs = btkGetAnalogs(acq);
ratio = btkGetAnalogSampleNumberPerFrame(acq);

analogFrames = btkGetAnalogFrameNumber(acq);
actualFrames = (0.000:0.001:29.9990)';

firstFrame = btkGetFirstFrame(acq); % Obtain first and last frame
lastFrame = btkGetLastFrame(acq);

conversion = 3/2;

% If/else statement to assign first and last frames properly.

if firstFrame == 1
     newLastFrame = (lastFrame * ratio);
     firstConversion = firstFrame;
     lastConversion = floor(newLastFrame * conversion);
     emgFrames = (firstFrame:1:newLastFrame)'; emgFrames = emgFrames ./ 1000;
elseif firstFrame == 2
     newLastFrame = (lastFrame * ratio) - 9;
     firstConversion = firstFrame + 9;
     lastConversion = floor(newLastFrame * conversion);
     emgFrames = (firstConversion + 1:1:newLastFrame)'; emgFrames = emgFrames ./ 1000;
else
     firstFrame = firstFrame - 1;
     newFirstFrame = (firstFrame * ratio) - 9;
     newLastFrame = (lastFrame * ratio) - 9;
     firstConversion = floor(newFirstFrame * conversion);
     lastConversion = floor(newLastFrame * conversion);
     emgFrames = (newFirstFrame + 1:1:newLastFrame)'; emgFrames = emgFrames ./ 1000;
end

% Frames in analog data
framesConversion = analogFrames * conversion;
% Frames in EMG data
totalFrameConversion = lastConversion - firstConversion;
%% Shrink EMG data and store in structure
emg = struct();

% Variable Names
channelNames = {'Channel1', 'Channel3', 'Channel4','Channel6','Channel7',...
     'Channel8','Channel9','Channel10','Channel11'};

for i = 1:9
     emg.(channelNames{1,i}) = shrinkEmgData2(ChannelData(:,i), firstConversion, lastConversion-1);
end

Time = shrinkEmgData2(Times, firstConversion, lastConversion-1);



%% Put EMG data into matrix

% Initialize
emgProcessed = [];

for i = 1:9, k = [1,3,4,6,7,8,9,10,11];
     emgData = emg.(channelNames{1,i});
     emgProcessed(:,k(1,i)) = emgData;
end

%%
emgFinal = struct();

channelNamesReal = {'Channel1', 'Channel2', 'Channel3', 'Channel4', 'Channel5', 'Channel6','Channel7',...
     'Channel8','Channel9','Channel10','Channel11'};

for i = 1:11
     emgFinal.(channelNamesReal{1,i}) = shrinkEmgData(Time, emgProcessed(:,i), emgFrames);
end


% Make sure the EMG data align correctly with analog channels in the .c3d file.

% emgProcessedShort = emgProcessed((first-4):(last+5),:);
% Added + 5 and - 5 frames to the data because last frame - first frame did
% not equal the total number of frames in the capture


%% Put EMG data into matrix for c3d file

% Initialize
emgImport= [];

for i = 1:11, k = 1:11;
     emgData = emgFinal.(channelNamesReal{1,i});
     emgImport(:,k(1,i)) = emgData;
end

end

