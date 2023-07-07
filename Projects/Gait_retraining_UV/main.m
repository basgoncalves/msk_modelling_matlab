function main

% activate msk_modelling
activeFile = matlab.desktop.editor.getActive;
bopsdir  = fileparts(activeFile.Filename);
cd([bopsdir '\..\..']);
activate_msk_modelling



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
%         run_IK(model_path,trc_file,resultsDir,marker_weights_path)
% 
%         run_ID(model_path,mot_file,grf_xml,resultsDir)

        run_MA(model_path,mot_file,grf_xml,[resultsDir fp 'ma_results'])
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
function run_MA(model_path,ik_mot,grf_xml,resultsDir)

if ~isfolder(resultsDir)
    mkdir(resultsDir)
end

import org.opensim.modeling.*
% Load the model
model = Model(model_path);
model.initSystem();                                 % Apply the motion data to the model

% Load the motion data
motion = Storage(ik_mot);

% Create a MuscleAnalysis object
muscleAnalysis = MuscleAnalysis();
muscleAnalysis.setModel(model);                     % Set the model for the MuscleAnalysis object
muscleAnalysis.setStartTime(motion.getFirstTime);
muscleAnalysis.setEndTime(motion.getLastTime);
muscleAnalysis.set_model(model);

% Create the muscle analysis tool
maTool = AnalyzeTool();
maTool.setModel(model);                                 % Set the model for the muscle analysis tool
maTool.setModelFilename(model_path);
maTool.setLowpassCutoffFrequency(6);                    % Set the motion data for the muscle analysis tool
maTool.setCoordinatesFileName(ik_mot);
maTool.setName('Muscle analysis');
maTool.setMaximumNumberOfSteps(20000);
maTool.setStartTime(motion.getFirstTime)                % time window
maTool.setFinalTime(motion.getLastTime)
maTool.getAnalysisSet().cloneAndAppend(muscleAnalysis)  % add analysis set
maTool.setResultsDir(resultsDir);                       % results directory
maTool.setInitialTime(motion.getFirstTime);             % time window
maTool.setFinalTime(motion.getLastTime);                
maTool.setExternalLoadsFileName(grf_xml)                % grf xml 
maTool.setSolveForEquilibrium(false)                    % other settings
maTool.setReplaceForceSet(false);
maTool.setMaximumNumberOfSteps(20000)
maTool.setOutputPrecision(8)
maTool.setMaxDT(1)
maTool.setMinDT(1e-008)
maTool.setErrorTolerance(1e-005)
maTool.removeControllerSetFromModel()
maTool.print([resultsDir fp '..' fp 'ma_setup.xml']);           % print setup

maTool = AnalyzeTool([resultsDir fp '..' fp 'ma_setup.xml']);   % reload analysis from xml (for some reason doesn't work othewise)

% Run the muscle analysis calculation
maTool.run;

%------------------------------------------------------------------------------------------%
