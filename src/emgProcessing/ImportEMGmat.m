%% Description - Goncalves, BM (2019)
%
%-------------------------------------------------------------------------
%INPUT
%   filename  = directory of the .c3d file from Vicon export
%
%-------------------------------------------------------------------------
%OUTPUT
%   filename = name of the file (eg 'E:\1-PhD\3-FatigueFAI\Testing\Dan\pre\HE2.c3d')
%   EMGdata = cell matrix with the EMG channels. If want other others,
%   change "EMGchannels"
%   Fs = sample frequency
%   Labels = cell vector with name of the channels to be imported
%--------------------------------------------------------------------------


function [filename,EMGdata,Fs,Labels]=ImportEMGmat (filename,LabelsAnalog_data)

if nargin ==0
    [filename,path] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    cd (path);
    % get al the files in the path
    folderCSV = sprintf('%s\%s',path,'*.c3d');
    
else
    [path,name]=fileparts(which(filename));
    cd(path);
    filename = sprintf('%s%s',name,'.c3d');
end


% read the .c3d file
data = btk_loadc3d(filename);
% select EMG Channels  amd Labels
for i = 1: length(LabelsAnalog_data)
    if sum(contains(fields(data.analog_data.Channels),LabelsAnalog_data{i}))>0
        Nrows = length(data.analog_data.Channels.(LabelsAnalog_data{i})) ;   
        EMGdata(1:Nrows,i) = data.analog_data.Channels.(LabelsAnalog_data{i});
    else
        EMGdata(:,i) = NaN;
    end
end

Labels = LabelsAnalog_data;
% get sample frequency
Fs = data.analog_data.Info.frequency;