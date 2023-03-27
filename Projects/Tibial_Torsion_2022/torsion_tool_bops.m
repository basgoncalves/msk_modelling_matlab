

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

        model_torsion_unscaled  = [session_folder fp 'DEFORMED_MODEL\FINAL_PERSONALISEDTORSIONS.osim'];
        model_torsion_scaled    = [session_folder fp 'torsion_scaled.osim'];

        setupScaleXml_template  = bops.directories.templates.ScaleTool;                                             
        static_trial_folder     = {getfolders(session_folder,'Static').name};
        statictrcpath           = [session_folder fp static_trial_folder{1} fp 'marker_experimental.trc'];

        calculate_joint_centres(statictrcpath)                                                                      
        scaleModel(model_torsion_unscaled,model_torsion_scaled,setupScaleXml_template,statictrcpath,subjectInfo)    % scale model
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

Scale.ScaleTool.mass    = subjectInfo.Mass_kg;                      % add subject subject demographics
Scale.ScaleTool.height  = subjectInfo.Height_cm*10;
Scale.ScaleTool.age     = subjectInfo.Age;

%% ----------------------------- CHECK MARKERS SCALE TOOL XML -----------------------------------------
trc             = load_trc_file(statictrcpath);
trc_markers     = fields(trc);
time_range      = [trc.Time(1) trc.Time(end)];
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

%============================================================================================%
function calculate_joint_centres(statictrcpath)
%Hip joint center computation according to Harrington et al J.Biomech 2006
%Developed by Zimi Sawacha <zimi.sawacha@dei.unipd.it>
%Modified by Claudio Pizzolato <claudio.pizzolato@griffithuni.edu.au>
%Modified by Basilio Gonvalves <basilio.goncalves@univie.ac.at>

trc             = load_trc_file(statictrcpath);
trc_markers     = fields(trc);

if contains(trc_markers,'RHJC')
    return
end

LASIS   = trc.LASI';   
RASIS   = trc.RASI';
SACRUM  = trc.SACR';

for t=1:size(RASIS,2)

    %Global Pelvis Center position
    OP(:,t)=(LASIS(:,t)+RASIS(:,t))/2;    
    
    PROVV(:,t)=(RASIS(:,t)-SACRUM(:,t))/norm(RASIS(:,t)-SACRUM(:,t));  
    IB(:,t)=(RASIS(:,t)-LASIS(:,t))/norm(RASIS(:,t)-LASIS(:,t));    
    
    KB(:,t)=IB(:,t).*PROVV(:,t);                               
    KB(:,t)=KB(:,t)/norm(KB(:,t));
    
    JB(:,t)=KB(:,t).*IB(:,t);                               
    JB(:,t)=JB(:,t)/norm(JB(:,t));
    
    OB(:,t)=OP(:,t);
      
    %rotation+ traslation in homogeneous coordinates (4x4)
    pelvis(:,:,t)=[IB(:,t) JB(:,t) KB(:,t) OB(:,t);
                   0 0 0 1];
    
    %Trasformation into pelvis coordinate system (CS)
    OPB(:,t)=inv(pelvis(:,:,t))*[OB(:,t);1];    
       
    PW(t)=norm(RASIS(:,t)-LASIS(:,t));
    PD(t)=norm(SACRUM(:,t)-OP(:,t));
    
    %Harrington formulae (starting from pelvis center)
    diff_ap(t)=-0.24*PD(t)-9.9;
    diff_v(t)=-0.30*PW(t)-10.9;
    diff_ml(t)=0.33*PW(t)+7.3;
    
    %vector that must be subtract to OP to obtain hjc in pelvis CS
    vett_diff_pelvis_sx(:,t)=[-diff_ml(t);diff_ap(t);diff_v(t);1];
    vett_diff_pelvis_dx(:,t)=[diff_ml(t);diff_ap(t);diff_v(t);1];    
    
    %hjc in pelvis CS (4x4)
    rhjc_pelvis(:,t)=OPB(:,t)+vett_diff_pelvis_dx(:,t);  
    lhjc_pelvis(:,t)=OPB(:,t)+vett_diff_pelvis_sx(:,t);  
    

    %Transformation Local to Global
    RHJC(:,t)=pelvis(1:3,1:3,t)*[rhjc_pelvis(1:3,t)]+OB(:,t);
    LHJC(:,t)=pelvis(1:3,1:3,t)*[lhjc_pelvis(1:3,t)]+OB(:,t);
       
end

trc.RHJC=RHJC';
trc.LHJC=LHJC';

Labels_struct = fields(trc);
CompleteMarkersData = [];
for i = 2:length(Labels_struct)                                                                                     % convert trc struct into double (data) and cell (lables)
    field_data = trc.(Labels_struct{i});
    for col = 1:size(field_data,2)
        CompleteMarkersData(:,end+1) = field_data(:,col);                                                           
    end
end


Rate = 1/(trc.Time(2) - trc.Time(1));
FullFileName = statictrcpath;
writetrc(CompleteMarkersData,Labels_struct(3:end),Rate,FullFileName)


