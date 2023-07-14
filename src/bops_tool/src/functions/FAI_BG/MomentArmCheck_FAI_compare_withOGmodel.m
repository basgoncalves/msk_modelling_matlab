
function MomentArmCheck_FAI_compare_withOGmodel
fp = filesep;

Dir = getdirFAI;
Studies = {'JointWork_RS' 'RS_FAI' 'JCFFAI' 'IAA' 'Walking'};
[Subjects,~]=splitGroupsFAI(Dir.Main,Studies{3});

[Dir,Temp,~,~] = getdirFAI(Subjects{1});
savedir = [Dir.Results fp 'GenericMomentArmsValidation_TC'];
mkdir(savedir)
copyfile(Temp.MASetup,savedir)
copyfile([fileparts(Temp.IKSetup) fp 'zeros.mot'],savedir)
cd(savedir)
%% creat mot files for hip and knee motions
templateMOT = load_sto_file([savedir '\zeros.mot']);

% scale models
% setupScaleXML =[savedir fp 'Scale\Setup_Scale_FAI.xml'];
% M=dos(['scale -S ' setupScaleXML],'-echo');
% 
% setupScaleXML =[savedir fp 'Scale\Setup_Scale_Original.xml'];
% M=dos(['scale -S ' setupScaleXML],'-echo');

scaledFAI = 'Rajagopal2015_FAI_scaled';
scaledOriginal = 'Rajagopal2015_Original_scaled';

% range of observed angles 
range_hip_flexion = [-30 100];
range_hip_adduction = [-40 20];
range_hip_rotation = [-30 30];
% 
createMotAndMA(templateMOT,range_hip_flexion,savedir,'hip_flexion_r',scaledFAI,scaledOriginal)
createMotAndMA(templateMOT,range_hip_adduction,savedir,'hip_adduction_r',scaledFAI,scaledOriginal)
createMotAndMA(templateMOT,range_hip_rotation,savedir,'hip_rotation_r',scaledFAI,scaledOriginal)
createMotAndMA(templateMOT,[0 145],savedir,'knee_angle_r',scaledFAI,scaledOriginal)

%% load data
LitData = struct;
load([Dir.LiteratureData fp 'DigitizedData\Arnold2000CAS\PaperData.mat']); LitData.Arnold = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Delp1999JBiomech\PaperData.mat']); LitData.Delp = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Nemeth1985Jbiomech\PaperData.mat']); LitData.Nemeth = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Blemker2005Annals\PaperData.mat']); LitData.Blemker = PaperData;
load([Dir.LiteratureData fp 'DigitizedData\Visser1990EJAP\PaperData.mat']); LitData.Visser = PaperData;
LitData.VisserTable2 = csvread([Dir.LiteratureData fp 'DigitizedData\Visser1990EJAP\Table2.csv']);
LitData.Schache = csvread([Dir.LiteratureData fp 'DigitizedData\Schache2018MSSE\Table1and2.csv']);

MomArm = struct;
MomArm.hip_flexion = load_sto_file([savedir fp 'hip_flexion_r_' scaledFAI '\_MuscleAnalysis_MomentArm_hip_flexion_r.sto']);
MomArm.hip_adduction = load_sto_file([savedir fp 'hip_flexion_r_' scaledFAI '\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
MomArm.hip_rotation = load_sto_file([savedir fp 'hip_flexion_r_' scaledFAI '\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
MomArm.hip_adduction_adduction_angle = load_sto_file([savedir fp 'hip_adduction_r_' scaledFAI '\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
MomArm.hip_rotation_rotation_angle = load_sto_file([savedir fp 'hip_rotation_r_' scaledFAI '\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
MomArm.knee_flexion = load_sto_file([savedir fp 'knee_angle_r_' scaledFAI '\_MuscleAnalysis_MomentArm_knee_angle_r.sto']);

OGMomArm = struct;
OGMomArm.hip_flexion = load_sto_file([savedir fp 'hip_flexion_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_flexion_r.sto']);
OGMomArm.hip_adduction = load_sto_file([savedir fp 'hip_flexion_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
OGMomArm.hip_rotation = load_sto_file([savedir fp 'hip_flexion_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
OGMomArm.hip_adduction_adduction_angle = load_sto_file([savedir fp 'hip_adduction_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_adduction_r.sto']);
OGMomArm.hip_rotation_rotation_angle = load_sto_file([savedir fp 'hip_rotation_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_rotation_r.sto']);
OGMomArm.hip_flexion_knee_flexion = load_sto_file([savedir fp 'knee_angle_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_hip_flexion_r.sto']);
OGMomArm.knee_flexion = load_sto_file([savedir fp 'knee_angle_r_' scaledOriginal '\_MuscleAnalysis_MomentArm_knee_angle_r.sto']);


IK = load_sto_file([savedir '\hip_flexion_r.mot']);
IK_adduction = load_sto_file([savedir '\hip_adduction_r.mot']);
IK_rotation = load_sto_file([savedir '\hip_rotation_r.mot']);
IK_knee = load_sto_file([savedir '\knee_angle_r.mot']);

%% create figure
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(14,0, 0.05, 0.1,[0.1 0.02],0);
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
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[1 0 0],Xvalues1)
plotShadedSD(M2,SD2,[0 1 1],Xvalues2)
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('psoas (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([6 5 4 2]),{'Rajagopal (2016)','current model','Arnold & James (2000)','Blemker & Delp (2005)'})

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
MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.psoas_r*100,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6]) 
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],Xvalues1)
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('iliacus (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Blemker & Delp (2005)'})

%% semitend -flexion moment arm vs flexion angle - Arnold & James (2000)
Ntile = Ntile+1;
momarm = -[LitData.Arnold.ST_hip_extension_moment_arm_S1(:,2),LitData.Arnold.ST_hip_extension_moment_arm_S2(:,2)];
angles = [LitData.Arnold.ST_hip_extension_moment_arm_S1(:,1),LitData.Arnold.ST_hip_extension_moment_arm_S2(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm = TimeNorm(MomArm.hip_flexion.semiten_r*100,200); % in cm
MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.semiten_r*100,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6]) 
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[1 0 0],mean(angles,2))
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('semitendinosus (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Arnold & James (2000)'})

%% semimemb - flexion moment arm vs flexion angle - Arnold & James (2000)
Ntile = Ntile+1;
momarm = -[LitData.Arnold.SM_hip_extension_moment_arm_S1(:,2),LitData.Arnold.SM_hip_extension_moment_arm_S2(:,2)];
angles = [LitData.Arnold.SM_hip_extension_moment_arm_S1(:,1),LitData.Arnold.SM_hip_extension_moment_arm_S2(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm = TimeNorm(MomArm.hip_flexion.semimem_r*100,200); % in cm
MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.semimem_r*100,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6]) 
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[1 0 0],mean(angles,2))
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('semimembranousus (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Arnold & James (2000)'})

%% Biceps femoris longhead - flexion moment arm vs flexion angle - Visser1990 (1990) / Schache (2018) - NOT GOOD
% Ntile = Ntile+1;
% momarm = -LitData.Schache(:,2)./10;
% % for i=1:length(LitData.VisserTable2(:,1))
% %     momarm(:,i) = -LitData.Visser.BF_hip_angle(:,2)./100*LitData.VisserTable2(i,2)./10; % conert from % to decimal and from mm to cm 
% % end
% angles = LitData.Schache(:,1);
% Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm
% 
% M = mean(momarm,2);
% SD = std(momarm,0,2);
% MuscleMomArm = TimeNorm(MomArm.hip_flexion.semimem_r*100,200); % in cm
% MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.semimem_r*100,200); % in cm
% 
% axes(ha(Ntile)); hold on
% plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6]) 
% plot(Angles_IK,MuscleMomArm,'--k')
% plotShadedSD(M,SD,[1 0 0],mean(angles,2))
% ylim([-10 0])
% xticklabels(xticks)
% yticklabels(yticks)
% xlabel('hip angle (flexion +)')
% ylabel('biceps femoris long head (flexion +)')
% mmfn_inspect
% % ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Arnold & James (2000)'})

%% Add magnus - flexion moment arm vs flexion angle - Nemeth1985Jbiomech
Ntile = Ntile+1;
momarm = -[LitData.Nemeth.AMag_female(:,2),LitData.Nemeth.AMag_male(:,2)]./10;   % from mm to cm
angles = [LitData.Nemeth.AMag_female(:,1),LitData.Nemeth.AMag_male(:,1)];
Angles_IK = TimeNorm(IK.hip_flexion_r,200); % in cm

M = mean(momarm,2);
SD = std(momarm,0,2);
MuscleMomArm = mean([MomArm.hip_flexion.addmagDist_r,MomArm.hip_flexion.addmagIsch_r,MomArm.hip_flexion.addmagMid_r,MomArm.hip_flexion.addmagProx_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); % in cm
MuscleMomArm_OG = mean([OGMomArm.hip_flexion.addmagDist_r,OGMomArm.hip_flexion.addmagIsch_r,OGMomArm.hip_flexion.addmagMid_r,OGMomArm.hip_flexion.addmagProx_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M,SD,[0 1 0],mean(angles,2))
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('adductor magnus (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Németh & Ohlsén (1985)'})

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
MuscleMomArm_OG =mean([OGMomArm.hip_flexion.glmax1_r,OGMomArm.hip_flexion.glmax2_r,OGMomArm.hip_flexion.glmax3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 0],mean(angles,2))
plotShadedSD(M2,SD2,[0 1 1],mean(angles,2))
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('gluteus maximus (flexion +)')
mmfn_inspect
%ax=gca;legend(ax.Children([6 5 4 2]),{'Rajagopal (2016)','current model','Németh & Ohlsén (1985)','Blemker & Delp (2005)'})

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
MuscleMomArm_OG =mean([OGMomArm.hip_rotation.glmax1_r,OGMomArm.hip_rotation.glmax2_r,OGMomArm.hip_rotation.glmax3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 0 1],mean(angles,2))
xticklabels(xticks)
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('gluteus maximus (internal rotation +)')
mmfn_inspect
% ax=gca;legend(ax.Children([4 3 2]),{'Rajagopal (2016)','current model','Delp et al. (1999)'})

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
MuscleMomArm_OG = mean([OGMomArm.hip_adduction_adduction_angle.glmax1_r,OGMomArm.hip_adduction_adduction_angle.glmax2_r,OGMomArm.hip_adduction_adduction_angle.glmax3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xlim([-40 40])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (adduction +)')
ylabel('gluteus maximus (adduction +)')
mmfn_inspect
% ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

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
MuscleMomArm_OG = mean([OGMomArm.hip_rotation_rotation_angle.glmax1_r,OGMomArm.hip_rotation_rotation_angle.glmax2_r,OGMomArm.hip_rotation_rotation_angle.glmax3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm


axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xlim([-40 40])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (internal rotation +)')
ylabel('gluteus maximus (internal rotation +)')
mmfn_inspect
% ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

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

MuscleMomArm = mean([MomArm.hip_flexion.glmed1_r,MomArm.hip_flexion.glmed2_r,MomArm.hip_flexion.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); % in cm
MuscleMomArm_OG =mean([OGMomArm.hip_flexion.glmed1_r,OGMomArm.hip_flexion.glmed2_r,OGMomArm.hip_flexion.glmed3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm


axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('gluteus medius (flexion +)')
mmfn_inspect
% ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})

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
MuscleMomArm_OG = mean([OGMomArm.hip_rotation.glmed1_r,OGMomArm.hip_rotation.glmed2_r,OGMomArm.hip_rotation.glmed3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 0 1],mean(angles,2))
xticklabels(xticks)
ylim([-10 10])
xlim([-40 100])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (flexion +)')
ylabel('gluteus medius (internal rotation +)')
mmfn_inspect
% ax=gca;legend(ax.Children([3 2]),{'current model','Delp et al. (1999)'})

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

MuscleMomArm = mean([MomArm.hip_adduction_adduction_angle.glmed1_r,MomArm.hip_adduction_adduction_angle.glmed2_r,MomArm.hip_adduction_adduction_angle.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 
MuscleMomArm_OG = mean([OGMomArm.hip_adduction_adduction_angle.glmed1_r,OGMomArm.hip_adduction_adduction_angle.glmed2_r,OGMomArm.hip_adduction_adduction_angle.glmed3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
ylim([-10 10])
xlim([-40 40])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (adduction +)')
ylabel('gluteus medius (adduction +)')
% ax=gca;legend(ax.Children([3 2]),{'current model','Blemker & Delp (2005)'})
mmfn_inspect

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

MuscleMomArm = mean([MomArm.hip_rotation_rotation_angle.glmed1_r,MomArm.hip_rotation_rotation_angle.glmed2_r,MomArm.hip_rotation_rotation_angle.glmed3_r],2)*100; % in cm
MuscleMomArm = TimeNorm(MuscleMomArm,200); 
MuscleMomArm_OG = mean([OGMomArm.hip_rotation_rotation_angle.glmed1_r,OGMomArm.hip_rotation_rotation_angle.glmed2_r,OGMomArm.hip_rotation_rotation_angle.glmed3_r],2)*100; % in cm
MuscleMomArm_OG = TimeNorm(MuscleMomArm_OG,200); % in cm

axes(ha(Ntile)); hold on
plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
plot(Angles_IK,MuscleMomArm,'--k')
plot(NaN,NaN,'r')
plotShadedSD(M1,SD1,[0 1 1],mean(angles,2))
plot(NaN,NaN,'g')
plot(NaN,NaN,'b')
ylim([-10 10])
xlim([-40 40])
xticklabels(xticks)
yticklabels(yticks)
xlabel('hip angle (internal rotation +)')
ylabel('gluteus medius (internal rotation +)')
ax=gca;
lg = legend(ax.Children([7 6 5 4 2 1]),{'Rajagopal (2016)','current model','Arnold & James (2000)','Blemker & Delp (2005)','Németh & Ohlsén (1985)','Delp et al. (1999)'});

%% make figure nice

mmfn_inspect
lg.Position = [0.83 0.42 0.1 0.1];
lg.Box='off';
delete(ha(10))
FigAx = get(gcf,'Children')';   for ax=FigAx; ax.FontSize=12;end           % change font size
tt = text(1,1,'moment arm (cm)');
tt.FontName = 'Times New Roman';
tt.FontSize = 15;
tt.Position =[-400 26 0];
tt.Rotation =90;

saveas(gcf,[savedir fp 'moment_arms_FAI.jpeg'])

%% compare all muscles updated
muscles = {'addmagDist_r';'addmagIsch_r';'addmagMid_r';'addmagProx_r';'bflh_r';'glmax1_r';'glmax2_r';'glmax3_r';'glmed1_r';'glmed2_r';'glmed3_r';'iliacus_r';'psoas_r';'recfem_r';'sart_r';'semimem_r';'semiten_r';'vasint_r';'vaslat_r';'vasmed_r'};
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(muscles),0, 0.05, 0.1,[0.1 0.02],0);

for i = 1:length(muscles)
    
    if contains(muscles{i},'vas')
        Angles_IK = TimeNorm(IK_knee.knee_angle_r,200);
        MuscleMomArm = TimeNorm(MomArm.knee_flexion.(muscles{i}),200);
        MuscleMomArm_OG = TimeNorm(OGMomArm.knee_flexion.(muscles{i}),200);
    else
        Angles_IK = TimeNorm(IK.hip_flexion_r,200);
        MuscleMomArm = TimeNorm(MomArm.hip_flexion.(muscles{i}),200);
        MuscleMomArm_OG = TimeNorm(OGMomArm.hip_flexion.(muscles{i}),200);
    end
    axes(ha(i)); hold on
    plot(Angles_IK,MuscleMomArm_OG,'Color',[0.6 0.6 0.6])
    plot(Angles_IK,MuscleMomArm,'--k')
    yticklabels(yticks)
    xticklabels(xticks)
    if contains(muscles{i},'vas')
        xlabel('knee angle (flexion +)');
        ylabel([strrep(muscles{i},'_r','') ' (hip flexion +)'])
    else
        xlabel('hip angle (flexion +)');
        ylabel([strrep(muscles{i},'_r','') ' (knee flexion +)'])
    end
    
    
end
axes(ha(1));
lg = legend({'Rajagopal (2016)',' Catelli (2018) - current model'});
mmfn_inspect
tt = text(1,1,'moment arm (cm)'); 
tt.Position = [-132.7 -0.2 0];
tt.FontName = 'Times New Roman';
tt.FontSize = 12;
tt.Rotation =90;

FigAx = get(gcf,'Children')';   for ax=FigAx; ax.FontSize=10;end           % change font size
saveas(gcf,[savedir fp 'moment_arms_RajaVSCatelli.jpeg'])


function createMotAndMA(templateMOT,rangeangles,savedir,coordinates,scaledFAI,scaledOriginal)
%% 
fp = filesep;
n = length(templateMOT.time)-1;
newMOT = templateMOT;
newMOT.(coordinates) = [rangeangles(1):range(rangeangles)/n:rangeangles(2)]';
write_sto_file(newMOT,[savedir '\' coordinates '.mot']);
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],coordinates,[savedir fp scaledFAI '.osim'])
cd(savedir)
run_muscleanalyis([savedir fp 'MA_setup_FAI.xml'],coordinates,[savedir fp scaledOriginal '.osim'])

function run_muscleanalyis(templateSetupMA,trial,modeldir)
%% 
import org.opensim.modeling.*
osimModel = Model(modeldir);
[~, modelName] = fileparts(modeldir);
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
