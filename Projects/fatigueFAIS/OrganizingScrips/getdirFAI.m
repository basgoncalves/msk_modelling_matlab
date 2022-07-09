%% Basilio Goncalves (2020)
% [Dir,Temp,SubjectInfo,Trials,Fcut]=getdirFAI(SubjectFolder,sessionName,suffix,OSIMModelName,WalkingCalibration)
%
% SubjectFolder = String with directory of the InputData or ElaboratedData folders
% update to match the folder containing your "InputData" folder 
% following MOtoNMS pipeline (Mantoan et al. 2015)
% https://scfbm.biomedcentral.com/articles/10.1186/s13029-015-0044-4

function [Dir,Temp,SubjectInfo,Trials,Fcut]=getdirFAI(Subject,sessionName,suffix,OSIMModelName,WalkingCalibration)

fp = filesep; 
MasterDir=MasterSetup;
%% UPDATE this section ONLY
Dir=struct;Temp=struct; SubjectInfo=[]; Trials=struct; Fcut=struct;         % outputs empty files if stops early

path_dataDir    = [MasterDir fp 'Projects\fatigueFAIS\data_directory.dat'];
dataDir         = char(importdata(path_dataDir));
Dir.Main = dataDir;

try cd(Dir.Main)
catch;    cmdmsg([Dir.Main ' does not exist, update "getdirFAI.m" ']); % check if the folder and sessions exist
end

Dir.Results = [Dir.Main fp 'Results'];
Dir.Results_ExternalBiomechanics = [Dir.Results fp 'ExternalBiomechanics'];
Dir.Results_OptimalGamma = [Dir.Results fp 'CEINMS' fp 'OptimalGammas'];
Dir.Results_JointWorkRS = [Dir.Results fp 'JointWork_RS'];              % paper on repeated sprints healthy
Dir.Results_RSFAI = [Dir.Results fp 'RS_FAIS'];                         % repeated sprints FAI
Dir.Results_JCFFAI = [Dir.Results fp 'JCFFAI'];                         % joint contact forces in FAI

PapersDir = [DirUp(Dir.Main,3) fp '4- Papers_Presentations_Abstracts\Papers'];             % paper Dirs
Dir.Paper_RSFAI = [PapersDir fp 'Goncalves-RepeatedSprintsFAI'];                        % paper on repeated sprints in FAI
Dir.Paper_JCFFAI = [PapersDir fp 'Goncalves-HipJointContactForcesDuringSprintingFAIS']; % paper on joint contact forces Running in FAI
Dir.Paper_JCFFAI_cut = [PapersDir fp 'Goncalves-HCFCuttingFAIS'];                 % paper on joint contact forces cutting in FAI


if nargin==0; Subject= ''; return; end

if nargin<2 || isempty(sessionName); sessionName='pre'; end
if nargin<3 || isempty(suffix); suffix = '_FAI'; end        
if nargin<4 || isempty(OSIMModelName); OSIMModelName='Rajagopal2015';end                                 % name of the model without the suffix or .osim
if nargin<5 || isempty(WalkingCalibration); WalkingCalibration = 0; end        

Dir.Input = [Dir.Main fp 'InputData' fp Subject fp sessionName];
if ~isfolder([Dir.Input])
    cmdmsg([Dir.Input ' does not exist,check data folder name or update "getdirFAI.m" ']); % check if the folder and sessions exist
end

Dir.CEINMSexePath = [MasterDir fp 'src\Ceinms\CEINMS_2'];

SubjectInfo = getDemographicsFAI(Dir.Main,Subject); 
%% Predifine the directories to be used
% Elaboration 

Dir.Elaborated = ([Dir.Main fp 'ElaboratedData' fp Subject fp sessionName]);
Dir.StrengthData = [Dir.Elaborated fp 'StrengthData']; 
Dir.sessionData = [Dir.Elaborated fp 'sessionData']; 
Dir.dynamicElaborations = [Dir.Elaborated fp 'dynamicElaborations']; 
Dir.staticElaborations = [Dir.Elaborated fp 'staticElaborations'];
% external biomechanics
Dir.Scale = [Dir.Elaborated fp 'Scale']; 
Dir.IK = [Dir.Elaborated fp 'inverseKinematics']; 
Dir.ID = [Dir.Elaborated fp 'inverseDynamics']; 
Dir.RRA = [Dir.Elaborated fp 'residualReductionAnalysis']; 
% OpenSim modeling
Dir.MA = [Dir.Elaborated fp 'muscleAnalysis']; 
Dir.IAA = [Dir.Elaborated fp 'inducedAccelerationAnalysis']; 
Dir.SO = [Dir.Elaborated fp 'StaticOpt']; 
Dir.JRA = [Dir.Elaborated fp 'JointReactionAnalysis']; 
% CEINMS
Dir.CEINMS = [Dir.Elaborated fp 'ceinms']; 
Dir.CEINMScalibration= [Dir.CEINMS fp 'calibration'];
Dir.CEINMSexcitationGenerator = [Dir.CEINMS fp 'excitationGenerators'];
Dir.CEINMSexecution = [Dir.CEINMS fp 'execution'];
Dir.CEINMSsetup = [Dir.CEINMS fp 'execution' fp 'Setup'];
Dir.CEINMScfg = [Dir.CEINMS fp 'execution' fp 'Cfg'];
Dir.CEINMSsimulations = [Dir.CEINMS fp 'execution' fp 'simulations'];
Dir.CEINMStrials = [Dir.CEINMS fp 'trials'];
% Results directories
Dir.Results_RRA = [Dir.Results fp 'RRA' fp SubjectInfo.ID];
Dir.Results_CEINMS = [Dir.Results fp 'CEINMS' fp SubjectInfo.ID];
Dir.Results_JRA = [Dir.Results fp 'JRA' fp SubjectInfo.ID];
Dir.Results_StOpt = [Dir.Results fp 'StaticOpt' fp SubjectInfo.ID];

warning off
F = fields(Dir); 
F(contains(F,'Input'))=[];
for i = 1:length(F); mkdir(Dir.(F{i})); end       % crete directories

Dir.ErrorsCEINMS = [Dir.Results fp 'CEINMS' fp 'ErrorsCEINMS.mat'];
if ~exist(Dir.ErrorsCEINMS)
    R2=struct;
    RMSE=struct;
    save(Dir.ErrorsCEINMS,'R2','RMSE')
end

Dir.OSIM_LinearScaled = [Dir.Elaborated fp Subject '_' OSIMModelName suffix '.osim'];
Dir.OSIM_RRA = strrep(Dir.OSIM_LinearScaled,'.osim','_rra.osim');
Dir.OSIM_LO = strrep(Dir.OSIM_LinearScaled,'.osim','_rra_opt_N10.osim');
Dir.OSIM_LO_HANS = strrep(Dir.OSIM_LinearScaled,'.osim','_rra_opt_N10_hans.osim');
Dir.OSIM_LO_HANS_originalMass = strrep(Dir.OSIM_LinearScaled,'.osim','_originalMass_opt_N10_hans.osim');

Dir.WakingEvents = [Dir.Main fp 'WalkingGaitEvents.xlsx'];

%% template directories
DirTemplateXML = [MasterDir fp 'src\bops_tool\Templates'];
Dir.LiteratureData = [DirUp(DirTemplateXML,2) fp 'LiteratureData'];
Temp.Acq = [DirTemplateXML fp 'MOtoNMS' fp 'acquisition' suffix '.xml'];
Temp.Elaboration = [DirTemplateXML fp 'MOtoNMS' fp 'elaboration' suffix '.xml'];
Temp.Model = [DirTemplateXML fp 'Models' fp OSIMModelName suffix '.osim'];
Temp.ScaleTool = [DirTemplateXML fp 'LinearScaling' fp 'ScaleTool' suffix '.xml'];
Temp.Static = [DirTemplateXML fp 'LinearScaling' fp 'static' suffix '.xml'];
Temp.IKSetup = [DirTemplateXML fp 'IKProcessing' fp 'IKsetup' suffix '.xml'];
Temp.GRF = [DirTemplateXML fp 'IDProcessing' fp 'externalForces_RL' suffix '.xml'];
Temp.IDSetup = [DirTemplateXML fp 'IDProcessing' fp 'IDsetup' suffix '.xml'];
Temp.RRAActuators = [DirTemplateXML fp 'RRA' fp 'RRA_Actuators' suffix '.xml'];
Temp.RRATaks = [DirTemplateXML fp 'RRA' fp 'RRA_Tasks' suffix '.xml'];
Temp.RRASetup = [DirTemplateXML fp 'RRA' fp 'RRA_Setup'  suffix '.xml'];
Temp.RRASetup_actuation_analyze = [DirTemplateXML fp 'RRA' fp 'RRA_Setup_actuation_analyze'  suffix '.xml'];
Temp.MASetup = [DirTemplateXML fp 'MuscleAnalysis' fp 'MA_setup' suffix '.xml'];
Temp.IAASetup = [DirTemplateXML fp 'InducedAccelerationAnalysis' fp 'IAA_Setup'  suffix '.xml'];
Temp.SOSetup = [DirTemplateXML fp 'StaticOptimization' fp 'SO_Setup'  suffix '.xml'];
Temp.SOActuators = [DirTemplateXML fp 'StaticOptimization' fp 'SO_Actuators'  suffix '.xml'];
Temp.JRAsetup = [DirTemplateXML fp 'JCFProcessing' fp 'Setup_JCFAnalyze'  suffix '.xml'];

Temp.CEINMSuncalibratedmodel = [DirTemplateXML fp 'CEINMS' fp 'uncalibrated_RL' suffix '.xml'];
Temp.CEINMScfgCalibration = [DirTemplateXML fp 'CEINMS' fp 'calibrationCfg_RL' suffix '.xml'];
Temp.CEINMScfgCalibration_HJCF = [DirTemplateXML fp 'CEINMS' fp 'calibrationCfg_RL_HJCF' suffix '.xml'];
Temp.CEINMSexcitationGenerator = [DirTemplateXML fp 'CEINMS' fp 'excitationGenerator16to34_' ...
    lower(SubjectInfo.TestedLeg) '_StaticOPT_' lower(SubjectInfo.ContralateralLeg) '.xml'];
Temp.CEINMSsetupExe = [DirTemplateXML fp 'CEINMS' fp 'executionSetup' suffix '.xml'];
Temp.CEINMScfgExe = [DirTemplateXML fp 'CEINMS' fp 'executionCfg' suffix '.xml'];
Temp.CEINMScontactmodel = [DirTemplateXML fp 'CEINMS' fp 'contactOpenSimModel' suffix '.xml'];

%% Define trials to analyse 
% delete letters that don not want to include in the running or cutting trials 
% {'baseline' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P'};
TrialsToUse = {'baseline' 'runA' 'runB' 'runC' 'runD' 'runE' 'runF' 'runG' 'runH' 'runI'...
    'runJ' 'runK' 'runL' 'runM' 'runN' 'runO' 'runP' 'walking'} ;
Trials = getTrialsFAI(Dir,TrialsToUse,WalkingCalibration,SubjectInfo.TestedLeg);
    
%% filtering settings

Fcut.Markers = 10; Fcut.EMGbp = [50 500];
Fcut.EMGlp = 6; Fcut.Force = 10;