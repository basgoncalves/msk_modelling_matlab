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


function [filename,EMGdata,Fs,Labels,time]=ImportEMGc3d (filepath,EMGLabels)

if nargin ==0
    [filename,path] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    filepath = [path filename];
else
    [~,filename] = fileparts(filepath);
end


% read the .c3d file
[Markers, AnalogData, FPdata, Events, ForcePlatformInfo, Rates] = getInfoFromC3D(filepath);
AnalogLabels = AnalogData.Labels;
% select EMG Channels  amd Labels
for i = 1: length(EMGLabels)
    try 
        col = contains(AnalogLabels,EMGLabels{i});
        Nrows = length(AnalogData.RawData(:,col)) ;   
        EMGdata(1:Nrows,i) = AnalogData.RawData(:,col);
    catch
        EMGdata(:,i) = NaN;
    end
end

Labels = EMGLabels;
% get sample frequency
Fs = AnalogData.Rate;