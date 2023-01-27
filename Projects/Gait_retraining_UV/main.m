

activeFile = matlab.desktop.editor.getActive;
bopsdir  = fileparts(activeFile.Filename);
cd([bopsdir '\..\..']);
activate_msk_modelling

bops = load_setup_bops;

bops.analyses

C3D2MAT_BOPS

import org.opensim.modeling.*


settings = load_subject_settings;
trial_paths = settings.trials.c3dpaths;
for i = 1: length(trial_paths)
    
    % split trial path in folder and trial name
    c3dfilepath  = trial_paths{i};
    folder = fileparts(c3dfilepath);
    trialName = settings.trials.names{i};

    % get directories of all files for this trial
    [osimFiles] = getdirosimfiles_BOPS(trialName);    
    
    % convert c3d to trc and mot files       
    c3dExport(c3dfilepath);                                                                                      
    
    % move trc and mot data to elaborated data folder
    if ~isfolder(fileparts(osimFiles.externalforces))
        mkdir(fileparts(osimFiles.externalforces))
    end
    movefile([folder fp 'test_data_forces.mot'],osimFiles.externalforces)
    movefile([folder fp 'test_data_markers.trc'],osimFiles.coordinates)

    % 
    EMGLabels = bops.emg.MuscleLabels;
    writeMOT_EMG(c3dfilepath,EMGLabels,bops.filters.EMGbp,bops.filters.EMGlp)
end