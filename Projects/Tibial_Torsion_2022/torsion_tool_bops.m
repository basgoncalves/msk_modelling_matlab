

function torsion_tool_bops(model_path,osim_version)

clc; close all;  % clean workspace (use restoredefaultpath if needed)
activate_msk_modelling
bops = load_setup_bops;

if ~contains(bops.directories.mainData,'TorsionToolAllModels')
    bops = setupbopstool;     
end

% if nargin < 1 || ~isfile(model_path)
%     model_path = [fileparts(mfilename('fullpath')) '\gait2392_genericsimplOS4_BG_markers.osim'];
% end
% 
% if nargin < 2
%     osim_version = 4;
% end
% 
% add_tosion_tool_to_path(osim_version,model_path)
% 
% % geneirc values (in degrees)
% legs = {'R'};
% 
% femurAnteversion_angles   = [0]; % anteversion angle (original = 17.6)
% femurNeckShaft_angles     = []; % neck-shaft angle (original = 123.3)
% [m,n] = ndgrid(femurAnteversion_angles,femurNeckShaft_angles);
% 
% femurTorsion_angles     = [m(:),n(:)];
% tibialTorsion_angles    = [-30,-15,0,15,30]; % tibial torsion angle (original = 0)
% 
% for iLeg = 1:length(legs)
%     which_leg   = legs{iLeg};
%     % apply all the femur rotations
%     deform_bone = 'F';
%     apply_bone_torsions(model_path,femurTorsion_angles,which_leg,deform_bone)
% 
%     % apply all the tibial rotations
%     deform_bone = 'T';
%     apply_bone_torsions(model_path,tibialTorsion_angles,which_leg,deform_bone)
% end


bops = load_setup_bops;
simulationsdir = 'C:\Git\research_data\TorsionToolAllModels\simulations';
subjects = {getfolders(simulationsdir).name};
sessions = {'pre', 'post'};
templatesdir = [bops.directories.templatesDir];

for i = 1:length(subjects)
    for ii = 1%:length(sessions)

        session_folder = [simulationsdir fp subjects{i} fp sessions{ii}];
        [subjectSettings] = load_subject_settings(subjects{i},sessions{ii});

        subjectInfo = getSubjectInfo(subjects{i});

        model_torsion_unscaled  = [session_folder fp 'FINAL_PERSONALISEDTORSIONS.osim'];
        model_torsion_scaled    = [session_folder fp 'PERSONALISEDTORSIONS_scaled.osim'];

        setupScaleXml_template  = bops.directories.templates.ScaleTool;                                             % scale model
        static_trial_folder     = {getfolders(session_folder,'Static').name};
        statictrcpath           = [session_folder fp static_trial_folder{1} fp 'marker_experimental.trc'];
        scaleModel(model_torsion_unscaled,model_torsion_scaled,setupScaleXml_template,statictrcpath,subjectInfo)
        
    end
end

    

%============================================================================================%
%=====================================CALLBACK FUNCTIONS=====================================%
%============================================================================================%
function add_tosion_tool_to_path(osim_version,model_path)

osim_version_str = ['osim' num2str(floor(osim_version))];

% get dir of the current file
activeFile = [mfilename('fullpath') '.m'];
mskmodelling_path = fileparts(fileparts(fileparts(activeFile)));

% if the mskmodelling pipeline is not in the path add it
try fp;catch; addpath(genpath(mskmodelling_path));end


% define dir of the torsion tool and check all the versions in the folder
torsion_tool_path = [mskmodelling_path fp 'src\TorsionTool-Veerkamp2021'];
torsion_tool_path_version = ([torsion_tool_path fp osim_version_str]);
all_versions = ls(torsion_tool_path);


% check which versions of the torsion tool ar in the path
onPath_current_version = is_on_path(torsion_tool_path_version);
onPath_other_versions = [];
for i = 3:size(all_versions,1)
    if ~isequal(strtrim(all_versions(i,:)), osim_version_str)
        onPath_other_versions(end+1) = is_on_path([torsion_tool_path fp strtrim(all_versions(i,:))]);
    end
end


% if none or more than one version are in the path
if onPath_current_version==0 || any(onPath_other_versions == 1)
    disp(['adding torsion tool for OpenSim version ' osim_version_str ' to the path'])
    warning off
    rmpath(genpath(torsion_tool_path))                      % remove all versions from path
    addpath(genpath(torsion_tool_path_version))             % add to path only the needed version
end


% if 
dir_model_path = fileparts(model_path);
if ~isfolder([dir_model_path fp 'femur'])
    
    fprintf('\n \n copying vtp files to the location of used model... \n \n')

    copyfile([torsion_tool_path_version fp 'femur'],[dir_model_path fp 'femur'])
    copyfile([torsion_tool_path_version fp 'tibia'],[dir_model_path fp 'tibia'])
    copyfile([torsion_tool_path_version fp 'calcn'],[dir_model_path fp 'calcn'])
    copyfile([torsion_tool_path_version fp 'talus'],[dir_model_path fp 'talus'])
    copyfile([torsion_tool_path_version fp 'toes'] ,[dir_model_path fp 'toes'])
end

%============================================================================================%
function apply_bone_torsions(model_path,Torsion_angles,which_leg,deform_bone)

[dir_contains_model,model,ext] = fileparts(model_path);
model = [model ext];
markerset = 'MarkerSet.xml';
cd(dir_contains_model)
if ~exist(markerset,'file')
    get_markerset_osim_model(model)
end

for i = 1:length(Torsion_angles)

    cd(dir_contains_model)
    if contains(deform_bone,'T')
        angle_TT        = Torsion_angles(i);
        TT_str          = strrep(num2str(angle_TT),'-','minus');
        deformed_model  = [which_leg '_TT_' TT_str];
        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_TT);
    else
        angle_AV = femurCombos(iFem,1);
        angle_NS = femurCombos(iFem,2);
        AV_str = strrep(num2str(angle_AV),'-','minus');
        NS_str = strrep(num2str(angle_NS),'-','minus');
        deformed_model = [which_leg '_NSA_' NS_str '_AVA_' AV_str];
        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_AV, angle_NS);
    end
end

%============================================================================================%
function scaleModel(originalModel, scaledModel,setupScaleXml_template,statictrcpath,subjectInfo)

Scale               = xml_read(setupScaleXml_template);
ScalePath           = fileparts(statictrcpath);
SessionFolder       = fileparts(ScalePath);
setup_scale_file    = [ScalePath fp 'Setup_Scale.xml'];

StaticTRCfile   = statictrcpath;
TRC             = load_trc_file(StaticTRCfile);

Scale.ScaleTool.mass    = subjectInfo.Mass_kg;                      % add subject subject demographics
Scale.ScaleTool.height  = subjectInfo.Height_cm*10;
Scale.ScaleTool.age     = subjectInfo.Age;

% ----------------------------- CHECK MARKERS SCALE TOOL XML -----------------------------------------
trc             = load_trc_file(StaticTRCfile);
trc_markers     = fields(trc);
Measurements    = Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement;
Nmeasuremtns    = length(Measurements);
checkScaleXML   = 0;
pairs_to_check  = {};

for i = 1:Nmeasuremtns                                                                                              % loop through all the body segments to scale
    iName  = Measurements(i).ATTRIBUTE.name;
    MarkerPair = Measurements(i).MarkerPairSet.objects.MarkerPair;
    NmarkerPairs = length(MarkerPair);
    for i = 1:NmarkerPairs
        iMarkerNames  = split(MarkerPair(i).markers,' ');
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
    winopen(bops.directories.templates.ScaleTool);
    msgbox(msg)
    return
end

MarkerSet = Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask;
for i = flip(1:length(MarkerSet))                                                                                   % loop from the last marker so deletes do not affect indexes
    iName = MarkerSet(i).ATTRIBUTE.name;
    if ~contains(trc_markers,iName)
        MarkerSet(i) = [];
    end
end

% -------------------------------------------        define paths
generic_model_file  = relativepath(originalModel,ScalePath);
marker_file         = relativepath(StaticTRCfile,ScalePath);
output_motion_file  = relativepath([ScalePath fp 'static_output.mot'],ScalePath);
output_marker_file  = relativepath([ScalePath fp 'static_output.trc'],ScalePath);
time_range          = [TRC.Time TRC.Time];
model_file          = relativepath(scaledModel,ScalePath);
% ------------------------------------------ create scale xml parameters
Scale.ATTRIBUTE.Version         = '30000';
Scale.ScaleTool.ATTRIBUTE.name  = SubjectInfo.ID;

Scale.ScaleTool.GenericModelMaker.ATTRIBUTE.name    = '';                                                           % GenericModelMaker
Scale.ScaleTool.GenericModelMaker.model_file        = generic_model_file;

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

root = 'OpenSimDocument';                                                                                           % save xml
Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
setupScaleXML = [ScalePath fp 'Setup_Scale.xml'];
Scale = ConvertLogicToString(Scale);
xml_write(setupScaleXML, Scale, root,Pref);
cd(ScalePath)

dos(['scale -S ' setupScaleXML],'-echo');                                                                           % run scale tool

cmdmsg('Model Scaled')

%============================================================================================%
function runIK(modelpath,trcfilepath)

% Set paths to OpenSim libraries
import org.opensim.modeling.*;

% Load OpenSim model and setup inverse kinematics tool
model = Model(modelpath);
ikTool = InverseKinematicsTool();
ikTool.setModel(model);

% Set input files
% ikTool.setCoordinatesFileName('subject_walk.xml');
ikTool.setMarkerFileName(trcfilepath);
ikTool.setStartTime(0);
ikTool.setEndTime(1.0);

% Set output files
ikTool.setOutputMotionFileName('ik_results.mot');
ikTool.setOutputMarkerFileName('virtual_markers.trc');

% Run inverse kinematics
ikTool.run();

% Load marker data from output file
data = importdata('virtual_markers.trc');
marker_labels = data.colheaders(3:end);
marker_data = data.data(:, 3:end);

% Print marker positions
disp('Virtual marker positions:');
disp(marker_labels);
disp(marker_data);


