%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% script designed to organise directories to and match rquirements of
% MOtoNMS pipeline to analyse biomechanical data -  https://simtk.org/projects/motonms/
%
%
% organise directories and get data for one single participant
% data should be organised as below (see also example data):
%
%   NOTE - Folders withthin "" should be named exactly as shown for the code to work
%
%   MocapDir -> "InputData" -> Subject -> Session -> data(.c3d format)
%   MocapDir -> 'ParticipantData and Labelling.xlsx' (excel file with the
%   demographics



fp = filesep;
%% MOtoNMS directories
% define project suffix
suffix = '_FAI';



warning off
if exist('DirC3D','var') && contains(class(DirC3D),'char')
    [SubjFolder,SessionFolder] = fileparts(DirC3D);     % Subject dir & C3D folder name
else
    SessionFolder = 'pre';
end

if ~exist('SubjFolder','var') || ~contains(class(SubjFolder),'char')
    SubjFolder = uigetdir('',...
        'Select participant folder in the InputData folder');
end

DirC3D = [SubjFolder fp SessionFolder];

if ~isdir(DirC3D)
    warning ('session folder named "%s" does not exist',SessionFolder)
    cd (SubjFolder)
    DirC3D = uigetdir('',...
        'Select InputFolder  with .c3d files');
end

[SubjFolder,SessionFolder] = fileparts(DirC3D);     % Subject dir & C3D folder name

Files = dir(sprintf('%s\\%s',DirC3D,'*.c3d'));  % c3d files

[~,Subject] = DirUp(DirC3D,2);                  % subject ID

[DirMocap,~] = DirUp(DirC3D,3);                 % Mocap dir

DirElaborated = ([DirMocap,fp,'ElaboratedData',fp,...
    Subject,fp,SessionFolder]);                    %location of elaboration.xml file.

ElaborationFilePath = ([DirMocap fp 'ElaboratedData' fp,...
    Subject fp SessionFolder '\dynamicElaborations']); %location of elaboration.xml file.
mkdir (ElaborationFilePath);

DirStrengthData = ([DirElaborated fp 'StrengthData']);
mkdir (DirStrengthData);

TemplateAquisitionXMl = [DirMocap fp 'acquisition.xml'];
TemplateScaleXMl = [DirMocap fp 'scale_tool_FAI_BG.xml'];

%% Results directories
DirResults = ([DirMocap fp 'Results']);
mkdir(DirResults);
DirWoodway = ([erase(DirMocap,'\MocapData') fp...
    '\WoodwayTreadmill_data' fp Subject]);

DirResultsIsom = [DirResults fp 'HipIsometric'];
DirFigure = sprintf('%s\\Figures', fileparts(DirMocap));  %directory of figures

%% Demogrphics

getDemographicsFAI

%% Define trials to analyse

[Isometrics_pre,Isometrics_post,StaticTrial,DynamicTrials] = getTrialsFAI(DirC3D,SubjectsDemogr,labelsDemographics);
% DynamicTrials =DynamicTrials (contains(DynamicTrials,'L'));
%% open Sim / CEINMS directories

addpath(genpath(DirBopsTool));
DirTemplateXML = [DirBopsTool fp 'Templates'];
ModelName = 'Rajagopal2015_FAI.osim';
% location of the open sim generic model
DirTemplateModel = ([DirMocap fp ModelName]);
% location of the open sim SCALED model
model_file = [DirElaborated fp Subject '_' ModelName];
model_file_rra = [DirElaborated fp Subject '_' strrep(ModelName,'.osim','_rra.osim')];
model_file_LO = strrep(model_file_rra,'rra.osim','rra_opt_N5.osim');
muscleString = {'        VM','        VL','        RF','       GRA',...
        '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
        '        GL','       TFL','   GLUTMAX','   GLUTMED','      PIRI','    OBTINT','    QF'}; % the spaces are part of the names

% inverse kinematics
DirIK = [DirElaborated fp 'inverseKinematics']; 
mkdir(DirIK);

% inverse dynamics
DirID = [DirElaborated fp 'inverseDynamics']; 
mkdir(DirID);
TemplateSetupID = [DirMocap fp 'ID_setup_FAI.xml'];
TemplateGRF = [DirMocap fp 'runGRF.xml'];

% Residual reduction analysis 
DirRRA = [DirElaborated fp 'residualReductionAnalysis']; 
mkdir(DirRRA);
TemplateActuatorsRRA = [DirTemplateXML fp 'RRA' fp 'RRA_Actuators' suffix '.xml'];
TemplateTasksRRA = [DirTemplateXML fp 'RRA' fp 'RRA_Tasks' suffix '.xml'];
TemplateSetupRRA = [DirTemplateXML fp 'RRA' fp 'RRA_Setup'  suffix '.xml'];

% muscle analysis
DirMA = [DirElaborated fp 'muscleAnalysis']; 
mkdir(DirMA);
TemplateSetupMA = [DirMocap fp 'MA_setup.xml'];

% induced acceleration analysis
DirIAA = [DirElaborated fp 'inducedAccelerationAnalysis']; 
mkdir(DirIAA);
TemplateSetupIAA = [DirTemplateXML fp 'InducedAccelerationAnalysis' fp 'IAA_Setup'  suffix '.xml'];

% joint reaction analysis
DirJRA = [DirElaborated fp 'JointReactionAnalysis']; 
mkdir(DirJRA);
TemplateSetupJRA = [DirTemplateXML fp 'JCFProcessing' fp 'Setup_JCFAnalyze'  suffix '.xml'];


% static optimization 
DirSO = [DirElaborated fp 'StaticOpt']; 
mkdir(DirSO);
TemplateSetupSO = [DirTemplateXML fp 'StaticOptimization' fp 'SO_Setup'  suffix '.xml'];
TemplateActuatorsSO = [DirTemplateXML fp 'StaticOptimization' fp 'SO_Actuators'  suffix '.xml'];

% CEINMS executables dir directory (should be in the C: drive??)
CEINMSdir = [DirElaborated fp 'ceinms'];
DirExeCEINMS ='C:\CEINMS_2';
DirTemplatesCEINMS = [DirExeCEINMS fp 'real-time-preprocessing\Template'];
% Add CEINMS to your path
addpath(genpath(DirExeCEINMS));

