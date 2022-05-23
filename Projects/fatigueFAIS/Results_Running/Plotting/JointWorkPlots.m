% JointWorkPlots_RS

%% create directories
DirC3D = 'E:\3-PhD\Data\MocapData\InputData\038\pre';
OrganiseFAI        % get directories (DirC3D; SubjFolder; DirInput; DirMocap; DirFigure; C3DFolderName;DirElaborated),subject code and demografics

RS_DirResults = [DirResults fp 'JointWork_RS'];
cd(RS_DirResults)
load ('MeanRunningBiomechanics.mat')
SaveDir = [DirFigure filesep 'JointWork_RS'];

%% split work total gait cycle - Formatted for SPSS
joint = 'hip_flexion';
[pfW_hip,nfW_hip, peW_hip, neW_hip] = SplitWork_Running (MeanRun,joint,fs);
nfW_hip = abs(nfW_hip); neW_hip = abs(neW_hip);

joint = 'knee';
[pfW_knee,nfW_knee, peW_knee, neW_knee] = SplitWork_Running (MeanRun,joint,fs);
nfW_knee = abs(nfW_knee); neW_knee = abs(neW_knee);

joint = 'ankle';
[pfW_ankle,nfW_ankle, peW_ankle, neW_ankle] = SplitWork_Running (MeanRun,joint,fs);
nfW_ankle = abs(nfW_ankle); neW_ankle = abs(neW_ankle);

% ABSOLUTE WORK 
AbsoluteWork_Running
AbsWork_fullGait = AbsJointWork;

% RELATIVE WORK
RelativeWork_Running
RelWork_fullGait = RelWork;

disp('Joint work calculated for whole gait cycle')

%% split work Swing Phase
joint = 'hip_flexion';
GaitPhase = 2;  
[pfW_hip,nfW_hip, peW_hip, neW_hip] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_hip = abs(nfW_hip); neW_hip = abs(neW_hip);

joint = 'knee';
[pfW_knee,nfW_knee, peW_knee, neW_knee] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_knee = abs(nfW_knee); neW_knee = abs(neW_knee);

joint = 'ankle';
[pfW_ankle,nfW_ankle, peW_ankle, neW_ankle] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_ankle = abs(nfW_ankle); neW_ankle = abs(neW_ankle);

% ABSOLUTE WORK 
AbsoluteWork_Running
AbsWork_Swing = AbsJointWork;

% RELATIVE WORK
RelativeWork_Running
RelWork_Swing = RelWork;

disp('Joint work calculated for swing phase only')

%% split work Stance Phase
joint = 'hip_flexion';
GaitPhase = 1;  
[pfW_hip,nfW_hip, peW_hip, neW_hip] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_hip = abs(nfW_hip); neW_hip = abs(neW_hip);

joint = 'knee';
[pfW_knee,nfW_knee, peW_knee, neW_knee] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_knee = abs(nfW_knee); neW_knee = abs(neW_knee);

joint = 'ankle';
[pfW_ankle,nfW_ankle, peW_ankle, neW_ankle] = SplitWork_Running (MeanRun,joint,fs,GaitPhase);
nfW_ankle = abs(nfW_ankle); neW_ankle = abs(neW_ankle);

% ABSOLUTE WORK 
AbsoluteWork_Running
AbsWork_Stance = AbsJointWork;

% RELATIVE WORK
RelativeWork_Running
RelWork_Stance = RelWork;

disp('Joint work calculated for stance phase only')

%% Arrange data for repeated measures analysis (Trial_1 | Trial_2|...)
% UnstckDataWork_Running  % callback sript

%% Save data 

cd(DirResults)
save JointWork AbsWork_fullGait AbsWork_Swing AbsWork_Stance RelWork_fullGait RelWork_Swing RelWork_Stance Labels

%% Correlations Joint Work

CorrelationsJointWork

%% check outliers (Change just the filename and maintain the order from Labels)
% hip
filename = 'PosWork';
[Data,LB,IDxData] = findData (AbsJointWork,Labels,{filename},2);
D1 = Data(1:N,1); 
D2 = Data(N+1:2*N,1);
[MD,LB,UB,PercDif] = meanDif (D1,D2);
[Q,IQR,outliersQ1, outliersQ3] = quartile(PercDif);
[Mean, ADJmean] = CalcADJmean(PercDif,Covariate);
idx = [];
for ii = 1: length (outliersQ3)
    idx(end+1)=find(PercDif==outliersQ3(ii));
   idx(end+1)= idx(end)+18;
end
for ii = 1: length (outliersQ1)
    idx(end+1)=find(PercDif==outliersQ1(ii));
    idx(end+1)= idx(end)+18;
end
Spss = [D1;D2];
Spss(idx) = 0;
SpssAll(:,end+1)= Spss;
bar(PercDif)
title([filename ' hip'])

saveas(gca, [filename ' hip.jpeg']);

% knee 
D1 = Data(:,2);
D2 = Data(:,5);
[MD,LB,UB,PercDif] = meanDif (D1,D2);
[Q,IQR,outliersQ1, outliersQ3] = quartile(PercDif);
[Mean, ADJmean] = CalcADJmean(PercDif,Covariate);
idx = [];
for ii = 1: length (outliersQ3)
    idx(end+1)=find(PercDif==outliersQ3(ii));
   idx(end+1)= idx(end)+18;
end
for ii = 1: length (outliersQ1)
    idx(end+1)=find(PercDif==outliersQ1(ii));
    idx(end+1)= idx(end)+18;
end
Spss = [D1;D2];
Spss(idx) = 0;
SpssAll(:,end+1)= Spss;
bar(PercDif)
title([filename ' knee'])
saveas(gca, [filename ' knee.jpeg']);

% ankle
D1 = Data(:,3);
D2 = Data(:,6);
[MD,LB,UB,PercDif] = meanDif (D1,D2);
[Q,IQR,outliersQ1, outliersQ3] = quartile(PercDif);
[Mean, ADJmean] = CalcADJmean(PercDif,Covariate);
idx = [];
for ii = 1: length (outliersQ3)
    idx(end+1)=find(PercDif==outliersQ3(ii));
   idx(end+1)= idx(end)+18;
end
for ii = 1: length (outliersQ1)
    idx(end+1)=find(PercDif==outliersQ1(ii));
    idx(end+1)= idx(end)+18;
end
Spss = [D1;D2];
Spss(idx) = 0;
SpssAll(:,end+1)= Spss;
bar(PercDif)
title([filename ' ankle'])
saveas(gca, [filename ' ankle.jpeg']);
%

%% absolute work data per phase

% AbsoluteJointWork_PlotsStaked
AbsoluteJointWork_PlotsSameRow
cd(SaveDir)
saveas(gcf, sprintf('AbsoluteJointWork_perPhase.jpeg'));

%% relative work data per phase

% RelativeJointWork_PlotsStacked
RelativeJointWork_PlotsSameRow
cd(SaveDir)
saveas(gcf, sprintf('RelativeJointWork_perPhase.png'));

%% OutputSPSS to table word (copy 

[Table,txt] = ConvertOutputSPSS; 




