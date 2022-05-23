% This file will load your participant information for the CEINMS pipeline
% CEINMS_2 folder should be saved directly in the C: drive

%% CEINMS_setup

function Param = CEINMSsetup_FAI(Dir,Temp,SubjectInfo)

fp = filesep;

%%
Param = struct;
s = lower(SubjectInfo.TestedLeg);
% Change your dofList based on your DOFs and the study limb being analysed

% Param.dofList = ['hip_flexion_r', ' hip_adduction_r', ' hip_rotation_r',...
%     ' knee_angle_r', ' ankle_angle_r',...
%     ' hip_flexion_l', ' hip_adduction_l', ' hip_rotation_l',...
%     ' knee_angle_l',' ankle_angle_l']; 

% Param.dofList = ['hip_flexion_r',' knee_angle_r', ' ankle_angle_r',...
%     ' hip_flexion_l',' knee_angle_l',' ankle_angle_l']; 

Param.Alphas = 1;
Param.Betas = [50];
Param.Gammas = [1 100:100:1000];
Param.dofList_calibration = [['hip_flexion_' s] [' knee_angle_' s] [' ankle_angle_' s]]; 
Param.dofList = [['hip_flexion_' s] [' hip_adduction_' s] [' hip_rotation_' s] [' knee_angle_' s] [' ankle_angle_' s]]; 
Param.nmsModel_exe = 'Hybrid';                % type of nms model to use
Param.osimModelFilename = Dir.OSIM_LO_HANS_originalMass;
Param.exeCfg = [Dir.CEINMScfg fp 'executionCfg.xml'];

% opensim model
if ~exist(Param.osimModelFilename)
    cmdmsg(['Model does not exist: ' Param.osimModelFilename ])
    return
end

Param.subjectFilename = [Dir.CEINMScalibration fp 'uncalibrated.xml']; %uncalibrated subject filename
Param.calibrationCfg = [Dir.CEINMScalibration fp 'calibrationCfg.xml'];
Param.calibrationSetup  = [Dir.CEINMScalibration fp 'calibrationSetup.xml']; 
Param.outputSubjectFilename = [Dir.CEINMScalibration fp 'calibratedSubject.xml']; 
Param.excitationGeneratorFilename = [Dir.CEINMSexcitationGenerator fp 'excitationGenerator.xml'];
Param.excitationGeneratorFilename2ndCal = [Dir.CEINMSexcitationGenerator fp 'excitationGenerator_2ndcal.xml'];
Param.excitationGeneratorFilenameStaicOpt = [Dir.CEINMSexcitationGenerator fp 'excitationGenerator_StaicOpt.xml'];
Param.contactModel = [Dir.CEINMScalibration fp 'contactModel.xml']; %uncalibrated subject filename

Param.vars = getOSIMVariablesFAI(SubjectInfo.TestedLeg,Param.osimModelFilename,split(Param.dofList,' '));




