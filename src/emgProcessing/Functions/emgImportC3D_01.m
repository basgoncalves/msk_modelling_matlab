clear;
clc;
close all;

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

% Select one of the .txt files in the folder
[fname, pname] = uigetfile('*.txt', 'Select .txt file');

% Set folder as that chosen above
txtFile_folder = pname;
txtFiles=dir([txtFile_folder,'\*.txt']);

% Select one of the c3d files in the folder
[fname, pname] = uigetfile('*.c3d', 'Select .c3d file');

% Set folder as that chosen above
c3dFile_folder = pname;
c3dFiles=dir([c3dFile_folder,'\*.c3d']);

%% Downsample the EMG data, put into c3d file analog channels, and save as new acquisition

for t_trial = 1:length(c3dFiles)
     
     txtFile_name = txtFiles(t_trial,1).name;
     c3dFile_name = c3dFiles(t_trial,1).name;
     % Downsample here and output the emg data and acquisition handle
     [btkAcq, emgData] = emgInsertion(txtFile_name, c3dFile_name);
     
     % Put new emg data into acquisition. i + 12 because FP channel data
     % finishes at channel 12, so we want to start from channel 13
     for i = 1:11
     [analogs, analogsInfo]  = btkSetAnalogValues(btkAcq, i+12, emgData(:,i));
     end
     
     % Write the new acquisition
     filename = [txtFile_name(:,1:11), '.c3d'];
     btkWriteAcquisition(btkAcq, filename);     
     
end

cd ..\
%% Run FFT
% Uncomment to run FFT and ensure frequency content is not lost from
% % interp1
% 
% [plot1, plot2, plot3, plot4, plot5] = emgAnalysis(Channel1, 1500, 2, 20, Times);
% 
% [p1, p2, p3, p4, p5] = emgAnalysis(emg.Channel1, 1000, 2, 20, actualFrames);
