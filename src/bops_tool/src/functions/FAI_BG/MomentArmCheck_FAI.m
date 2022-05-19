
function MomentArmCheck_FAI
fp = filesep;

Dir = getdirFAI;
Studies = {'JointWork_RS' 'RS_FAI' 'JCFFAI' 'IAA' 'Walking'};
[Subjects,~]=splitGroupsFAI(Dir.Main,Studies{3});

[Dir,Temp,~,~] = getdirFAI(Subjects{1});
savedir = [Dir.Main fp 'ElaboratedData\GenericMomentArmsValidation'];
copyfile(Temp.MASetup,savedir)
cd(savedir)

%% creat mot files for hip and knee motions
templateMOT = load_sto_file([savedir '\zeros.mot']);
n = length(templateMOT.time)-1;

% hip_flexion_r
newMOT = templateMOT;
rangeangles = [-30 120];
newMOT.hip_flexion_r = [rangeangles(1):range(rangeangles)/n:rangeangles(2)]';
write_sto_file(newMOT,[savedir '\hip_flexion_r.mot']);
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],'hip_flexion_r','.\009_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim')

%hip_adduction_r
newMOT = templateMOT;
rangeangles = [-50 30];
newMOT.hip_adduction_r = [rangeangles(1):range(rangeangles)/n:rangeangles(2)]';
write_sto_file(newMOT,[savedir '\hip_adduction_r.mot']);
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],'hip_adduction_r','.\009_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim')

% hip_rotation_r
newMOT = templateMOT;
rangeangles = [-40 40];
newMOT.hip_rotation_r = [rangeangles(1):range(rangeangles)/n:rangeangles(2)]';
write_sto_file(newMOT,[savedir '\hip_rotation_r.mot']);
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],'hip_rotation_r','.\009_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim')

% knee_angle_r
newMOT = templateMOT;
rangeangles = [-40 40];
newMOT.hip_rotation_r = [rangeangles(1):range(rangeangles)/n:rangeangles(2)]';
write_sto_file(newMOT,[savedir '\knee_angle_r.mot']);
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],'knee_angle_r','.\009_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim')

%% load data
LitData = struct;
load([Dir.LiteratureData fp 'DigitizedData\Arnold2000CAS\PaperData.mat']); LitData.Arnold = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Delp1999JBiomech\PaperData.mat']); LitData.Delp = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Nemeth1985Jbiomech\PaperData.mat']); LitData.Nemeth = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Blemker2005Annals\PaperData.mat']); LitData.Blemker = PaperData;

MomArm = struct;
MomArm.hip_flexion = load_sto_file([savedir fp 'hip_flexion_r\_MuscleAnalysis_MomentArm_hip_flexion_r.sto']);
MomArm.hip_adduction = load_sto_file([savedir fp 'hip_flexion_r\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
MomArm.hip_rotation = load_sto_file([savedir fp 'hip_flexion_r\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
MomArm.hip_adduction_adduction_angle = load_sto_file([savedir fp 'hip_adduction_r\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
MomArm.hip_rotation_rotation_angle = load_sto_file([savedir fp 'hip_rotation_r\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
MomArm.hip_flexion_knee_flexion = load_sto_file([savedir fp 'knee_angle_r\_MuscleAnalysis_MomentArm_hip_flexion_r.sto']);

IK = load_sto_file([savedir '\hip_flexion_r.mot']);
IK_adduction = load_sto_file([savedir '\hip_adduction_r.mot']);
IK_rotation = load_sto_file([savedir '\hip_rotation_r.mot']);
IK_knee = load_sto_file([savedir '\knee_angle_r.mot']);

%% create figure
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(14,0, 0.05, 0.05,[0.1 0.02],0);
%% psoas hip flexion moment arm vs flexion angle - Arnold & James (2000),Blemker & Delp (2005)
Ntile = 1;
momarm = [LitData.Arnold.Psoas_hip_flexion_moment_arm_S1(:,2),LitData.Arnold.Psoas_hip_flexion_moment_arm_S2(:,2),LitData.Arnold.Psoas_hip_flexion_moment_arm_S3(:,2)];
angles = [LitData.Arnold.Psoas_hip_flexion_moment_arm_S1(:,1),LitData.Arnold.Psoas_hip_flexion_moment_arm_S2(:,1),LitData.Arnold.Psoas_hip_flexion_moment_arm_S3(:,1)];
M1 = mean([momarm],2);
SD1 = std([momarm],0,2);
Xvalues1 = mean(angles,2);

momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Psoas_flex'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M2 = mean(momarm,2); 
SD2 = std(momarm,0,2);
Xvalues2 = mean(angles,2);

Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

MuscleMomArm = TimeNorm(MomArm.hip_flexion.psoas_r*100,200); % in cm
MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.psoas_r*100,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[1 0 0],Xvalues1)
plotShadedSD(M2,SD2,[0 1 1],Xvalues2)
ylim([0 8])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('psoas (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([5 4 2]),{'current model','Arnold & James (2000)','Blemker & Delp (2005)'})

%% iliacus hip flexion moment arm vs flexion angle - Blemker & Delp (2005)

Ntile = Ntile+1;
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Illiacus_flex'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Xvalues1 = mean(angles,2);

Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

MuscleMomArm = TimeNorm(MomArm.hip_flexion.iliacus_r*100,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],Xvalues1)
ylim([0 8])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('iliacus (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

%% semitend -flexion moment arm vs flexion angle - Arnold & James (2000)
Ntile = Ntile+1;
momarm = -[LitData.Arnold.ST_hip_extension_moment_arm_S1(:,2),LitData.Arnold.ST_hip_extension_moment_arm_S2(:,2)];
angles = [LitData.Arnold.ST_hip_extension_moment_arm_S1(:,1),LitData.Arnold.ST_hip_extension_moment_arm_S2(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm = TimeNorm(MomArm.hip_flexion.semiten_r*100,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[1 0 0],mean(angles,2))
ylim([-10 0])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('semitendinosus (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Arnold & James (2000)'})

%% semimemb - flexion moment arm vs flexion angle - Arnold & James (2000)
Ntile = Ntile+1;
momarm = -[LitData.Arnold.SM_hip_extension_moment_arm_S1(:,2),LitData.Arnold.SM_hip_extension_moment_arm_S2(:,2)];
angles = [LitData.Arnold.SM_hip_extension_moment_arm_S1(:,1),LitData.Arnold.SM_hip_extension_moment_arm_S2(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm = TimeNorm(MomArm.hip_flexion.semimem_r*100,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[1 0 0],mean(angles,2))
ylim([-10 0])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('semimembranousus (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Arnold & James (2000)'})

%% Add magnus - flexion moment arm - Nemeth1985Jbiomech
Ntile = Ntile+1;
momarm = -[LitData.Nemeth.AMag_female(:,2),LitData.Nemeth.AMag_male(:,2)]./10;   % from mm to cm
angles = [LitData.Nemeth.AMag_female(:,1),LitData.Nemeth.AMag_male(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm =mean([MomArm.hip_flexion.addmagDist_r,MomArm.hip_flexion.addmagIsch_r,MomArm.hip_flexion.addmagMid_r,MomArm.hip_flexion.addmagProx_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[0 1 0],mean(angles,2))
ylim([-10 0])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('adductor magnus (flexion +)')
mmfn_inspect
legend({'current model','Németh & Ohlsén (1985)'})

%% glute max - flexion moment arm vs flexion angle - Nemeth1985Jbiomech / Blemker2005Annals
Ntile = Ntile+1;
momarm = -[LitData.Nemeth.Gmax_female(:,2),LitData.Nemeth.Gmax_male(:,2)]./10;   % from mm to cm
angles = [LitData.Nemeth.Gmax_female(:,1),LitData.Nemeth.Gmax_male(:,1)];
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);

momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmax_ext'));
for i = 1:length(muscles)
    momarm(:,i) = -LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M2 = mean(momarm,2); 
SD2 = std(momarm,0,2);
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_flexion.glmax1_r,MomArm.hip_flexion.glmax2_r,MomArm.hip_flexion.glmax3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 0],mean(angles,2))
plotShadedSD(M2,SD2,[0 1 1],mean(angles,2))
ylim([-10 5])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('gluteus maximus (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([5 4 2]),{'current model','Németh & Ohlsén (1985)','Blemker & Delp (2005)'})

%% glute max - rotation moment vs flexion angle - Delp1999JBiomech 
Ntile = Ntile+1;
% get data from Delp
muscles =fields(LitData.Delp); muscles = muscles(contains(muscles,'Gmax'));
momarm=[]; angles=[];
for i = 1:length(muscles)
    momarm(:,i) = LitData.Delp.(muscles{i})(:,2)./10; 
    angles(:,i) = LitData.Delp.(muscles{i})(:,1);
end
M1 = mean(momarm,2);         % from mm to cm
SD1 = std(momarm,0,2);       % from mm to cm

MuscleMomArm =mean([MomArm.hip_rotation.glmax1_r,MomArm.hip_rotation.glmax2_r,MomArm.hip_rotation.glmax3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 0 1],mean(angles,2))
xticklabels(xticks)
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('gluteus maximus (internal rotation +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Delp et al. (1999)'})

%% glute max - adduction moment arm vs addction angle - Blemker2005Annals
Ntile = Ntile+1;
% get data from Blemker
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmax_add'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Angles_IK = TimeNorm(IK_adduction.hip_adduction_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_adduction_adduction_angle.glmax1_r,MomArm.hip_adduction_adduction_angle.glmax2_r,MomArm.hip_adduction_adduction_angle.glmax3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip adduction angle')
ylabel('gluteus maximus (adduction +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

%% glute max - rotation moment arm vs rotation angle - Blemker2005Annals
Ntile = Ntile+1;
% get data from Blemker
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmax_rot'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Angles_IK = TimeNorm(IK_rotation.hip_rotation_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_rotation_rotation_angle.glmax1_r,MomArm.hip_rotation_rotation_angle.glmax2_r,MomArm.hip_rotation_rotation_angle.glmax3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip internal rotation angle')
ylabel('gluteus maximus (internal rotation +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

%% glute med - flexion moment arm vs flexion angle - Blemker2005Annals
Ntile = Ntile+2;
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmed_ext'));
for i = 1:length(muscles)
    momarm(:,i) = -LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_flexion.glmed1_r,MomArm.hip_flexion.glmed2_r,MomArm.hip_flexion.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); % in cm
axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('gluteus medius (flexion +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

%% glute med - rotation moment vs flexion angle - Delp1999JBiomech
Ntile = Ntile+1;
% get data from Delp
muscles =fields(LitData.Delp); muscles = muscles(contains(muscles,'Gmax'));
momarm=[]; angles=[];
for i = 1:length(muscles)
    momarm(:,i) = LitData.Delp.(muscles{i})(:,2)./10; 
    angles(:,i) = LitData.Delp.(muscles{i})(:,1);
end
M1 = mean(momarm,2);         % from mm to cm
SD1 = std(momarm,0,2);       % from mm to cm

MuscleMomArm =mean([MomArm.hip_rotation.glmed1_r,MomArm.hip_rotation.glmed2_r,MomArm.hip_rotation.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 0 1],mean(angles,2))
xticklabels(xticks)
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip flexion angle')
ylabel('gluteus medius (internal rotation +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Delp et al. (1999)'})

%% glute med - rotation moment arm vs rotation angle - Blemker2005Annals
Ntile = Ntile+1;
% get data from Blemker
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmed_rot'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Angles_IK = TimeNorm(IK_rotation.hip_rotation_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_rotation_rotation_angle.glmed1_r,MomArm.hip_rotation_rotation_angle.glmed2_r,MomArm.hip_rotation_rotation_angle.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip internal rotation angle')
ylabel('gluteus medius (internal rotation +)')
mmfn_inspect
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

%% glute med - adduction moment arm vs addction angle - Blemker2005Annals
Ntile = Ntile+1;
% get data from Blemker
momarm=[]; angles=[];
muscles =fields(LitData.Blemker); muscles = muscles(contains(muscles,'Gmed_add'));
for i = 1:length(muscles)
    momarm(:,i) = LitData.Blemker.(muscles{i})(:,2); 
    angles(:,i) = LitData.Blemker.(muscles{i})(:,1);
end
M1 = mean(momarm,2); 
SD1 = std(momarm,0,2);
Angles_IK = TimeNorm(IK_adduction.hip_adduction_r,200); % in cm

MuscleMomArm =mean([MomArm.hip_adduction_adduction_angle.glmed1_r,MomArm.hip_adduction_adduction_angle.glmed2_r,MomArm.hip_adduction_adduction_angle.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip adduction angle')
ylabel('gluteus medius (adduction +)')
ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})
mmfn_inspect

%% make figure nice

delete(ha(10))
FigAx = get(gcf,'Children')';   for ax=FigAx; ax.FontSize=12;end           % change font size
tt = text(1,1,'moment arm (cm)');
tt.FontName = 'Times New Roman';
tt.FontSize = 12;
tt.Position =[-500 26 0];
tt.Rotation =90;

saveas(gcf,[savedir fp 'moment_arms_FAI.jpeg'])
function run_muscleanalyis(templateSetupMA,trial,modeldir)

import org.opensim.modeling.*
osimModel = Model(modeldir);
modelName = strrep(modeldir,'.\','');
modelName = strrep(modelName,'.osim','');
ResultsDir = ['.\' trial '_' modelName];
mkdir(ResultsDir); cd(ResultsDir)

analyzeTool=AnalyzeTool(templateSetupMA);
analyzeTool.setModel(osimModel);
analyzeTool.setModelFilename(modeldir);
analyzeTool.setReplaceForceSet(false);
analyzeTool.setResultsDir(['.\']);
analyzeTool.setOutputPrecision(8)
analyzeTool.setInitialTime(0.005);
analyzeTool.setFinalTime(0.415);
analyzeTool.setSolveForEquilibrium(false)
analyzeTool.setMaximumNumberOfSteps(20000)
analyzeTool.setMaxDT(1)
analyzeTool.setMinDT(1e-008)
analyzeTool.setErrorTolerance(1e-005)
analyzeTool.setCoordinatesFileName(['..\' trial '.mot'])
% analyzeTool.setExternalLoadsFileName(osimFiles.IDgrfxml)
analyzeTool.print(['.\setup_MA.xml']);
analyzeTool.run
