%% Description - Goncalves, BM (2019)
%
%-------------------------------------------------------------------------
%INPUT
%   filename  = directory of the .csv file from Vicon ASCII
%   export
%
%-------------------------------------------------------------------------
%OUTPUT
%   filename = name of the file
%   EMGdata = cell matrix with the EMG channels. If want other others,
%   change "EMGchannels"
%   Fs = sample frequency
%   Labels = cell vector with name of the channels to be imported
%--------------------------------------------------------------------------


function [filename,EMGdata,Fs,Labels]=ImportEMGcsv (filename)

% define channels to Import
EMGchannels = 19:35;

% open file 
% filename = 'E:\1-PhD\3-FatigueFAI\Testing\Dan\pre\HE2.csv';

if nargin ==0
    [filename,path] = uigetfile ('*.csv');
    cd (path);
    % get al the files in the path
    folderCSV = sprintf('%s\%s',path,'*.csv');
    
else
    [path,name]=fileparts(which(filename));
    cd(path);
    filename = sprintf('%s%s',name,'.csv');
end


% read the .csv file
[~,~,data] = xlsread(filename);

% find the first column of the csv output file
FirstColumn = (data(:,1));

% convert each cell to string
FirstColumn = string(FirstColumn);

% find the begining of trajectroires in the csv file output
for i = 1: length(FirstColumn)
    if contains(FirstColumn(i),'Trajectories')
        idx = i-1;
        break
    end
end

% define channels to Import
EMGchannels = length(LabelsAnalog_data)-16:length(LabelsAnalog_data);
% select EMG Channels  amd Labels
EMGdata = data(6:idx,EMGchannels);
Labels = data (4 , EMGchannels);

% get sample frequency
Fs = data{2,1};
