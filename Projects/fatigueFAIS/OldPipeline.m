

%% select subject to analyse
Subjects = {'008'};  %select a few participant
%% all subjects without the not usable ones
Subjects = {'007','008','009','010',...
    '012','013','015','016','017','018','019','021','022','023','024','025',...
    '026','027','028','029','030','031','033','034','036','037','038','039',...
    '040','041','042','043','044','045','046','047','048','049','050','052','053','054',...
    '055','056','057','058','059','060','061','064','067','068','070','071','072',...
    '073','074','075','076','077'};
%% select multiple FAI participants and organise data
% [SubjectFoldersInputData,SubjectFoldersElaborated,sessionName] = smfai(DirMocap,sessionName,Subjects);
% Organise directories and Scripts
DirC3D = [SubjectFoldersInputData{1} fp sessionName];
OrganiseFAI
disp('==================================================================')
disp(['Directories created for ' Subject '- NOTE: these may need editing'])
disp('==================================================================')
%% check which steps of data processing have been done 
[ExistStrength,ExistID,ExistMA] =checkMA (DirElaborated);
% check data
SJ = GaitEventsMultiple(SubjectFoldersInputData(1),sessionName);
SJ = CheckAcqSteps(SubjectFoldersInputData,sessionName);
SJ = CheckEMGbadtrials(SubjectFoldersInputData,sessionName);
%% select analysis to run
list = {'Isometric tasks','MOtoNMS','inverse kinematics','inverse dynamics',...
    'residual reduction analysis','muscle analysis','CEINMS','induced acceleration analysis',...
    'joint reaction analysis','results paper 2'};
[indx,tf] = listdlg('ListString',list);
analysis = list(indx);
%% clear Bad trials (run when needed)
% based on the excel file called "ParticipantData and Labelling.xlsx"

% clearBadTrials(DirMocap,DirElaborated,Subject)
% MoveIKandIDFiles (Subject)
%% EMG check
% EMGcheck(SubjectFoldersInputData,sessionName);
TrialList = {'Run_baselineA1' 'Run_baselineB1' 'RunL1'};
checkEMGdata_dynamic (DirC3D,muscleString,TrialList) %single participant 
RunningEMGCheck(SubjectFoldersElaborated, sessionName) % multiple participants

[IsmEMG,NormEMG,maxTrial] = EMGNormDynamic(SessionDataDir, Isometrics_pre,DynamicTrials);
%% Batch isometric strength tasks
if  sum(contains(analysis,'Isometric tasks'))>0
    Batch_Isometric_FAI(SubjectFoldersInputData, sessionName)
    %     IsometricTroqrueEMG_meanPlots
end





%% CEINMS
if sum(contains(analysis,'CEINMS'))>0
    % select only participats that have 2 baseline trials
%     SubjectFoldersElaborated = find2RunningTrials (SubjectFoldersElaborated, sessionName);
    
    BatchCEINMS_FAI_BG (SubjectFoldersElaborated(1:end), sessionName)
    % FatigueModel(CEINMSdir)
    % https://simtk-confluence.stanford.edu/display/OpenSim/Design+of+a+Fatigable+Muscle
end

%% Induced acceleration analysis
if sum(contains(analysis,'induced acceleration analysis'))>0
% Logic = 1 (default); 1 = re-run trials / 0 = do not re-run trials 
    Logic = 1;
    BatchIAA_FAI_BG (SubjectFoldersElaborated(1:end), sessionName,'RRA',Logic)
end

%% Joint reaction analysis
if sum(contains(analysis,'joint reaction analysis'))>0
% Logic = 1 (default); 1 = re-run trials / 0 = do not re-run trials 
    Logic = 1;
    BatchJRA_FAI_BG (SubjectFoldersElaborated(1:end), sessionName,'IK',Logic)
end

%% Plot muscle forces from the CEINMS output
PlotsMeanStrength_FAI (SubjectFoldersElaborated, sessionName,1)
CheckEMG_FAI(DirElaborated)
PlotIAA_BG(SubjectFoldersElaborated,sessionName)

CompareMomentsRRA(DirID,trialName)

%% Mean biomehcanical data for mechanical work running paper (paper 2)
if sum(contains(analysis,'results paper 2'))>0
    PHD_Paper2_results
    % PHD_Paper2_results_April2020
end




%% Mean muscle forces and IAA (paper 3)

PHD_IAA_results

%% CEINMS results 
Trials = {'Run_baselineA1' 'Run_baselineB1'};
Results = ResultsCEINMS (CEINMSdir,Trials);
% plotMuscleForces(CEINMS_trialDir,side)


%% plot or load single tirals (choose)
IOSD        % import open sim data
POSD        % plot open sim data
CFc3d       % check initial contact from force plates in c3d files
LRFAI       % load results FAI (for an individual participant)
DirElaborated = strrep(DirElaborated,['\' Subject],'\028');
[DirElaborated,Joint,TrialName,Motions] = plotTrialPower (DirElaborated);

%% Run single trial IK
import org.opensim.modeling.*
trialName = 'Run_baselineB1';
IKxmlPath = [DirIK fp trialName fp 'setup_IK.xml'];
cd(fileparts(IKxmlPath))
[~,log_mes] = dos(['ik -S ' IKxmlPath],'-echo');

%% Run single trial ID
import org.opensim.modeling.*
trialName = 'Run_baseline1';
IDxmlPath = [DirID fp trialName fp 'setup_ID.xml'];
cd(fileparts(IDxmlPath))
[~,log_mes] = dos(['id -S ' IDxmlPath],'-echo');

CompareMomentsRRA(DirID,trialName)

%% Run single trial RRA

% run RRA and print log
% "adjust(Dir,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)"
trialName ='Run_baseline2';
ActuatorsRRA = [DirRRA fp trialName '\RRA\RRA_Actuators_FAI.xml'];
adjustActuatorXML(ActuatorsRRA,1,1,1,1,1,1,1,1);
TaskFile = [DirRRA fp trialName '\RRA\RRA_Tasks_FAI.xml'];
adjustTaskXML(TaskFile,1,1,0,1,1,1,1,0)
fileout = [DirRRA fp trialName '\RRA\RRA_setup.xml'];
cd(fileparts(fileout))
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

%% check delay forceplates

d = btk_loadc3d('E:\3-PhD\Data\MocapData\InputData\048\pre\RunL1.c3d');
FP1 = find(d.fp_data.GRF_data(1).F(:,end));
FP2 = find(d.fp_data.GRF_data(2).F(:,end));
FP3 = find(d.fp_data.GRF_data(3).F(:,end));
time = FP2(1)/2000;
