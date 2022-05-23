function BatchResultsOS_FAI_BG (SubjectFoldersElaborated, sessionName)

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

%% plot kinematics

% [IKresults.pelvis,IKresultsNormalized.pelvis, GaitCycle,BadTrials,Labels] = PlotOSimKinematics (DirIKResults,DirC3D,TestedLeg,GaitCycleType,JointMotions.pelvis,[-30 30]);
% cd (DirFigRunBiomech)
% saveas(gca, 'pelvisKinmatics.jpeg')
% 
% [IKresults.trunk,IKresultsNormalized.trunk, GaitCycle,BadTrials,Labels] = PlotOSimKinematics (DirIKResults,DirC3D,TestedLeg,GaitCycleType,JointMotions.trunk);
% cd (DirFigRunBiomech)
% saveas(gca, 'trunkKinematics.jpeg')


[IKresults.hip,IKresultsNormalized.hip, GaitCycle,BadTrials,Labels.hip] = PlotOSimKinematics ...
    (DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMotions.hip]);
cd (DirFigRunBiomech)
saveas(gca, 'hipKinematics.jpeg')

[IKresults.knee,IKresultsNormalized.knee, GaitCycle,BadTrials,Labels.knee] = PlotOSimKinematics ...
    (DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMotions.knee]);
cd (DirFigRunBiomech)
saveas(gca, 'kneeKinematics.jpeg')

[IKresults.ankle,IKresultsNormalized.ankle, GaitCycle,BadTrials,Labels.ankle] = PlotOSimKinematics ...
    (DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMotions.ankle]);
cd (DirFigRunBiomech)
saveas(gca, 'ankleKinematics.jpeg')

[IKresults.all,IKresultsNormalized.all, GaitCycle,BadTrials,Labels.all] = PlotOSimKinematics ...
    (DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMotions.hip JointMotions.knee JointMotions.ankle]);
cd (DirFigRunBiomech)
saveas(gca, 'allKinematics.jpeg')

close all

cd(DirIKResults)
save IKresults IKresults IKresultsNormalized GaitCycle BadTrials Labels

%% plot ID

 
% [IDresults.pelvis,IDresultsNormalized.pelvis, GaitCycle,BadTrials,Labels] = PlotOSimMoments (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,JointMom.pelvis,MassKG);
% cd (DirFigRunBiomech)
% saveas(gca, 'pelvisMoments.jpeg')
% 
% [IDresults.trunk,IDresultsNormalized.trunk, GaitCycle,BadTrials,Labels] = PlotOSimMoments (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,JointMom.trunk,MassKG);
% cd (DirFigRunBiomech)
% saveas(gca, 'trunkMoments.jpeg')


[IDresults.hip,IDresultsNormalized.hip, GaitCycle,BadTrials,Labels.hip] = PlotOSimMoments...
    (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMom.hip],MassKG);
cd (DirFigRunBiomech)
saveas(gca,'hipMoments.jpeg')

[IDresults.knee,IDresultsNormalized.knee, GaitCycle,BadTrials,Labels.knee] = PlotOSimMoments...
    (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMom.knee],MassKG);
cd (DirFigRunBiomech)
saveas(gca,'kneeMoments.jpeg')

[IDresults.ankle,IDresultsNormalized.ankle, GaitCycle,BadTrials,Labels.ankle] = PlotOSimMoments...
    (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMom.ankle],MassKG);
cd (DirFigRunBiomech)
saveas(gca,'ankleMoments.jpeg')

[IDresults.all,IDresultsNormalized.all, GaitCycle,BadTrials,Labels.all] = PlotOSimMoments...
    (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,[JointMom.hip JointMom.knee JointMom.ankle],MassKG);
cd (DirFigRunBiomech)
saveas(gca,'allMoments.jpeg')

close all

cd(DirIDResults)
save IDresults IDresults IDresultsNormalized GaitCycle BadTrials Labels

%% work loops

PlotOSimWork
% PlotOSimWork_merged

%% Power plot

PlotOSimPower

%% Done
fprintf('Plots finished for participant %s \n', Subject)
end