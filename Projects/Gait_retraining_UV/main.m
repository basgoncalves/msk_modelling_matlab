function main

% activate msk_modelling
activeFile = matlab.desktop.editor.getActive;
bopsdir  = fileparts(activeFile.Filename);
cd([bopsdir '\..\..']);
activate_msk_modelling

main_dir = 'Z:\GaitRetraining\MonteCarlo';
data_dir = [main_dir fp 'TD10_Data'];

model_path = [main_dir fp 'Model\defModel_scaled.osim'];
marker_weights_path = [main_dir fp 'marker_weights.xml'];

% get_marker_weight_from_model(model_path,marker_weights_path)

trial_list = dir(data_dir);
trial_list = {trial_list([trial_list.isdir]).name};
trial_list(1:2) = [];

for i = 1:length(trial_list)

    % file directories
    trialDir = [data_dir fp trial_list{i}];
    trc_file = [trialDir fp 'marker_experimental.trc'];
    grf_file = [trialDir fp 'grf.mot'];
    grf_xml  = [trialDir fp 'GRF.xml'];
    c3dpath  = [trialDir fp 'c3dfile.c3d'];
    mot_file = [trialDir fp 'ik.mot'];

    resultsDir = trialDir;

    %     c3dExport(c3dpath)
    try
        run_IK(model_path,trc_file,resultsDir,marker_weights_path)

        run_ID(model_path,mot_file,grf_xml,resultsDir)

        run_MA(model_path,mot_file,resultsDir)
    end
end

%% -----------------------Run OpenSim API functions ---------------------------------------%
%------------------------------------------------------------------------------------------%
function run_IK(model_path,trc_file,resultsDir,marker_weights_path)

import org.opensim.modeling.*
trc = load_trc_file(trc_file);

% Load the model
osimModel = Model(model_path);
state = osimModel.initSystem();

% Define the time range for the analysis
initialTime = trc.Time(1);
finalTime = trc.Time(end);

% Create the inverse kinematics tool
ikTool = InverseKinematicsTool();
ikTool.setModel(osimModel);
ikTool.setStartTime(initialTime);
ikTool.setEndTime(finalTime);
ikTool.setMarkerDataFileName(trc_file);
ikTool.setResultsDir(resultsDir);
ikTool.set_accuracy(1*10^-6),
ikTool.setOutputMotionFileName([resultsDir fp 'ik.mot']);

% print setup
ikTool.print([resultsDir fp 'ik_setup.xml']);

% Run inverse kinematics
disp(['running ik...'])
ikTool.run();
%------------------------------------------------------------------------------------------%

%------------------------------------------------------------------------------------------%
function run_ID(model_path,ik_mot,grf_xml,resultsDir)

import org.opensim.modeling.*
% Load the model
model = Model(model_path);

% Load the motion data
motion = Storage(ik_mot);

% Apply the motion data to the model
model.initSystem();

% Create the inverse dynamics tool
idTool = InverseDynamicsTool();

% Set the model for the inverse dynamics tool
idTool.setModel(model);
idTool.setModelFileName(model_path)

% Set time range
idTool.setStartTime(motion.getFirstTime)
idTool.setEndTime(motion.getLastTime)

% Set the motion data for the inverse dynamics tool
idTool.setLowpassCutoffFrequency(6);
idTool.setCoordinatesFileName(ik_mot);

idTool.setExternalLoadsFileName(grf_xml);

excludedForces = ArrayStr();
excludedForces.setitem(0,'muscles')
idTool.setExcludedForces(excludedForces)

% Results directories
idTool.setOutputGenForceFileName([resultsDir fp 'id.sto']);
idTool.setResultsDir([resultsDir])

% print setup
idTool.print([resultsDir fp 'id_setup.xml']);

% Run the inverse dynamics calculation
disp(['running id...'])
idTool.run();
%------------------------------------------------------------------------------------------%

%------------------------------------------------------------------------------------------%
function run_MA(model_path,ik_mot,resultsDir)

import org.opensim.modeling.*
% Load the model
model = Model(model_path);

% Load the motion data
motion = Storage(ik_mot);

% Apply the motion data to the model
model.initSystem();


% Create the muscle analysis tool
maTool = AnalyzeTool();

% Set the model for the muscle analysis tool
maTool.setModel(model);

% Set the motion data for the muscle analysis tool
maTool.setLowpassCutoffFrequency(6);
maTool.setInputMotionFileName(ik_mot);

% print setup
maTool.print([resultsDir fp 'ma_setup.xml']);

% Run the muscle analysis calculation
maTool.run();


% Run the inverse dynamics calculation
disp(['running id...'])
idTool.run();
%------------------------------------------------------------------------------------------%
