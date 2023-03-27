

function setupAnalysis

project_settings = load_setup_bops;
subjects = split(project_settings.subjects,' ');
sessions = split(project_settings.sessions,' ');

%% move c3d data 
prompt = ['Do you want to move c3d files from "Vicon" folder to "InputData" folder?'];                              % ask if user wants to move c3d files
answer = questdlg(prompt,'choice','Select folders to move','Continue to next step...','Continue');
if isequal(answer,'Select folders to move')
    create_InputData_folder(project_settings);
end

%% select model to use
prompt = ['Do you want to use the current model' project_settings.directories.templates.Model];                                 % ask user
answer = questdlg(prompt,'choice','Select new model','Continue to next step...','Continue');

if isequal(answer,'Select new model')
    models = uigetmultiple([project_settings.directories.bops fp 'Templates' fp 'Models'],'Select .osim models to use in this project');
    project_settings.directories.templates.Model = models';
    for iModel = models
        copyfile(iModel{1},project_settings.directories.templatesDir)
    end
end
%% select EMG channels
prompt = ['Do you want to select new EMG channels' project_settings.emg.Muscle];                                                % ask user 
answer = questdlg(prompt,'choice','Select new channels','Continue to next step...','Continue');
if isequal(answer,'Select new channels')
    settings = load_subject_settings(subjects{1},sessions{1},'setupAnalysis');                % load subject settings
    if isempty(settings)
        selectSession(1);
        settings = load_subject_settings(project_settings.subjects{1},project_settings.sessions{1},'setupAnalysis');
    end

    if all(~isfile(settings.trials.c3dpaths))   % if c3d file paths DO NOT exist 
        msg = msgbox('Cannot find c3d files in path. EMG names cannot be selected at this time');
        uiwait(msg)
    else
        [~, AnalogData, ~, ~, ForcePlatformInfo, ~] = getInfoFromC3D(settings.trials.c3dpaths{1});
        msg = 'select EMG signals';
        [indx,~] = listdlg('PromptString',msg,'ListString',AnalogData.Labels);
        project_settings.emg.MuscleLabels = AnalogData.Labels(indx);
        project_settings.emg.Muscle = AnalogData.Labels(indx);
    end
end

%% select trials types
[trialType,~,~] = getTrialType_multiple(settings.trials.names);
trialType = unique(trialType);

prompt = ['Do you want to select new Dynamic Trials: ' project_settings.Trials.Dynamic];                                        % dynamic
answer = questdlg(prompt,'choice','Select new trials','Continue to next step...','Continue');
if isequal(answer,'Select new trials') 
    msg = 'select names of dynamic trials';                                                                         
    [indx,~] = listdlg('PromptString',msg,'ListString',trialType);
    project_settings.Trials.Dynamic = trialType(indx);
end


prompt = ['Do you want to select new EMG normalisation: ' project_settings.Trials.MaxEMG];                                         % MaxEMG
answer = questdlg(prompt,'choice','Select new trials','Continue to next step...','Continue');
if isequal(answer,'Select new trials')
    msg = 'select names of MaxEMG trials';                                                                         
    [indx,~] = listdlg('PromptString',msg,'ListString',trialType);
    project_settings.Trials.MaxEMG = trialType(indx);
end

%% rotation of the forceplates to lab CS

if all(~isfolder(settings.trials.c3dpaths))   % if c3d file paths DO NOT exist
    disp('Cannot find c3d files in path. Force plate set-up cannot be done at this time')
else
    if length(ForcePlatformInfo) ~= length(project_settings.Laboratory.FP)                                                          % if force plate number is not correct
        for i = 1:length(ForcePlatformInfo)                                                                             % assign generic force plate vlaues
            project_settings.Laboratory.FP(i).ID = i;
            project_settings.Laboratory.FP(i).PadTickness = 14;
            project_settings.Laboratory.FP(i).rotationToGlobal.X = 180;
            project_settings.Laboratory.FP(i).rotationToGlobal.Z = -180;
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
        definput = [definput, num2str(project_settings.Laboratory.FP(i).rotationToGlobal.X), ...
            ' ' , num2str(project_settings.Laboratory.FP(i).rotationToGlobal.Z), ' '];
    end
    prompt(end) = []; definput(end) = [];  % delete last space
    answer = inputdlg(split(prompt),'Select the correct rotations of the force plates',[1 35],split(definput));         % ask the user to confirm the FP rotations

    count_plate = 0;                                                                                                    % save rotations inbops struct
    for i = 1:2:length(ForcePlatformInfo)*2
        count_plate = count_plate + 1;
        project_settings.Laboratory.FP(count_plate).rotationToGlobal.X   = answer{i};
        project_settings.Laboratory.FP(count_plate).rotationToGlobal.Z   = answer{i+1};
    end
end

%% save data
xml_write(project_settings.directories.setupbopsXML,project_settings,'bops',project_settings.xmlPref);

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
