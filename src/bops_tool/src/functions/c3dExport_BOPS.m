

function c3dExport_BOPS

bops = load_setup_bops;
settings = load_subject_settings;
trial_paths = settings.trials.c3dpaths;

% define EMG filters
EMGLabels = bops.emg.MuscleLabels;
bandPassFilter = bops.filters.EMGbp;
lowPassFilter = bops.filters.EMGlp;

for i = 1:length(trial_paths)
    
    % split trial path in folder and trial name
    c3dFilePath  = trial_paths{i};
    
    % convert c3d to trc and mot files          
    exportC3d(c3dFilePath,EMGLabels,bandPassFilter,lowPassFilter)
   
end