function writeMOT_EMG(c3dFilePath, emgLabels, bp, lp)
fp = filesep;

if nargin < 1
    [filename, path] = uigetfile({'*.c3d', 'C3D file'}, 'C3D data file...');
    c3dFilePath = [path, filename];
end

% Select EMG channels
if nargin < 2
    [~, analogData, ~, ~, ~, ~] = getInfoFromC3D(c3dFilePath);
    msg = 'Select labels corresponding to EMG signals';
    [indx, ~] = listdlg('PromptString', msg, 'ListString', analogData.Labels);
    emgLabels = analogData.Labels(indx);
elseif isempty(emgLabels)
    [~, analogData, ~, ~, ~, ~] = getInfoFromC3D(c3dFilePath);
    emgLabels = analogData.Labels;
end

% predifined emg filters
if nargin < 3
    bp = [50, 450];
    lp = 6;
end

% Load EMG data and time vector
[~, emgData, emgRate, ~] = ImportEMGc3d(c3dFilePath, emgLabels);
c3dData = btk_loadc3d(c3dFilePath);
time = c3dData.analog_data.Time;

% Filter data
emgsSelected = emgData;
emgsEnvelope = EMGLinearEnvelope(emgsSelected, emgRate, bp, lp);

% Save mot file as emg.mot
[parentFolderC3dFile, filename] = fileparts(c3dFilePath);
saveFolder = [parentFolderC3dFile, fp, filename];

if ~isfolder(saveFolder)
    mkdir(saveFolder);
end

printEMGmot(saveFolder, time, emgsEnvelope, emgLabels, '.mot');

disp(['EMG data saved in ', saveFolder]);

