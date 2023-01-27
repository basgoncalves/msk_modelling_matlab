function writeMOT_EMG(c3dfilepath,EMGLabels,bp,lp)

fp = filesep;

if nargin < 1
    [filename,path] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    c3dfilepath = [path filename];
end

% select EMG channels
if nargin < 2    
    [~, AnalogData, ~, ~, ~, ~] = getInfoFromC3D(c3dfilepath);
    msg = 'select labels corresponding to EMG signals';
   
    [indx,~] = listdlg('PromptString',msg,'ListString',AnalogData.Labels); 
    EMGLabels = AnalogData.Labels(indx);
end

if nargin < 3
    bp = [50 450];
    lp = 6;
end

% load EMG data and time vector
[~,EMGdata,EMGRate,~] = ImportEMGc3d (c3dfilepath,EMGLabels);
c3d_data = btk_loadc3d(c3dfilepath);
time = c3d_data.analog_data.Time;

% filter data
EMGsSelected = EMGdata;
EMGsEnvelope = EMGLinearEnvelope(EMGsSelected,EMGRate,bp,lp);                       

% save mot file as emg.mot
[save_folder,filename] = fileparts(c3dfilepath);
printEMGmot(save_folder,time,EMGsEnvelope,EMGLabels,'.mot')

% remanme the file to match the c3dfile name
movefile([save_folder fp 'emg.mot'],[save_folder fp filename '_emg.mot'])