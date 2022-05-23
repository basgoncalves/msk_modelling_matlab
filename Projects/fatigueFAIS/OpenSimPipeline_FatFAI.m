%% Basilio Goncalves 2020 PhD pipeline (Fatigue FAI)
% Before running this pipeline check the foolowing scripts and update
% directories, trial names and demographics
%   getdirFAI
%   getDemographicsFAI
%   getTrialsFAI
%   CEINMSsetup_FAI
%% Organise Data
clear; clc; close all; fp = filesep;
tmp = matlab.desktop.editor.getActive;
pwd=DirUp(fileparts(tmp.Filename),3);
MasterDir=[pwd fp 'MSKmodelling']; 
addpath(genpath(MasterDir));                                                                                        % rmpath(genpath(MasterDir)); 
OsimDirDefine                                                                                                       % check if OpenSim is set up
setupdirFAI
Dir=getdirFAI;                                                                                                      % EDIT THIS FUNCTION FOR a DIFFERENT PROJECT
% schemer_import('.\schemes\darksteel.prf');                                                                          % change theme to dark mode (not needed but I prefer it myself)

% Subjects
Studies = {'JointWork_RS' 'RS_FAI' 'JCFFAI' 'IAA' 'Walking' 'Cutting'};
[Subjects,Groups,Weights,~] = splitGroupsFAI(Dir.Main,Studies{3});
Subjects = Subjects(1:end);
% Subjects = {'009' '021' '028' '044'};

% Batch analysis 
ReRun=0; if ReRun==true; n=1; else, n=2 ;end %   Logic (after "suffix'): 1 = re-run trials(default) / 2 = do not re-run trials

% checkThroughFolders
% BatchC3D2MAT_FAI_BG(Subjects)
% CheckSubjects = BatchMOtoNMS_FAI_BG(Subjects);
% BatchLinearScaling_FAI_BG(Subjects(3))
% Batch_Isometric_FAI(Subjects)
% BatchIK_FAI_BG(Subjects,n)
% BatchID_FAI_BG (Subjects,n)
% BatchRRA_FAI_BG(Subjects([1]),n)
% BatchID_postRRA_BG(Subjects,n)
% BatchLucaOptimiser_FAI_BG(Subjects(1),n)
% BatchHandsfieldMuscleVolume_FAI_BG (Subjects(1:end))
% Batch_restoreOriginalMass(Subjects)
% BatchMA_FAI_BG(Subjects(1:end),n)
% BatchCEINMS_FAI_BG(Subjects(41:end),n) % CEINMSTroubleshoot
% BatchJRA_FAI_BG(Subjects(1:end),n)
BatchMuscleContributions(Subjects(4:end))
% BatchIAA_FAI_BG (Subjects(1:end),n)
% BatchStaticOpt_FAI_BG(Subjects(1)) % not finished
% Batch_PlotCEINMSresults(Subjects)
% [center_ace, radius_ace, midcup, psup_max, center_circ] = getAceSphere_midCup([Dir.Scale fp 'Scale_output.xml']);

%% CEINMS with walking calibration
HCFWalkingCalibration

%% Inspect data
InspectIsometricStrength(SubjectFoldersInputData, sessionName,suffix)
InspectEMGStrength(SubjectFoldersInputData, sessionName,suffix)
InspectEMG_Running(SubjectFoldersInputData, sessionName,suffix)
InspectEMG_Walking(SubjectFoldersInputData, sessionName,suffix)
 
for i = 1%length(SubjectFoldersElaborated)
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{1}); 
    EMGcheck(Dir.Main,SubjectInfo.ID,Trials.MaxEMG)
end

GroupsOfTrials = {'CutDominant'};                       % choose one or more from {'RunStraight' 'CutDominant' 'CutOpposite' 'Walking'}
ResultsDir = stoToMatOsim(Subjects,GroupsOfTrials,Dir.Results_ExternalBiomechanics);
PlotOSIMresults(ResultsDir,1)              % plot results

copyBadTrialsFileToElaboratedFolder(Subjects(1:21))
compareWeightScaleVSStaticGRF(Subjects)
rraWeigthComparison(Subjects)
MomentArmCheck_FAI_compare_withOGmodel

%% Mean biomehcanical data for mechanical work running paper (paper 2)
PHD_Paper2_results

%% External biomechanics before and after RS in FAIS,CAM and CON (paper 5)
PHD_RS_FAIS_results
cd([Dir.Paper_RSFAI fp 'Results\April2021'])
% MainResults_RSFAI

%% Results Joint contact forces and muscle forces in FAIS,CAM and CON - RUNNING
Dir=getdirFAI;  
Subjects=splitGroupsFAI(Dir.Main,'JCFFAI');
update={'MuscleVariables' 'MomentArms' 'ContactForces' 'externalBiomech' 'SpatioTemporal'}; 
PHD_JCF_FAIS_results(update([1]),Subjects(29:end),'run')
MuscleParamenters = GetMuscleParameters_FAI(Subjects);
cd([Dir.Paper_JCFFAI fp 'Results']) % ResultsScript_JCFFAIS
% GatherRRAresults(Subjects,[1:16]) 

%% Results Joint contact forces and muscle forces in FAIS,CAM and CON - CUTTING
Dir=getdirFAI;  
Subjects=splitGroupsFAI(Dir.Main,'JCFFAI');
update={'MuscleVariables' 'MomentArms' 'ContactForces' 'externalBiomech' 'SpatioTemporal'}; 
PHD_JCF_FAIS_results(update([1]),Subjects(1:end),'cut')
cd([Dir.Paper_JCFFAI fp 'Results']) % ResultsScript_JCFFAIS_cut

%% Strength report figures
Batch_StrengthReport_FAI(Subjects)

%% literature data 
Dir.LiteratureData=[MasterDir fp 'src\LiteratureData\DigitizedData'];
cd(Dir.LiteratureData);DigitizedData = csv2Mat_LiteratureData;
cd([Dir.Paper_JCFFAI fp 'Results']);

%% Random code!!!
M=[];SD=[];
sig = [65:70];
M(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS(sig,2));
M(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM(sig,2));
M(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control(sig,2));

SD(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS_upperSD(sig,2));
SD(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM_upperSD(sig,2));
SD(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control_upperSD(sig,2));
SD = SD-M;
M
mean(SD)

% anterior FAIS VS CAM (1 VS 2)

M=[];SD=[];
sig = [15:25];
M(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS(sig,2));
M(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM(sig,2));
M(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control(sig,2));

SD(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS_upperSD(sig,2));
SD(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM_upperSD(sig,2));
SD(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control_upperSD(sig,2));
SD = SD-M;
M
mean(SD)

% anterior FAIS VS CONTROL (1 VS 3)

M=[];SD=[];
sig = [70:81];
M(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS(sig,2));
M(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM(sig,2));
M(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control(sig,2));

SD(1) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_FAIS_upperSD(sig,2));
SD(2) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_CAM_upperSD(sig,2));
SD(3) = mean(DigitizedData.Catelli2021FrontActLiving.Anterior_control_upperSD(sig,2));
SD = SD-M;
M
mean(SD)