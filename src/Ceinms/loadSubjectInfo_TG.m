% This file will load your participant information for the CEINMS pipeline
% CEINMS_2 folder should be saved directly in the C: drive

%% Load subject info - run OrganiseFAI first 

%OrganiseFAI

fp = filesep;

baseDir = DirElaborated; % Base directory where CEINMS is stored
[Subject,Session] = fileparts(baseDir);
[~,Subject] = fileparts(Subject);               % Your participant within the CEINMS baseDir

demoDir = DirMocap;
side = TestedLeg;
CEINMSdir = [baseDir fp 'ceinms'];
trialsDir = [CEINMSdir fp 'trials'];
mkdir(trialsDir);
%%

% Change your dofList based on your DOFs and the study limb being analysed
if strcmp(side, 'L')
    dofList = {'hip_flexion_l', 'ankle_angle_l'}; % Left
else
    dofList = {'hip_flexion_r', 'ankle_angle_r'}; % Right limb
end

% opensim model
osimModelFilename = model_file; % The name of your linearly scaled OpenSim model

% Generate calibration and excitation setup information
uncalFileName = 'uncalibrated.xml'; % Uncalibrated subject model name
UncalibratedSubject = [CEINMSdir fp 'calibration' fp 'uncalibrated' fp uncalFileName]; %uncalibrated subject filename

% calibration configuration xml directory 
calibrationCfg = [CEINMSdir fp 'calibration' fp 'cfg' fp 'calibrationCfg.xml'];
subjectFilename = [CEINMSdir fp 'calibration' fp 'uncalibrated' fp 'uncalibrated.xml']; 
outputSubjectFilename = [CEINMSdir fp 'calibration' fp 'calibrated' fp 'calibratedSubject.xml']; 
excitationGeneratorFilename = [CEINMSdir fp 'excitationGenerators' fp 'excitationGenerator.xml'];

mkdir([CEINMSdir fp 'excitationGenerators']);
mkdir ([CEINMSdir fp 'calibration' fp 'uncalibrated']);
mkdir ([CEINMSdir fp 'calibration' fp 'calibrated']);

if contains(side,'L')
    %
    excitationGeneratorTemp = [DirTemplatesCEINMS fp 'excitationGenerator' fp 'excitationGenerator16to34_l.xml'];
    copyfile(excitationGeneratorTemp, excitationGeneratorFilename)
    % copy uncalibrated subject template to CEINMSdir 
    subjectFileTemp = [DirTemplatesCEINMS fp 'Subjects' fp 'uncalibrated_l.xml'];
    copyfile(subjectFileTemp, subjectFilename)

elseif contains(side,'R')
    %
    excitationGeneratorTemp = [DirTemplatesCEINMS fp 'excitationGenerator' fp 'excitationGenerator16to34_r.xml'];
    copyfile(excitationGeneratorTemp, excitationGeneratorFilename)
    % copy uncalibrated subject template to CEINMSdir 
    subjectFileTemp = [DirTemplatesCEINMS fp 'Subjects' fp 'uncalibrated_r.xml'];
    copyfile(subjectFileTemp, subjectFilename)
end

fprintf('Subject and excitationGenerator XML files generated from templates \n');

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
CeinmsExeDir = DirExeCEINMS; %from OrganiseFAI




