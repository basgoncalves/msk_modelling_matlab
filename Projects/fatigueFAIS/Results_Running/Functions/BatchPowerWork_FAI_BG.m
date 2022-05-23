function BatchPowerWork_FAI_BG (SubjectFoldersElaborated, sessionName)

if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
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

fprintf('ploting participant %s... \n',Subject)

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


%% work loops
% 
% PlotOSimWork
% PlotOSimWork_merged

%% Power plot

PlotOSimPower

%% Done
fprintf('Plots finished for participant %s \n', Subject)
end