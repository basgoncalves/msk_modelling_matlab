

function torsion_tool_bops

clc; close all;  % clean workspace (use restoredefaultpath if needed)
activate_msk_modelling
bops = load_setup_bops;

if ~contains(bops.directories.mainData,'TorsionToolAllModels')
    bops = setupbopstool;     
end

simulationsdir = 'C:\Git\research_data\TorsionToolAllModels\simulations';
modelsdir = 'C:\Git\research_data\TorsionToolAllModels\models';
subjects = {getfolders(simulationsdir).name};
sessions = {'pre', 'post'};

for iSubj = 1:length(subjects)
    for iSess = 1%:length(sessions)

        subject = subjects{iSubj};
        session = sessions{iSess};
        session_folder = [simulationsdir fp subject fp session];
        [subjectSettings] = load_subject_settings(subject,session);

        subjectInfo = getSubjectInfo(subject);

        model_torsion_unscaled  = [modelsdir fp subject fp 'FINAL_PERSONALISEDTORSIONS.osim'];
        model_scaled            = [modelsdir fp subject fp 'torsion_scaled.osim'];
        model_luca              = [modelsdir fp subject fp 'torsion_scaled_luca.osim'];
        model_handsfield        = [modelsdir fp subject fp 'torsion_scaled_luca_hands.osim'];

        mass        = subjectInfo.Mass_kg;
        height      = subjectInfo.Height_cm/100;

        setupScaleXml_template  = bops.directories.templates.ScaleTool;                                             
        static_trial_folder     = {getfolders(session_folder,'Static',1).name};
        statictrcpath           = [session_folder fp static_trial_folder{1} fp 'marker_experimental.trc'];

        calculate_joint_centres(statictrcpath,setupScaleXml_template)                                                                      
        scaleModel(model_torsion_unscaled,model_scaled,setupScaleXml_template,statictrcpath,subjectInfo)            % scale model
%         applyLucaOptimizer(model_torsion_unscaled,model_scaled,10)                                                  % apply luca optimizer
%         adjust_model_Handsfield_regressions(in_model,out_model,mass,height,sex)                                     % 

        trialsNames         = {getfolders(session_folder,'Dynamic',1).name};
        template_so_xml     = [fileparts(modelsdir) '\templates\SO_setup.xml'];

        disp(['subject ' subject])
        for iTrial = 1:length(trialsNames)
            trialpath = [session_folder fp trialsNames{iTrial}];
            runIK(model_scaled,trialpath)                                                                           % ik
            runID(model_scaled,trialpath)                                                                           % id
            runSOandJRF(model_scaled,trialpath)                                                                     % so & jrf
        
        end
    end
end




%============================================================================================%
%============================================================================================%
%============================================================================================%
function scaleModel(originalModel, scaledModel,setupScaleXml_template,statictrcpath,subjectInfo)


if isfile(scaledModel)
    disp(['Scaled model already exists in: ' scaledModel])
    return 
end

Scale               = xml_read(setupScaleXml_template);
ScalePath           = fileparts(statictrcpath);
SessionFolder       = fileparts(ScalePath);
setup_scale_file    = [ScalePath fp 'Setup_Scale.xml'];

Scale.ScaleTool.mass    = subjectInfo.Mass_kg;                      % add subject subject demographics
Scale.ScaleTool.height  = subjectInfo.Height_cm*10;
Scale.ScaleTool.age     = subjectInfo.Age;

%% ----------------------------- CHECK MARKERS SCALE TOOL XML -----------------------------------------
trc             = load_trc_file(statictrcpath);
trc_markers     = fields(trc);
time_range      = [trc.Time(1) trc.Time(2)];
Measurements    = Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement;
MarkerSet       = Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask;
Nmeasuremtns    = length(Measurements);
checkScaleXML   = 0;
pairs_to_check  = {};
MarkerSetNames = {};

for i = (1:length(MarkerSet))                                                                                       % convert structure of markerset to names
    MarkerSetNames{i} = MarkerSet(i).ATTRIBUTE.name;
end

for i = flip(1:length(trc_markers))                                                                                 % delete trc markers that are not in the markerset
    iName = trc_markers{i};
    if ~contains(MarkerSetNames,iName)
        trc = rmfield(trc,trc_markers{i});
        trc_markers(i) = [];
    end
end

for iMeasure = 1:Nmeasuremtns                                                                                       % check if markers in the template scale tool exist in the trc file
    iName  = Measurements(iMeasure).ATTRIBUTE.name;
    MarkerPair = Measurements(iMeasure).MarkerPairSet.objects.MarkerPair;
    NmarkerPairs = length(MarkerPair);
    for iPair = 1:NmarkerPairs
        iMarkerNames  = split(MarkerPair(iPair).markers,' ');
        if any(~contains(iMarkerNames,trc_markers))
            checkScaleXML = 1;
            pairs_to_check{end+1} = iName;
        end
    end
end

if checkScaleXML == 1                                                                                               % if markers in  current scale tool do not correspond
    msg = ['please check scale tool marker pairs for'];
    for i = 1:length(pairs_to_check)
        msg = [msg sprintf('\n %s',pairs_to_check{i})];
    end
    winopen(setupScaleXml_template);
    msgbox(msg)
    return
end

for i = flip(1:length(MarkerSet))                                                                                   % delete the markers not contained in the trc
    iName = MarkerSet(i).ATTRIBUTE.name;
    if ~contains(trc_markers,iName)
        MarkerSet(i) = [];
    end
end


%% ------------------------------------- define paths -------------------------------------------------
generic_model_file  = relativepath(originalModel,ScalePath);
marker_file         = relativepath(statictrcpath,ScalePath);
output_motion_file  = relativepath([ScalePath fp 'static_output.mot'],ScalePath);
output_marker_file  = relativepath([ScalePath fp 'static_output.trc'],ScalePath);
model_file          = relativepath(scaledModel,ScalePath);
%% ------------------------------ create scale xml parameters -----------------------------------------
Scale.ATTRIBUTE.Version         = '30000';
Scale.ScaleTool.ATTRIBUTE.name  = subjectInfo.ID;

Scale.ScaleTool.GenericModelMaker.ATTRIBUTE.name    = '';                                                           % GenericModelMaker
Scale.ScaleTool.GenericModelMaker.model_file        = generic_model_file;
Scale.ScaleTool.GenericModelMaker.marker_set_file   = [fileparts(generic_model_file) fp 'FINAL_MARKERSET.xml'];

Scale.ScaleTool.ModelScaler.ATTRIBUTE.name      = '';                                                               % ModelScaler
Scale.ScaleTool.ModelScaler.marker_file         = marker_file;
Scale.ScaleTool.ModelScaler.time_range          = time_range;
Scale.ScaleTool.ModelScaler.output_scale_file   = relativepath(['.' fp 'Scale_output.xml'],ScalePath);

Scale.ScaleTool.MarkerPlacer.output_motion_file = output_motion_file;                                               % MarkerPlacer
Scale.ScaleTool.MarkerPlacer.output_model_file  = model_file;
Scale.ScaleTool.MarkerPlacer.output_marker_file = output_marker_file;
Scale.ScaleTool.MarkerPlacer.marker_file        = marker_file;
Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask = MarkerSet;
Scale.ScaleTool.MarkerPlacer.time_range         = time_range;

Scale.ScaleTool.COMMENT                     = [];                                                                   % COMMENTS
Scale.ScaleTool.MarkerPlacer.COMMENT        = [];
Scale.ScaleTool.GenericModelMaker.COMMENT   = [];
Scale.ScaleTool.ModelScaler.COMMENT         = [];
Nmeasurments = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement]);
for n=1:Nmeasurments
    Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).COMMENT=[];
    Npairs = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair]);
    for n2=1:Npairs
        Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair(n2).COMMENT=[];
    end
end
%% -------------------------------------- save xml ----------------------------------------------------
root = 'OpenSimDocument';                                                                                           % save xml
Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
setupScaleXML = [ScalePath fp 'Setup_Scale.xml'];
Scale = ConvertLogicToString(Scale);
xml_write(setupScaleXML, Scale, root,Pref);
cd(ScalePath)

dos(['opensim-cmd run-tool ' setupScaleXML],'-echo');                                                                           % run scale tool

cmdmsg('Model Scaled')

%============================================================================================%
function runIK(modelpath,trialpath)

cd(trialpath)
if isfile('ik.mot')
    disp(['ik.mot already exists in: ' trialpath])
    return 
end
[~,trial] = fileparts(trialpath);
disp(['ik for ' trial])
% Set paths to OpenSim libraries
import org.opensim.modeling.*;

% ImportC3D file and find timing based on events
c3d = btk_loadc3d([trialpath fp 'c3dfile.c3d']);
for i = 1:100
    c3d.Events.Events = TrimStruct (c3d.Events.Events,['C' num2str(i) '_']); % deelte "c_xx" in case events come from mokka
end
start_time = c3d.marker_data.First_Frame/c3d.marker_data.Info.frequency;

if length(fields(c3d.Events.Events)) > 2
    cell_time = struct2cell(c3d.Events.Events);
    time_range = cell_time{1};
    
else
    try
        time_range = [c3d.Events.Events.Right_Foot_Off c3d.Events.Events.Right_Foot_Strike];
    catch
        time_range = [c3d.Events.Events.Left_Foot_Off c3d.Events.Events.Left_Foot_Strike];
    end
end

time_range = time_range - start_time;

% Load OpenSim model and setup inverse kinematics tool
model = Model(modelpath);
ikTool = InverseKinematicsTool();
ikTool.setModel(model);

% copy model to the subject folder
[~,modelname,ext]   = fileparts(modelpath);
model_destidnation  = [fileparts(trialpath) fp modelname ext];
if ~isfile(model_destidnation)
    copyfile(modelpath,model_destidnation)
end

% set ik parameters
trcfilepath = ['.\marker_experimental.trc'];
ikTool.setMarkerDataFileName(trcfilepath);
ikTool.setStartTime(time_range(1));
ikTool.setEndTime(time_range(2));
ikTool.setOutputMotionFileName('.\ik.mot');
ikTool.print('.\setup_ik.xml');
ikTool.set_report_marker_locations(true);
ikTool.set_results_directory(trialpath)

% run tool
ikTool.run();

%============================================================================================%
function runID(modelpath,trialpath)

cd(trialpath)
if isfile('inverse_dynamics.sto')
    disp(['inverse_dynamics.sto already exists in: ' trialpath])
    return 
end

[~,trial] = fileparts(trialpath);
disp(['id for ' trial])

% Set paths to OpenSim libraries
import org.opensim.modeling.*;

idTool = InverseDynamicsTool();
model = Model(modelpath);
idTool.setModel(model);
idTool.setModelFileName(model.getDocumentFileName());

%Set Input
coordinates_file = [trialpath fp 'ik.mot'];
idTool.setCoordinatesFileName(coordinates_file);
idTool.setLowpassCutoffFrequency(6);

% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

idTool.setStartTime(initial_time);
idTool.setEndTime(final_time);

%Set folders
idTool.set_results_directory('.\');
idTool.setOutputGenForceFileName(['.\inverse_dynamics.sto']);

%Set forces_to_exclude
excludedForces = ArrayStr();
excludedForces.append('Muscles');
idTool.setExcludedForces(excludedForces);
idTool.setExternalLoadsFileName('.\GRF.xml');

%Print ID setup file
idTool.print(['.\setup_id.xml']);

%Run ID
idTool.run();

%============================================================================================%
function runSOandJRF(modelpath,trialpath)

cd(trialpath)
results_directory   = [trialpath];
coordinates_file    = [trialpath fp 'ik.mot'];
[~,trial] = fileparts(trialpath);

import org.opensim.modeling.*

% open osim model
OsimModel = Model(modelpath);

% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

%% Static Optimization
so = StaticOptimization();
so.setName('StaticOptimization');
so.setModel(OsimModel);

% Set other parameters as needed
so.setStartTime(initial_time);
so.setEndTime(final_time);
so.setMaxIterations(25);

% add to analysis tool
analyzeTool_SO = create_analysisTool(coordinates_file,modelpath,results_directory);
analyzeTool_SO.get().AnalysisSet.cloneAndAppend(so);
OsimModel.addAnalysis(so);

if ~isfile([results_directory fp '_StaticOptimization_force.sto'])
    % save setup file and run
    analyzeTool_SO.print(['setup_so.xml']);
    analyzeTool_SO=AnalyzeTool(['setup_so.xml']);

    disp(['so for ' trial])

    analyzeTool_SO.run();
else
    disp(['SO and JRA already exists in: ' results_directory])
end
%% Joint reaction analysis
jr = JointReaction();
jr.setName('joint reaction analysis');
jr.set_model(OsimModel);

inFrame = ArrayStr; onBody = ArrayStr; jointNames = ArrayStr;
inFrame.set(0,'parent'); 
onBody.set(0,'parent'); 
jointNames.set(0,'all');

jr.setInFrame(inFrame);
jr.setOnBody(onBody);
jr.setJointNames(jointNames);

% Set other parameters as needed
jr.setStartTime(initial_time);
jr.setEndTime(final_time);
jr.setForcesFileName([results_directory fp '_StaticOptimization_force.sto']);

% add to analysis tool
analyzeTool_JR = create_analysisTool(coordinates_file,modelpath,results_directory);;
analyzeTool_JR.get().AnalysisSet.cloneAndAppend(jr);
OsimModel.addAnalysis(jr);

if ~isfile([results_directory fp '_joint reaction analysis_ReactionLoads.sto'])
   
    % save setup file and run
    analyzeTool_JR.print(['setup_jra.xml']);
    analyzeTool_JR = AnalyzeTool(['setup_jra.xml']);

    disp(['jra for ' trial])

    analyzeTool_JR.run();

else
    disp(['JRA already exists in: ' results_directory])
end

%============================================================================================%
function analyzeTool = create_analysisTool(coordinates_file,modelpath,results_directory)
import org.opensim.modeling.*

% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();

%Set the model
model = Model(modelpath);

%% Analyze tool
analyzeTool=AnalyzeTool();
analyzeTool.setModel(model);
analyzeTool.setModelFilename(model.getDocumentFileName());

analyzeTool.setReplaceForceSet(false);
analyzeTool.setResultsDir(results_directory);
analyzeTool.setOutputPrecision(8)

if nargin >4  %Set actuators file    
    forceSet = ArrayStr();
    forceSet.append(force_set_files);
    analyzeTool.setForceSetFiles(forceSet);
end

% motData.print('.\states.sto');
% states = Storage('.\states.sto');
% analyzeTool.setStatesStorage(states);
analyzeTool.setInitialTime(initial_time);
analyzeTool.setFinalTime(final_time);

analyzeTool.setSolveForEquilibrium(false)
analyzeTool.setMaximumNumberOfSteps(20000)
analyzeTool.setMaxDT(1)
analyzeTool.setMinDT(1e-008)
analyzeTool.setErrorTolerance(1e-005)

analyzeTool.setExternalLoadsFileName('.\GRF.xml');
analyzeTool.setCoordinatesFileName(coordinates_file);
analyzeTool.setLowpassCutoffFrequency(6);

%============================================================================================%
function applyLucaOptimizer(reference_model,target_model,N_eval)
% Copyright (c) 2015 Modenese L., Ceseracciu, E., Reggiani M., Lloyd, D.G. %
% reference - 

% importing OpenSim libraries
import org.opensim.modeling.*
% importing muscle optimizer's functions
addpath(genpath('./Functions_MusOptTool'))
fp = filesep;

%=========== INITIALIZING FOLDERS AND FILES =============
% folders used by the script

DirElaborated           = fileparts(osimModel_targ_filepath);
OptimizedModel_folder   = DirElaborated;    % folder for storing optimized model
Results_folder          = [DirElaborated fp 'Results_LO'];
log_folder              = [DirElaborated fp 'Results_LO'];

checkFolder(OptimizedModel_folder);% creates results folder is not existing
checkFolder(Results_folder);

% reference model for calculating results metrics
osimModel_ref = Model(osimModel_ref_filepath);


%====== MUSCLE OPTIMIZER ========
% optimizing target model based on reference model fro N_eval points per
% degree of freedom
if ~exist(N_eval)
    N_eval = 10;
end

[osimModel_opt, SimsInfo{N_eval}] = optimMuscleParams(osimModel_ref_filepath, osimModel_targ_filepath, N_eval, log_folder);

%====== PRINTING OPT MODEL =======
% setting the output folder
if strcmp(OptimizedModel_folder,'') || isempty(OptimizedModel_folder)
    OptimizedModel_folder = targModel_folder;
end
% printing the optimized model
osimModel_opt.print(fullfile(OptimizedModel_folder, char(osimModel_opt.getName())));

%============================================================================================%
function adjust_model_Handsfield_regressions(in_model,out_model,mass,height,sex)
% by Daniel Devaprakash (Griffith University) (2020), Tamara Grant (2021), Basilio Goncalves (2021) 
% Update muscle volumes and then use them to calculate maximal isometric forces based
% Handsfield et al. 2014

import org.opensim.modeling.*

if ~exist(ModelOut)
    % Create model object
    model = Model(ModelIn);
    % Create reference for the maintained model state
    model.initSystem;
    
    %% Muscles in model
    muscles = model.getMuscles();
    nMuscles = muscles.getSize();
    
    % read b1 and b2 (regression equation coefficients based on Handsfield et al. 2014)
    % change path accordingly
    inF = "handsfieldRegressionCoefficients.xlsx";
    d = xlsread(inF);
    muscleInfo = struct();
    
    % Create a structure to store required information
    for ii = 0:nMuscles-1
        muscleInfo(ii+1).muscleNames = char(muscles.get(ii).getName());
        muscleInfo(ii+1).muscleOptFiberLength = muscles.get(ii).getOptimalFiberLength()*100;
        %   Here specific tension of the muscle is taken as 55; Thomas O' Brien 2010
        if contains(sex,'M')
            muscleInfo(ii+1).specificTension = 55;
        else
            muscleInfo(ii+1).specificTension = 57;
        end
        muscleInfo(ii+1).muscleForce = muscles.get(ii).getMaxIsometricForce();
        muscleInfo(ii+1).presentVolume = (muscleInfo(ii+1).muscleForce * muscleInfo(ii+1).muscleOptFiberLength)/muscleInfo(ii+1).specificTension;
        muscleInfo(ii+1).b1 = d(ii+1,1);
        muscleInfo(ii+1).b2 = d(ii+1,2);
    end
    
    % Calculate total lower limb muscle volume
    totalVolume = (47*mass*height) + 1285;
    
    % Recalculate volume for specific muscles
    [muscleInfo] = recalculateMuscleVolumes_RajModel(nMuscles, muscleInfo, totalVolume);
    
    for ii = 0:nMuscles-1
        muscleInfo(ii+1).updatedMuscleForce = (muscleInfo(ii+1).specificTension * muscleInfo(ii+1).updatedVolume)/muscleInfo(ii+1).muscleOptFiberLength;
    end
    muscles.get(muscleInfo(ii+1).muscleNames).setMaxIsometricForce(muscleInfo(ii+1).updatedMuscleForce);
    % Write the model to a new file
    model.print(ModelOut)
end

%============================================================================================%
function calculate_joint_centres(statictrcpath,setupScaleXml_template)
%Hip joint center computation according to Harrington et al J.Biomech 2006
%Developed by Zimi Sawacha <zimi.sawacha@dei.unipd.it>
%Modified by Claudio Pizzolato <claudio.pizzolato@griffithuni.edu.au>
%Modified by Basilio Gonvalves <basilio.goncalves@univie.ac.at>

trc             = load_trc_file(statictrcpath);
Rate            = 1/(trc.Time(2) - trc.Time(1));
trc_markers     = fields(trc);
Scale           = xml_read(setupScaleXml_template);
MarkerSet       = Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask;
MarkerSetNames  = {};

for i = (1:length(MarkerSet))                                                                                       % convert structure of markerset to names
    MarkerSetNames{i} = MarkerSet(i).ATTRIBUTE.name;
end
MarkerSetNames = ['Time' MarkerSetNames];

for i = flip(1:length(trc_markers))                                                                                 % delete trc markers that are not in the markerset
    iName = trc_markers{i};
    if ~contains(MarkerSetNames,iName)
        trc = rmfield(trc,trc_markers{i});
        trc_markers(i) = [];
    end
end

if contains(trc_markers,'RHJC')
    return
end

LASIS   = trc.LASI';   
RASIS   = trc.RASI';
SACRUM  = trc.SACR';
RHJC = []; LHJC = [];
for t=1:size(RASIS,2)

    %Global Pelvis Center position
    OP      = (LASIS(:,t)+RASIS(:,t))/2;        
    PROVV   = (RASIS(:,t)-SACRUM(:,t))/norm(RASIS(:,t)-SACRUM(:,t));  
    IB      = (RASIS(:,t)-LASIS(:,t))/norm(RASIS(:,t)-LASIS(:,t));    
    
    KB=IB.*PROVV;                               
    KB=KB/norm(KB);
    
    JB=KB.*IB;
    JB=JB/norm(JB);
      
    %rotation+ traslation in homogeneous coordinates (4x4)
    pelvis = [IB JB KB OP;  0 0 0 1];
    
    %Trasformation into pelvis coordinate system (CS)
    OPB = inv(pelvis)*[OP;1];    
       
    PW=norm(RASIS(:,t)-LASIS(:,t));
    PD=norm(SACRUM(:,t)-OP);
    
    %Harrington formulae (starting from pelvis center)
    diff_ap = -0.24 * PD - 9.9;
    diff_v  = -0.30 * PW - 10.9;
    diff_ml =  0.33 * PW + 7.3;
    
    %vector that must be subtract to OP to obtain hjc in pelvis CS
    vett_diff_pelvis_sx = [-diff_ml; diff_ap; diff_v; 1];
    vett_diff_pelvis_dx = [diff_ml; diff_ap; diff_v; 1];    
    
    %hjc in pelvis CS (4x4)
    rhjc_pelvis = OPB + vett_diff_pelvis_dx;  
    lhjc_pelvis = OPB + vett_diff_pelvis_sx;  
    

    %Transformation Local to Global
    RHJC(:,t) = pelvis(1:3,1:3,1) * [rhjc_pelvis(1:3,1)] + OP;
    LHJC(:,t) = pelvis(1:3,1:3,1) * [lhjc_pelvis(1:3,1)] + OP;
       
end

trc.RHJC=RHJC';
trc.LHJC=LHJC';

Labels_struct = fields(trc);
CompleteMarkersData = [];
for i = 1:length(Labels_struct)                                                                                     % convert trc struct into double (data) and cell (lables)
    field_data = trc.(Labels_struct{i});
    for col = 1:size(field_data,2)
        CompleteMarkersData(:,end+1) = field_data(:,col);                                                           
    end
end

Labels_struct(2:3)=[];
CompleteMarkersData(:,2:7) = [];

FullFileName = strrep(statictrcpath,'.trc','_HJC.trc');
writetrc(CompleteMarkersData,Labels_struct(2:end),Rate,FullFileName)


