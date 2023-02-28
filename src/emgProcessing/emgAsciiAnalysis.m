function [] = emgAsciiAnalysis(inputc3d, txtFile, physFolderName, c3dFile_folder)
%Function to import .c3d file and .txt file and move downsampled EMG into
%the .c3d file
%   Import .c3d and .txt file, load the acquisition using btk, downsample
%   the EMG data so it fits with mocap data, then import the EMG into the
%   appropriate EMG column - also rename the EMG column.

%% Load c3d file using btk and add EMG data from text file.
% EMG data comes in form of text file
% Convert the text file to column variables and insert into c3d file as
% single analog channels for each muscle.

% The channels used in the normal EMG data are as follows
% Channel1 = Tib Ant
% Channel3 = Med Gastroc
% Channel4 = Lat Gastroc
% Channel6 = Biceps Fem
% Channel7 = VM
% Channel8 = VL
% Channel9 = RF
% Channel10 = Soleus
% Channel11 = Medial Ham

%% Import the .txt file and store in relevant column vectors
% Imports the data as 45000 x 1 column vectors for each muscle
% May need to resample the data to fit into c3d file
% Need to remember that the EMG data needs to align with the beginning of
% the c3d file so that the timing matches.

% Make this process faster by first searching the folder for names of
% files, and creating a cell array with those names for the .txt files and
% those for .c3d files

% Do this for fast and slow walks, and KneeFJC1 and 2
[Times, Channel1, Channel3, Channel4, Channel6, Channel7, Channel8,...
     Channel9, Channel10, Channel11] = importEmgTextFile(txtFile); % Import EMG

ChannelData = [Channel1 Channel3 Channel4 Channel6 Channel7 Channel8...
     Channel9 Channel10 Channel11];

%% Load c3d file with btk
h = btkReadAcquisition(inputc3d);
frames = btkGetAnalogFrameNumber(h);
actualFrames = (0.000:0.001:29.9990)';
data = btk_loadc3d(inputc3d);

% Some warning message if aquisition frames is different from EMG frames
if frames < length(actualFrames)
     firstFrame = btkGetFirstFrame(h); % Obtain first and last frame
     lastFrame = btkGetLastFrame(h);
     % BTK uses First/Last so convert to fit routine (e.g., first frame
     % always starts at 1
     lastFrame = lastFrame - firstFrame;
     firstFrame = 1;
else
     firstFrame = 1;
     lastFrame = 30000;
end



%% Convert first frame to the same number of units as EMG data
% Initialising some variables
F = 1000;
conversion = 3/2;
emgSamplingTimeStep = (1/F);
firstConversion = floor(firstFrame * conversion);
lastConversion = (frames * conversion);
framesConversion = floor(frames * conversion);
framesNew = frames-ceil(firstFrame);
diff2zero = 10 - firstFrame;

%% Shrink EMG data and store in structure
emg = struct();

% Variable Names
channelNames = {'Channel1', 'Channel3', 'Channel4','Channel6','Channel7',...
     'Channel8','Channel9','Channel10','Channel11'};

for i = 1:9
	if lastConversion > length(ChannelData(:,i))
		lastConversion = length(ChannelData(:,i));
     emg.(channelNames{1,i}) = shrinkEmgData2(ChannelData(:,i), firstConversion, lastConversion);
	else
		emg.(channelNames{1,i}) = shrinkEmgData2(ChannelData(:,i), firstConversion, lastConversion);
	end
	
end

Time = shrinkEmgData2(Times, firstConversion, lastConversion);



%% Put EMG data into matrix for c3d file

% Initialize
emgProcessed = [];

for i = 1:9, k = [1,3,4,6,7,8,9,10,11];
     emgData = emg.(channelNames{1,i});
     emgProcessed(:,k(1,i)) = emgData(:);
end

%% Create structure of final, interpolated EMG data
emgFinal = struct();
% Define analog times
emgFrames = data.fp_data.Time;
% emgFrames = (0:emgSamplingTimeStep:(framesNew-diff2zero)/1000)'; 

channelNamesReal = {'Channel1', 'Channel2', 'Channel3', 'Channel4', 'Channel5', 'Channel6','Channel7',...
     'Channel8','Channel9','Channel10','Channel11'};

% Loop through EMG data and interp so it fits with analog data in c3d file.
for i = 1:11
     emgFinal.(channelNamesReal{1,i}) = shrinkEmgData(Time, emgProcessed(:,i), emgFrames);
end


% Make sure the EMG data align correctly with analog channels in the .c3d file.

% emgProcessedShort = emgProcessed((first-4):(last+5),:);
% Added + 5 and - 5 frames to the data because last frame - first frame did
% not equal the total number of frames in the capture


%% Put EMG data into matrix for c3d file

% Initialize
emgImport= zeros(frames,11);

for i = 1:11, k = 1:11;
     emgData = emgFinal.(channelNamesReal{1,i});
     emgImport(:,k(1,i)) = emgData;
end

%% Put EMG data into c3d file in appropriate channel

for i = 1:11
     % replace analog channel values
     btkSetAnalogValues(h, i+12, emgImport(:,i));
     % replace muscle labels in c3d file with those consistent for CEINMS
     replaceMuscleLabels(h, i+12);
end

% Navigate to physical folder and save c3d there
cd(physFolderName);

outputName = inputc3d;
btkWriteAcquisition(h, outputName);

% Copy file back to Google Drive
% fileSource = [physFolderName, filesep, outputName];
% copyfile(fileSource, c3dFile_folder)

cd(c3dFile_folder);

disp(['Finished merging EMG from txt file ', txtFile, ' into ', inputc3d, ', good job, bro'])
%% Run FFT
% Uncomment to run FFT and ensure frequency content is not lost from
% interp1

% [plot1, plot2, plot3, plot4, plot5] = emgAnalysis(Channel1, 1500, 2, 20, Times);
%
% [p1, p2, p3, p4, p5] = emgAnalysis(emg.Channel1, 1000, 2, 20, actualFrames);


end

