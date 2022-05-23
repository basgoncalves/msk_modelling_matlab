% This file will load your participant information for the CEINMS pipeline
% CEINMS_2 folder should be saved directly in the C: drive

%% loadSubjectInfo
fp = filesep;

baseDir =DirElaborated; % Base directory where CEINMS is stored
[Subject,Session] = fileparts(baseDir);
[~,Subject] = fileparts(Subject);               % Your participant within the CEINMS baseDir

demoDir = DirMocap;
side = TestedLeg;
CEINMSdir = [baseDir fp 'ceinms'];
trialsDir = [CEINMSdir fp 'trials'];
mkdir(trialsDir);

%% templates directories

% configuration setup xml
templateCalSetup = [DirTemplatesCEINMS fp 'calibration' fp 'calibrationSetup.xml'];
% configuration calibration xml
templateCalCfg = [DirTemplatesCEINMS fp 'calibration' fp 'calibrationCfg_FAI.xml'];
% uncalibrated subject xml
templateSubject = [DirTemplatesCEINMS fp 'Subjects' fp 'subjectTemplate'];

% Change your dofList based on your DOFs and the study limb being analysed
if strcmp(side, 'L')
    dofList = {'hip_flexion_l', 'ankle_angle_l'}; % Left
else
    dofList = {'hip_flexion_r', 'ankle_angle_r'}; % Right limb
end

% opensim model
osimModelFilename = model_file; % The name of your linearly scaled OpenSim model

% Generate calibration and excitation setup information
mkdir([CEINMSdir fp 'calibration' fp 'uncalibrated']);
uncalFileName = 'uncalibrated.xml'; % Uncalibrated subject model name
subjectFilename = [CEINMSdir fp 'uncalibrated' fp uncalFileName ]; %uncalibrated subject filename


% calibration configuration xml directory 
calibrationFilename = [CEINMSdir fp 'calibration' fp 'cfg' fp 'calibrationCfg.xml'];

if contains(side,'L')
    %
    excitationGeneratorFilename = [DirTemplatesCEINMS fp 'excitationGenerator16to34_l.xml'];
    %
    subjectFilename = [DirTemplatesCEINMS fp 'Subjects' fp 'subjectTemplate_l.xml'];

elseif contains(side,'R')
    %
    excitationGeneratorFilename = [DirTemplatesCEINMS fp 'excitationGenerator16to34_r.xml'];
    %
    subjectFilename = [DirTemplatesCEINMS fp 'Subjects' fp 'subjectTemplate_r.xml'];

end
outputSubjectFilename = [CEINMSdir fp 'calibration' fp 'calibrated' fp 'calibratedSubject.xml']; 

% Generate calibration cfg information

% Generate execution cfg information

nmsModel_exe = 'Hybrid';                % type of nms model to use
exeDir = [CEINMSdir fp 'execution'];
pref = {};
sexualOrientation = 'Gaaaaayyyyy';
% DirTemplatesCEINMS = [demoDir fp 'CEINMS_xmlTemplates'];
setupExeDir = [DirTemplatesCEINMS fp 'executionSetup.xml'];
cfgExeDir = [DirTemplatesCEINMS fp 'executionCfg.xml'];
trialsDir = [CEINMSdir fp 'trials'];
excGenDir = [CEINMSdir fp 'excitationGeneration'];

% Run CEINMS directories
exeSetupDir = [exeDir fp 'Setup'];
CeinmsExeDir = DirExeCEINMS;




