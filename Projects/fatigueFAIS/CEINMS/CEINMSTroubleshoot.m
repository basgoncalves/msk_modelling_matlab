% CEINMSTroubleshoot
Studies = {'JointWork_RS' 'RS_FAI' 'JCFFAI' 'IAA' 'Walking'};
[Subjects,Groups]=splitGroupsFAI(Dir.Main,Studies{3});Subjects = Subjects(1:end);

for ff = 17:length(Subjects)
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    updateLogAnalysis(Dir,'CEINMS exe',SubjectInfo,'start')% print log
    
    dofList = split(CEINMSSettings.dofList ,' ')';
    AdjustDofDListOnly(CEINMSSettings.outputSubjectFilename,CEINMSSettings.osimModelFilename,dofList)
    
    trialList = [Trials.MA];
    idx = find(contains(trialList,'walking')| contains(trialList,'baseline')&contains(trialList,'1'));
    trialList=trialList([idx]);
    
    for trial=trialList'
        for A = CEINMSSettings.Alphas
            for B = CEINMSSettings.Betas
                for G = CEINMSSettings.Gammas
                     CEINMSexe_BG (Dir,CEINMSSettings,trial{1},A,B,G);
                end
            end
        end
        cd(Dir.CEINMSsimulations)
        SimulationDir = [Dir.CEINMSsimulations fp trial{1}];
        delete([SimulationDir fp 'OptimalSettings.mat'])
        OptimalGamma = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);
    end
    updateLogAnalysis(Dir,'CEINMS exe',SubjectInfo,'end')% print log
end

cd([Dir.Results fp 'CEINMS'])
load([Dir.Results fp 'CEINMS' fp 'ErrorsCEINMS.mat'])
% trial = 'walking1';
trial = 'RunStraight1';
A = 'A1';
B = 'B50';

%% R2 excitations
PP.Gap = 0.05;
PP.Nh = 0.05;
PP.Nw = 0.05;
PP.Size = [20 20 1000 700];
Vars = fields(R2.excitations.(trial));
Vars = Vars([1 7:10 21 24 25 27 28 30 31]);
CEINMSTroubleshoot_PlotError(R2,'excitations',trial,Vars,A,B,PP)
suptitle(['R2 excitations (EMG vs Adjusted EMGs)-' trial])
saveas(gca,[Dir.Results fp 'CEINMS\R2_exc_' trial '.jpeg'])

CEINMSTroubleshoot_PlotError(RMSE,'excitations',trial,Vars,Iteration,PP)
suptitle(['RMSE excitations (EMG vs Adjusted EMGs)-' trial])
saveas(gca,[Dir.Results fp 'CEINMS\RMSE_exc_' trial '.jpeg'])

%% moments
PP.Gap = 0.05;
PP.Nh = 0.1;
PP.Nw = 0.05;
PP.Size = [20 200 1000 300];
Vars = fields(R2.moments.(trial));
CEINMSTroubleshoot_PlotError(R2,'moments',trial,Vars,Iteration,PP)
suptitle(['R2 moments (ID vs CEINMS)-' trial])
saveas(gca,[Dir.Results fp 'CEINMS\R2_mom_' trial '.jpeg'])

CEINMSTroubleshoot_PlotError(RMSE,'moments',trial,Vars,Iteration,PP)
suptitle(['RMSE moments (ID vs CEINMS)-' trial])
saveas(gca,[Dir.Results fp 'CEINMS\RMSE_mom_' trial '.jpeg'])


%% RANDOM

cd('D:\3-PhD\Data\MocapData\ElaboratedData\037\pre\ceinms\execution\simulations\walking3')
load('OptimalGamma.mat')
% OptimalGamma.Gamma_MinDiff=20;
% save OptimalGamma OptimalGamma RMSE_mom RMSE_exc OrderedIterations Settings

%%
Subject = '041';
trialName = 'walking2';
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subject);
CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);

dofList = split(CEINMSSettings.dofList ,' ')';
AdjustDofDListOnly(CEINMSSettings.outputSubjectFilename,CEINMSSettings.osimModelFilename,dofList)

OptimalSettings = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
A=OptimalSettings.Alpha; B=OptimalSettings.Beta;G=OptimalSettings.Gamma;
CEINMSexe_BG (Dir,CEINMSSettings,trialName,A,B,G);      

osimFiles = getosimfilesFAI(Dir,trialName);
CEINMS_trialDir = OptimalSettings.Dir;

JRAforcefile(CEINMS_trialDir,osimFiles,osimFiles.JRAforcefile)

outputDir = runJRA_BG(osimFiles.JRAmodel,osimFiles.JRAkinematics,...
                osimFiles.JRAexternal_loads_file,osimFiles.JRAforcefile,...
                dofList,osimFiles.JRA,Temp.JRAsetup);

%% CEINMS CF vs JRA
Subject = '041';
trialName = 'walking2';
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subject);
OptimalGamma = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
l = lower(SubjectInfo.TestedLeg);

L= load_sto_file([OptimalGamma.Dir fp 'ContactForces.sto']);
L2= load_sto_file([Dir.JRA fp trialName '\JCF_JointReaction_ReactionLoads.sto']);

hip_resultant_CEINMS = sum3Dvector(L.(['hip_' l '_x']),L.(['hip_' l '_y']),L.(['hip_' l '_z']));
hip_resultant_JRA = sum3Dvector(L2.(['hip_' l '_on_pelvis_in_pelvis_fx']),L2.(['hip_' l '_on_pelvis_in_pelvis_fy']),L2.(['hip_' l '_on_pelvis_in_pelvis_fz']));

knee_resultant_CEINMS = sum3Dvector(L.(['walker_knee_' l '_x']),L.(['walker_knee_' l '_y']),L.(['walker_knee_' l '_z']));
knee_resultant_JRA = sum3Dvector(L2.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fx']),L2.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fy']),L2.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fz']));

ankle_resultant_CEINMS = sum3Dvector(L.(['ankle_' l '_x']),L.(['ankle_' l '_y']),L.(['ankle_' l '_z']));
ankle_resultant_JRA = sum3Dvector(L2.(['ankle_' l '_on_tibia_' l '_in_tibia_' l '_fx']),L2.(['ankle_' l '_on_tibia_' l '_in_tibia_' l '_fy']),L2.(['ankle_' l '_on_tibia_' l '_in_tibia_' l '_fz']));

lg = {'CEINMS' 'JRA'};
[ha, ~,FirstCol, LastRow] = tight_subplotBG (1,3,[0.03],[0.1 0.1],0.05,[9 ,274,1521,384]);
axes(ha(1)); hold on; plot(hip_resultant_CEINMS);  plot(hip_resultant_JRA); title(['hip result force' Subject trialName]); mmfn_inspect; legend(lg); yticklabels(yticks);
axes(ha(2)); hold on; plot(knee_resultant_CEINMS);  plot(knee_resultant_JRA); title(['knee result force' Subject trialName]); mmfn_inspect; legend(lg); yticklabels(yticks);
axes(ha(3)); hold on; plot(ankle_resultant_CEINMS);  plot(ankle_resultant_JRA); title(['ankle result force' Subject trialName]); mmfn_inspect; legend(lg); yticklabels(yticks);

%% plot forces
F1 = load_sto_file([Dir.JRA fp trialName '\forcefile.sto']);
Force = fields(F1);
if isequal(l,'l'); Force=Force([44:83 112]); else; Force=Force([2:41 107:111]);end 

[ha, ~,FirstCol, LastRow] = tight_subplotBG (length(Force),0,[0.03],[0.1 0.05],0.05,0);
for i = 1:length(Force)
    axes(ha(i)); hold on; plot(F1.(Force{i})); yticklabels(yticks); title(Force{i}); xticks('')
end


%%
Subject1 = '041';
trialName = 'walking1';
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subject1);
l = lower(SubjectInfo.TestedLeg);
F1 = load_sto_file([Dir.JRA fp trialName '\forcefile.sto']);

hip_reserve_1 = F1.(['hip_flexion_' l '_reserve']);
knee_reserve_1 = F1.(['knee_angle_' l '_reserve']);

Subject2 = '028';
trialName = 'walking1';
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subject2);
l = lower(SubjectInfo.TestedLeg);
F2 = load_sto_file([Dir.JRA fp trialName '\forcefile.sto']);

%============= reserves ===================
hip_reserve_2 = F2.(['hip_flexion_' l '_reserve']);
knee_reserve_2 = F2.(['knee_angle_' l '_reserve']);

lg = {Subject1 Subject2};
figure; hold on; plot(hip_reserve_1);  plot(hip_reserve_2); title(['hip felxion reserve' trialName]); mmfn_inspect; legend(lg);
figure; hold on; plot(knee_reserve_1);  plot(knee_reserve_2); title(['knee reserve' trialName]); mmfn_inspect; legend(lg);

Reserves=fields(F1);
Reserves =  Reserves(contains(Reserves,'reserve'));
[ha, ~,FirstCol, LastRow] = tight_subplotBG (length(Reserves),0,[0.03],[0.1 0.05],0.05,0);
for i = 1:length(Reserves)
    axes(ha(i)); hold on; plot(F1.(Reserves{i})); 
end

Reserves=fields(F1);
Reserves =  Reserves(contains(Reserves,'reserve'));
for i = 1:length(Reserves)
    axes(ha(i)); hold on; plot(F2.(Reserves{i})); yticklabels(yticks); title(Reserves{i}); xticks('')
end
suptitle([trialName])
legend({Subject1 Subject2})

%============= forces ===================
Force = fields(F1);
Force =  Force(~contains(Force,'calcn_'));

[ha, ~,FirstCol, LastRow] = tight_subplotBG (length(Force),0,[0.03],[0.1 0.05],0.05,0);
for i = 1:length(Force)
    axes(ha(i)); hold on; plot(F1.(Force{i})); 
end

for i = 1:length(Force)
    axes(ha(i)); hold on; plot(F2.(Force{i})); yticklabels(yticks); title(Force{i}); xticks('')
end
suptitle([trialName])
legend({Subject1 Subject2})

%% loadResults_BG vs loadsto

%% CEINMS CF vs JRA
Subject = '041';
trialName = 'walking2';
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subject);
OptimalGamma = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
trialDirs = getosimfilesFAI(Dir,trialName);
Vars = {'hip_r_x' 'hip_r_y' 'hip_r_z'};
l = lower(SubjectInfo.TestedLeg);

tic
L= load_sto_file([OptimalGamma.Dir fp 'ContactForces.sto']);


toc

tic

%% results from Rajagopal

L = load_sto_file(['C:\OpenSim 3.3\Models\Rajagopal_FullBody\SimulationDataAndSetupFiles-4.0\ID\results_run\inverse_dynamics.sto']);
L2 = load_sto_file(['C:\OpenSim 3.3\Models\Rajagopal_FullBody\SimulationDataAndSetupFiles-4.0\ID\results_run_rra\inverse_dynamics.sto']);
figure; hold on; plot(TimeNorm(L.pelvis_tx_force,100)); plot(TimeNorm(L2.pelvis_tx_force,1000)); legend({'ID' 'RRA'})
max(L.pelvis_tx_force)
max(L2.pelvis_tx_force)

cd('C:\OpenSim 3.3\Models\Rajagopal_FullBody\SimulationDataAndSetupFiles-4.0\RRA\run')
[~,log_mes]=dos(['rra -S  ','C:\OpenSim 3.3\Models\Rajagopal_FullBody\SimulationDataAndSetupFiles-4.0\RRA\run\rra_setup_run_3_BG.xml'])


TimeWindow = IDxml.InverseDynamicsTool.time_range;
ID = LoadResults_BG('D:\3-PhD\Data\MocapData\ElaboratedData\009\pre\inverseDynamics\RunA1\inverse_dynamics.sto',TimeWindow,{'pelvis_ty_force' 'hip_flexion_r_moment' 'lumbar_extension_moment'});
IDrra = LoadResults_BG('D:\3-PhD\Data\MocapData\ElaboratedData\009\pre\residualReductionAnalysis\RunA1\inverse_dynamics.sto',TimeWindow,{'pelvis_ty_force' 'hip_flexion_r_moment' 'lumbar_extension_moment'});
IDceinms = LoadResults_BG('D:\3-PhD\Data\MocapData\ElaboratedData\009\pre\inverseDynamics\RunA1\inverse_dynamics_RRA.sto',TimeWindow,{'pelvis_ty_force' 'hip_flexion_r_moment' 'lumbar_extension_moment'});

IK = LoadResults_BG('D:\3-PhD\Data\MocapData\ElaboratedData\009\pre\inverseKinematics\RunA1\IK.mot',TimeWindow,{'hip_flexion_r'});
IKrra = LoadResults_BG('D:\3-PhD\Data\MocapData\ElaboratedData\009\pre\residualReductionAnalysis\RunA1\RunA1_Kinematics_q.sto',TimeWindow,{'hip_flexion_r'});

[ha, ~, FirstCol, LastRow] = tight_subplotBG(5,3,[],[],[],0);
axes(ha(1)); hold on; plot(ID(:,1)); plot(IDrra(:,1)); plot(IDceinms(:,1)); legend({'ID' 'RRA' 'ID ceinms'}); title('pelvis y force')
axes(ha(2)); hold on; plot(ID(:,2)); plot(IDrra(:,2)); plot(IDceinms(:,2));legend({'ID' 'RRA' 'ID ceinms'}); title('hip flexion moments')
axes(ha(3)); hold on; plot(ID(:,3)); plot(IDrra(:,3)); plot(IDceinms(:,3));legend({'ID' 'RRA' 'ID ceinms'}); title('lumbar extension moments') 
axes(ha(4)); hold on; plot(IK(:,1)); plot(IKrra(:,1)); plot(IK(:,1)); legend({'IK' 'RRA' 'IK ceinms'}); title('hip flexion deg')

tight_subplot_ticks (LastRow,0)

max(L.pelvis_tx_force)
max(L2.pelvis_tx_force)

%% compare iteration ceinms 
[Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{1});
osimFiles = getosimfilesFAI(Dir,Trials.CEINMS{1});
L1 = load_sto_file([osimFiles.JRAresults]);
L2 = load_sto_file(['E:\3-PhD\Data\MocapData\ElaboratedData\009\pre\JointReactionAnalysis\Run_baseline1\JCF_JointReaction_ReactionLoads - Copy.sto']);

figure; hold on; mmfn_inspect
plot(L1.hip_r_on_pelvis_in_pelvis_fy);plot(L2.hip_r_on_pelvis_in_pelvis_fy); title('')
figure; hold on; mmfn_inspect
plot(L1.hip_r_on_pelvis_in_pelvis_fx);plot(L2.hip_r_on_pelvis_in_pelvis_fx); title('')
figure; hold on; mmfn_inspect
plot(L1.hip_r_on_pelvis_in_pelvis_fz);plot(L2.hip_r_on_pelvis_in_pelvis_fz); title('')

