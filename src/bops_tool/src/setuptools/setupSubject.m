
% [Dir,Temp,SubjectInfo,Trials,Fcut]=getdirbops(SubjectFolder,sessionName,suffix,OSIMModelName,WalkingCalibration)
%
% SubjectFolder = String with directory of the InputData or ElaboratedData folders
% update to match the folder containing your "InputData" folder 
% following MOtoNMS pipeline (Mantoan et al. 2015)
% https://scfbm.biomedcentral.com/articles/10.1186/s13029-015-0044-4
%
% by Basilio Goncalves (2020) basilio.goncalves7@gmail.com

function [settings] = setupSubject(subject,session)

bops = load_setup_bops;
settings.directories = struct;                                                                                      % outputs empty files if stops early
settings.subjectInfo = struct; 
settings.ceinms = struct; 

if nargin==0                                                                                                        % if there is no subject input return empty structs 
    subject = bops.current.subject;
    session = bops.current.session;
end

%% Predifine the directories to be used

subjectInfo = getSubjectInfo(subject); 

mainDataDir = bops.directories.mainData;                                                                            % Directory of "Data" containing "BOPS", "InputData", "visual3D",...)

directories.Input = [mainDataDir fp 'InputData' fp subject fp session];

directories.Elaborated = [mainDataDir fp 'ElaboratedData' fp subject fp session];                                   % elaboration: c3D to mat / osim formats
directories.StrengthData = [directories.Elaborated fp 'StrengthData']; 
directories.sessionData = [directories.Elaborated fp 'sessionData']; 
directories.dynamicElaborations = [directories.Elaborated fp 'dynamicElaborations']; 
directories.staticElaborations = [directories.Elaborated fp 'staticElaborations'];

directories.Scale = [directories.Elaborated fp 'Scale'];                                                            % external biomechanics
directories.IK = [directories.Elaborated fp 'inverseKinematics']; 
directories.ID = [directories.Elaborated fp 'inverseDynamics']; 
directories.RRA = [directories.Elaborated fp 'residualReductionAnalysis']; 

directories.MA = [directories.Elaborated fp 'muscleAnalysis'];                                                      % msk modeling
directories.IAA = [directories.Elaborated fp 'inducedAccelerationAnalysis']; 
directories.SO = [directories.Elaborated fp 'StaticOpt']; 
directories.JRA = [directories.Elaborated fp 'JointReactionAnalysis']; 
directories.CMC = [directories.Elaborated fp 'ComputedMuscleControl']; 
directories.EMG_Check = [directories.Elaborated fp 'EMG_Check']; 

directories.CEINMS = [directories.Elaborated fp 'ceinms'];                                                          % CEINMS
directories.CEINMScalibration= [directories.CEINMS fp 'calibration'];
directories.CEINMSexcitationGenerator = [directories.CEINMS fp 'excitationGenerators'];
directories.CEINMSexecution = [directories.CEINMS fp 'execution'];
directories.CEINMSsetup = [directories.CEINMS fp 'execution' fp 'Setup'];
directories.CEINMScfg = [directories.CEINMS fp 'execution' fp 'Cfg'];
directories.CEINMSsimulations = [directories.CEINMS fp 'execution' fp 'simulations'];
directories.CEINMStrials = [directories.CEINMS fp 'trials'];

resultsDir = bops.directories.Results;
directories.Results_RRA = [resultsDir fp 'RRA' fp subjectInfo.ID];                                                  % results directories per subject                                                         
directories.Results_CEINMS = [resultsDir fp 'CEINMS' fp subjectInfo.ID];
directories.Results_OptimalGamma = [resultsDir fp 'OptimalGammas'];
directories.Results_JRA = [resultsDir fp 'JRA' fp subjectInfo.ID];
directories.Results_StOpt = [resultsDir fp 'StaticOpt' fp subjectInfo.ID];

warning off
F = fields(directories); 
F(contains(F,'Input'))=[];
for i = 1:length(F); mkdir(directories.(F{i})); end                                                                 % create directories

directories.ErrorsCEINMS = [resultsDir fp 'CEINMS' fp 'ErrorsCEINMS.mat'];
if ~exist(directories.ErrorsCEINMS)
    R2=struct;
    RMSE=struct;
    save(directories.ErrorsCEINMS,'R2','RMSE')
end

directories.sessionSettings = [directories.Elaborated fp 'settings.xml']; 
directories.acquisitionXML  = [directories.Input fp 'acquisition.xml']; 
directories.elaborationXML  = [directories.dynamicElaborations fp 'elaboration.xml']; 
directories.staticXML       = [directories.staticElaborations fp 'static.xml']; 

try  models = split(importdata([bops.directories.modelsCSV]),','); 
catch models = [];
end

if ~isempty(models)                                                                                                 % use this section to allow for different models per participant
       
    models          = cell2struct(models(2:end,:),models(1,:),2);
     
    rowsID          = find(contains({models.ID},subject));
    rowsSession     = find(contains({models.session},bops.current.session));
    model_to_use    = models(intersect(rowsID,rowsSession)).model;
    
    generic_model_file = [bops.directories.templatesDir fp model_to_use '.osim'];
else
    generic_model_file = bops.directories.templates.Model;
end

directories.OSIM_generic                = generic_model_file;
directories.OSIM_LinearScaled           = [directories.Elaborated fp subject '_linearScalled.osim'];
directories.OSIM_RRA                    = strrep(directories.OSIM_LinearScaled,'.osim','_rra.osim');
directories.OSIM_LO                     = strrep(directories.OSIM_LinearScaled,'.osim','_rra_opt_N10.osim');
directories.OSIM_LO_HANS                = strrep(directories.OSIM_LinearScaled,'.osim','_rra_opt_N10_hans.osim');
directories.OSIM_LO_HANS_originalMass   = strrep(directories.OSIM_LinearScaled,'.osim','_originalMass_opt_N10_hans.osim');

RRA_trials                              = cellstr(ls(directories.RRA)); RRA_trials(1:2) = [];

for iTrial = 1:length(RRA_trials)
    directories.OSIM_RRA_PerTrial(iTrial).TrialName = RRA_trials{iTrial};
    
    modeldir = [directories.RRA fp RRA_trials{iTrial} fp 'Results_Final' fp subject '_linearScalled_MIMF_FINAL.osim'];
    if exist(modeldir,'file')
        directories.OSIM_RRA_PerTrial(iTrial).ModelDir  = modeldir;
    else
        directories.OSIM_RRA_PerTrial(iTrial).ModelDir  = '';
    end
end
%% CEINMS settings
s = lower(subjectInfo.InstrumentedSide);

ceinms = struct;
ceinms.Alphas = 1;
ceinms.Betas = [50];
ceinms.Gammas = [1 100:100:1000];
ceinms.dofList_calibration = [['hip_flexion_' s] [' knee_angle_' s] [' ankle_angle_' s]]; 
ceinms.dofList = [['hip_flexion_' s] [' hip_adduction_' s] [' hip_rotation_' s] ...
    [' knee_angle_' s] [' ankle_angle_' s]]; 
ceinms.nmsModel_exe = 'Hybrid';                                                                                     % type of nms model to use
ceinms.osimModelFilename = directories.OSIM_LO_HANS_originalMass;
ceinms.exeCfg = [directories.CEINMScfg fp 'executionCfg.xml'];
ceinms.subjectFilename = [directories.CEINMScalibration fp 'uncalibrated.xml'];                                     % uncalibrated subject filename
ceinms.calibrationCfg = [directories.CEINMScalibration fp 'calibrationCfg.xml'];
ceinms.calibrationSetup  = [directories.CEINMScalibration fp 'calibrationSetup.xml']; 
ceinms.outputSubjectFilename = [directories.CEINMScalibration fp 'calibratedSubject.xml']; 
ceinms.excitationGeneratorFilename = [directories.CEINMSexcitationGenerator fp 'excitationGenerator.xml'];
ceinms.excitationGeneratorFilename2ndCal = [directories.CEINMSexcitationGenerator fp 'excitationGenerator_2ndcal.xml'];
ceinms.excitationGeneratorFilenameStaicOpt = [directories.CEINMSexcitationGenerator fp 'excitationGenerator_StaicOpt.xml'];
ceinms.contactModel = [directories.CEINMScalibration fp 'contactModel.xml'];                                                 
% CEINMS.vars = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMS.osimModelFilename,split(CEINMS.dofList,' '));

settings.subjectInfo    = subjectInfo; 
settings.directories    = directories;            
settings.ceinms         = ceinms;
trialList               = strrep(cellstr(selectTrialNames(directories.Input,'.c3d')),'.c3d','');

settings.trials                 = struct;
settings.trials.trialList       = trialList;
settings.trials.dynamicTrials   = trialList(contains(trialList,bops.Trials.Dynamic));
settings.trials.staticTrials    = trialList(contains(trialList,bops.Trials.Static));
settings.trials.maxEMGTrials    = trialList(contains(trialList,bops.Trials.MaxEMG));

settings.trials.CEINMScalibration = trialList;


if isfile(directories.sessionSettings)                                                                              % check if xml file already exists
    og_settings = xml_read(directories.sessionSettings);
    printXML = compareStructs(og_settings,settings);
else
    printXML = 0;
end

if printXML == 0                                                                                                    % save new xml if original bops is different from the new one
    Pref.StructItem = false;
    xml_write(directories.sessionSettings,settings,'bops',Pref);
end

