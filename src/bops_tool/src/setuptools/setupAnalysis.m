

function setupAnalysis

bops = load_setup_bops;

%% move c3d data 
prompt = ['Do you want to move c3d files from "Vicon" folder to "InputData" folder?'];                              % ask if user wants to move c3d files
answer = questdlg(prompt,'choice','Select folders to move','Continue to next step...','Continue');
if isequal(answer,'Select folders to move')
    create_InputData_folder(bops);
end

%% select model to use
models = uigetmultiple([bops.directories.bops fp 'Templates' fp 'Models'],'Select .osim models to use in this project');
bops.directories.templates.Model = models';
for iModel = models
    copyfile(iModel{1},bops.directories.templatesDir)
end

%% select EMG channels
prompt = ['Do you want to select new EMG channels' bops.emg.Muscle];                                                % ask user 
answer = questdlg(prompt,'choice','Select new channels','Continue to next step...','Continue');
if isequal(answer,'Select new channels')
    settings = load_subject_settings(bops.subjects{1},bops.sessions{1},'setupAnalysis');                            % load subject settings
    if isempty(settings)
        selectSession(1);
        settings = load_subject_settings(bops.subjects{1},bops.sessions{1},'setupAnalysis');
    end
    [~, AnalogData, ~, ~, ForcePlatformInfo, ~] = getInfoFromC3D(settings.trials.c3dpaths{1});
    msg = 'select EMG signals';
    [indx,~] = listdlg('PromptString',msg,'ListString',AnalogData.Labels);
    bops.emg.MuscleLabels = AnalogData.Labels(indx);
    bops.emg.Muscle = AnalogData.Labels(indx);
end

%% select trials types
[trialType,~,~] = getTrialType_multiple(settings.trials.names);
trialType = unique(trialType);

prompt = ['Do you want to select new Dynamic Trials: ' bops.Trials.Dynamic];                                        % dynamic
answer = questdlg(prompt,'choice','Select new trials','Continue to next step...','Continue');
if isequal(answer,'Select new trials') 
    msg = 'select names of dynamic trials';                                                                         
    [indx,~] = listdlg('PromptString',msg,'ListString',trialType);
    bops.Trials.Dynamic = trialType(indx);
end


prompt = ['Do you want to select new Dynamic Trials: ' bops.Trials.MaxEMG];                                         % MaxEMG
answer = questdlg(prompt,'choice','Select new trials','Continue to next step...','Continue');
if isequal(answer,'Select new trials')
    msg = 'select names of MaxEMG trials';                                                                         
    [indx,~] = listdlg('PromptString',msg,'ListString',trialType);
    bops.Trials.MaxEMG = trialType(indx);
end

%% rotation of the forceplates to lab CS
if length(ForcePlatformInfo) ~= length(bops.Laboratory.FP)                                                          % if force plate number is not correct
    for i = 1:length(ForcePlatformInfo)                                                                             % assign generic force plate vlaues
        bops.Laboratory.FP(i).ID = i;
        bops.Laboratory.FP(i).PadTickness = 14;
        bops.Laboratory.FP(i).rotationToGlobal.X = 180;
        bops.Laboratory.FP(i).rotationToGlobal.Z = -180;
    end
end
winopen(settings.trials.c3dpaths{1});                                                                               % open c3d file
pause(2)
msg = msgbox(['Please confirm the roations of the forceplates']);
uiwait(msg)
prompt = '';
definput = '';
for i = 1:length(ForcePlatformInfo)
    prompt = [prompt , ['FP' num2str(i) '_X '] , ['FP' num2str(i) '_Z ']];
    definput = [definput, num2str(bops.Laboratory.FP(i).rotationToGlobal.X), ...
        ' ' , num2str(bops.Laboratory.FP(i).rotationToGlobal.Z), ' '];
end
prompt(end) = []; definput(end) = [];  % delete last space
answer = inputdlg(split(prompt),'Select the correct rotations of the force plates',[1 35],split(definput));         % ask the user to confirm the FP rotations

count_plate = 0;                                                                                                    % save rotations inbops struct
for i = 1:2:length(ForcePlatformInfo)*2
    count_plate = count_plate + 1;
    bops.Laboratory.FP(count_plate).rotationToGlobal.X   = answer{i};
    bops.Laboratory.FP(count_plate).rotationToGlobal.Z   = answer{i+1};
end


%% save data
xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);

%% -----------------------------------CALBACK FUNCTIONS------------------------------------------------- %
function subjects = create_InputData_folder(bops)

if nargin <1
    bops = load_setup_bops;
end

% select subject folders containing sessions and c3d files
prompt = 'Select Vicon subject folders';
subject_folders = uigetmultiple(bops.directories.mainData,prompt);
mkdir([bops.directories.InputData])

for iFolder = subject_folders
    parts = split(iFolder{1},fp);
    subject = parts{end};
    sessions = getfolders(iFolder{1});

    for iSession = {sessions.name}
        viconFolder = [iFolder{1} fp iSession{1}];
        inputFolder = [bops.directories.InputData fp subject fp iSession{1}];
        mkdir([bops.directories.InputData fp subject fp iSession{1}])

        % copy c3d files to the new Input folder
        c3dFiles = getfiles([viconFolder fp '*.c3d']);
        for iFile = c3dFiles
            copyfile(iFile{1},inputFolder)
        end
    end
end

[subjects,~] = check_subjects(bops);
