

function setupAnalysis

bops = load_setup_bops;

subjects = selectSubjects(1);

sessions = selectSession(1);

% select model to use 
models = uigetmultiple([bops.directories.bops fp 'Templates' fp 'Models'],'Select .osim models to use in this project');
bops.directories.templates.Model = models';
for iModel = models
    copyfile(iModel{1},bops.directories.templatesDir)
end
xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);


% 
settings = load_subject_settings(subjects{1},sessions{1},'setupAnalysis'); 

% select EMG channels
[Markers, AnalogData, FPdata, Events, ForcePlatformInfo, Rates] = getInfoFromC3D(settings.trials.c3dpaths{1});

msg = 'select EMG signals';
[indx,~] = listdlg('PromptString',msg,'ListString',AnalogData.Labels); % select the sessions to use from all available

bops.emg.MuscleLabels = AnalogData.Labels(indx);
bops.emg.Muscle = AnalogData.Labels(indx);
xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);


% rotation of the forceplates
length(bops.Laboratory.FP)

length(ForcePlatformInfo)

winopen(settings.trials.c3dpaths{1})

