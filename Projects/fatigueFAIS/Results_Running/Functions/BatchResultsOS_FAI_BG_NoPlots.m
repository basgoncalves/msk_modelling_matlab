
function BatchResultsOS_FAI_BG_NoPlots (SubjectFoldersElaborated, sessionName)
tic

if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run analysis');
end

if ~exist ('sessionName')|| isempty(sessionName)
sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
sessionName = sessionPath{end};
end

%generate the first subject 
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};


for ff = 1:length(SubjectFoldersElaborated)
    
OldSubject = Subject;
folderParts = split(SubjectFoldersElaborated{ff},filesep);
Subject = folderParts{end};
DirIDResults = [strrep(SubjectFoldersElaborated{ff},OldSubject,Subject) filesep sessionName filesep 'inverseDynamics' filesep 'results'];
DirIKResults = [strrep(SubjectFoldersElaborated{ff},OldSubject,Subject) filesep sessionName filesep 'inverseKinematics' filesep 'Results'];
DirC3D = [strrep(SubjectFoldersElaborated{ff},'ElaboratedData','InputData') filesep sessionName];

fprintf('Cutting data for participant %s... \n',Subject)

OrganiseFAI

DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);

  if  ~exist(DirIKResults) ||  length(dir(DirIKResults))<3 || ~exist(DirIDResults) ||  length(dir(DirIDResults))<3
      continue
  end
%% select data for the plotting file

GaitCycleType = 2; %   GaitCycleType:  1 = Foot Strike to Foot strike, 2 = Toe off to Toe off


if contains(TestedLeg,'R','IgnoreCase',true)
    JointMotions.trunk = {'lumbar_extension','lumbar_bending','lumbar_rotation'};
    JointMotions.pelvis = {'pelvis_tilt','pelvis_list','pelvis_rotation'};  
    JointMotions.hip = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
    JointMotions.knee = {'knee_angle_r',};
    JointMotions.ankle = {'ankle_angle_r',};
    
    JointMom.pelvis={'pelvis_tilt_moment','pelvis_list_moment','pelvis_rotation_moment'};
    JointMom.trunk = {'lumbar_extension_moment','lumbar_bending_moment','lumbar_rotation_moment'};
    JointMom.hip = {'hip_flexion_r_moment','hip_adduction_r_moment','hip_rotation_r_moment'};
    JointMom.knee = {'knee_angle_r_moment',};
    JointMom.ankle = {'ankle_angle_r_moment',};

elseif contains(TestedLeg,'L','IgnoreCase',true)
    JointMotions.trunk = {'lumbar_extension','lumbar_bending','lumbar_rotation'};
    JointMotions.pelvis = {'pelvis_tilt','pelvis_list','pelvis_rotation'};  
    JointMotions.hip = {'hip_flexion_l','hip_adduction_l','hip_rotation_l'};
    JointMotions.knee = {'knee_angle_l',};
    JointMotions.ankle = {'ankle_angle_l',};
    
        
    JointMom.pelvis={'pelvis_tilt_moment','pelvis_list_moment','pelvis_rotation_moment'};
    JointMom.trunk = {'lumbar_extension_moment','lumbar_bending_moment','lumbar_rotation_moment'};
    JointMom.hip = {'hip_flexion_l_moment','hip_adduction_l_moment','hip_rotation_l_moment'};
    JointMom.knee = {'knee_angle_l_moment',};
    JointMom.ankle = {'ankle_angle_l_moment',};


end

%% results kinematics (in radians)

[IKresults,IKresultsNormalized, GaitCycle,BadTrials,Labels] = OSimKinematics ...
    (DirIKResults,TestedLeg,[JointMotions.hip JointMotions.knee JointMotions.ankle]);

cd(DirElaborated)
save IKresults IKresults IKresultsNormalized GaitCycle BadTrials Labels
fprintf('Inverse Kinematics trials cropped and converted to radians... \n')

%% results ID
fprintf('Cropping inverse dynamics trials ... \n')
[IDresults,IDresultsNormalized, GaitCycle,BadTrials,Labels] = OSimMoments...
    (DirIDResults,TestedLeg,[JointMom.hip JointMom.knee JointMom.ankle],MassKG);
cd(DirElaborated)
save IDresults IDresults IDresultsNormalized GaitCycle BadTrials Labels

fprintf('inverse dynamics trials cropped ... \n')

%% work loops
% 
% PlotOSimWork_NoPlots
% 
% 
%% work and power calculations

OSimPower_NoPlots
% 
% fprintf('Work and power finished...')

%% Done
fprintf('Cutting data finished for participant %s \n', Subject)


Run.GaitCycle = GaitCycle;
Run.Labels = Labels;
 cd(DirElaborated)
save RunningBiomechanics Run

end


%% Contact time and running velocity 

contactTime


% max velocity 
CheckTrialNames = {'Run_baselineA1';'Run_baselineB1';'RunA1';'RunB1';'RunC1';'RunD1';'RunE1';'RunF1';...
    'RunG1';'RunH1';'RunI1';'RunJ1';'RunK1';'RunL1'};

[velocityMax,LabelsVmax] = HorizontalVelocity_FAI_BG (SubjectFoldersElaborated, sessionName, CheckTrialNames);



tEnd = toc;

cd(DirMocap)
fileID = fopen('LogDataAnalysis.txt','a');
date = char(datetime);
txt = sprintf('Batch Results OS done in %.f participants on %s - time to run = %.fmin%.fsec \n',length(SubjectFoldersElaborated),date,floor(tEnd/60), rem(tEnd,60));
fprintf(fileID, txt);
fclose(fileID);