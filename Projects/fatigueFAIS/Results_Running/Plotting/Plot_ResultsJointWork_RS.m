%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plor Results for PhD paper 2 - Joint work before and after repeated sprints
% use after running "ResultsJointWork_RS"
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%
%INPUT
%   DirResults = string containing directory where the results from
%                "ResultsJointWork_RS" were stored. 
%   Trials = (optional) cell vector
%   
%-------------------------------------------------------------------------
%OUTPUT
%   Plots for absolute (W/kg) and relative (% of total)
%   work done by different joint moments as described by David Winter(1983)
%   DOI: 10.1097/00003086-198305000-00021
%
%   
%--------------------------------------------------------------------------
%% Satrt function
function Plot_ResultsJointWork_RS (DirResults,Trials)

fp = filesep;cd(DirResults)
load([DirResults fp 'ExternaBiomechanics.mat'])

%plots settings 
FS = 25; % fontsize 
LW = 1; % line width

%% Absolute work assign variables 
M = struct; %mean 
SE = struct; %standard error 
ALL = struct; % all data 
%Hip work (H1-H4)
%Knee work (K1-K4)
%Ankle work (A1-A2)

% select the work phases of interest 
% each column represents the mean/SE 
for k = 1:length(Trials)
    
    N = length(GroupData.TotalPosWork.(Trials{k}));
    %total work
    ALL.TPW(:,k) = GroupData.TotalPosWork.(Trials{k})';
    M.TotPosWork(k) = nanmean(GroupData.TotalPosWork.(Trials{k}));
    SE.TotPosWork(k) = nanstd(GroupData.TotalPosWork.(Trials{k}),0,2)/sqrt(N);
    
    ALL.TNW(:,k) = GroupData.TotalNegWork.(Trials{k})';
    M.TotNegWork(k) = nanmean(GroupData.TotalNegWork.(Trials{k}));
    SE.TotNegWork(k) = nanstd(GroupData.TotalPosWork.(Trials{k}),0,2)/sqrt(N);
    
    % hip
    ALL.H1(:,k) = GroupData.hip_flexion.AbsoluteWork.PosExtStance.(Trials{k})';
    M.H1(k) =  nanmean(GroupData.hip_flexion.AbsoluteWork.PosExtStance.(Trials{k}));
    SE.H1(k) =  nanstd(GroupData.hip_flexion.AbsoluteWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.H2(:,k) = GroupData.hip_flexion.AbsoluteWork.NegFlexStance.(Trials{k})';
    M.H2(k) =  nanmean(GroupData.hip_flexion.AbsoluteWork.NegFlexStance.(Trials{k}));
    SE.H2(k) =  nanstd(GroupData.hip_flexion.AbsoluteWork.NegFlexStance.(Trials{k}),0,2)/sqrt(N);    
    
    ALL.H3(:,k) = GroupData.hip_flexion.AbsoluteWork.PosFlexSwing.(Trials{k})';
    M.H3(k) =  nanmean(GroupData.hip_flexion.AbsoluteWork.PosFlexSwing.(Trials{k}));
    SE.H3(k) =  nanstd(GroupData.hip_flexion.AbsoluteWork.PosFlexSwing.(Trials{k}),0,2)/sqrt(N);
    
    ALL.H4(:,k) = GroupData.hip_flexion.AbsoluteWork.PosExtSwing.(Trials{k})';
    M.H4(k) =  nanmean(GroupData.hip_flexion.AbsoluteWork.PosExtSwing.(Trials{k}));
    SE.H4(k) =  nanstd(GroupData.hip_flexion.AbsoluteWork.PosExtSwing.(Trials{k}),0,2)/sqrt(N);
    
    % knee
    ALL.K1(:,k) = GroupData.knee.AbsoluteWork.NegExtStance.(Trials{k})';
    M.K1(k) =  nanmean(GroupData.knee.AbsoluteWork.NegExtStance.(Trials{k}));
    SE.K1(k) =  nanstd(GroupData.knee.AbsoluteWork.NegExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K2(:,k) = GroupData.knee.AbsoluteWork.PosExtStance.(Trials{k})';
    M.K2(k) =  nanmean(GroupData.knee.AbsoluteWork.PosExtStance.(Trials{k}));
    SE.K2(k) =  nanstd(GroupData.knee.AbsoluteWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K3(:,k) = GroupData.knee.AbsoluteWork.NegExtStance.(Trials{k})';
    M.K3(k) =  nanmean(GroupData.knee.AbsoluteWork.NegExtSwing.(Trials{k}));
    SE.K3(k) =  nanstd(GroupData.knee.AbsoluteWork.NegExtSwing.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K4(:,k) = GroupData.knee.AbsoluteWork.NegFlexSwing.(Trials{k})';
    M.K4(k) =  nanmean(GroupData.knee.AbsoluteWork.NegFlexSwing.(Trials{k}));
    SE.K4(k) =  nanstd(GroupData.knee.AbsoluteWork.NegFlexSwing.(Trials{k}),0,2)/sqrt(N);
    
    % Ankle
    ALL.A1(:,k) = GroupData.ankle.AbsoluteWork.NegExtStance.(Trials{k})';    
    M.A1(k) =  nanmean(GroupData.ankle.AbsoluteWork.NegExtStance.(Trials{k}));
    SE.A1(k) =  nanstd(GroupData.ankle.AbsoluteWork.NegExtStance.(Trials{k}),0,2)/sqrt(N);
        
    ALL.A2(:,k) = GroupData.ankle.AbsoluteWork.PosExtStance.(Trials{k})';    
    M.A2(k) =  nanmean(GroupData.ankle.AbsoluteWork.PosExtStance.(Trials{k}));
    SE.A2(k) =  nanstd(GroupData.ankle.AbsoluteWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
end

%% normality tests
Norm = [];
fld = fields(ALL);
for k = 1: size(ALL.TPW,2)
    for kk = 1: length(fld)
    [~,Norm(k,kk),~] = swtest(ALL.(fld{kk})(:,k),0.05);
    end
end
   
% total work
figure
bar(Norm(:,1:2),'DisplayName','Norm(:,1:2)')
hold on
plot([0 14],[0.05 0.05],'--k')
xticks ([2:2:14])
xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
legend('TotalPositiveWork' ,'TotalNegativeWork','p = 0.05')
ylabel('p-value')
title('Shapiro-Wilk test')
mmfn
cd(DirResults)
saveas(gcf, sprintf('Normality_Total.tif'));

% hip work
figure
bar(Norm(:,3:6))
hold on
plot([0 14],[0.05 0.05],'--k')
xticks ([2:2:14])
xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
legend('H1','H2','H3','H4','p = 0.05')
ylabel('p-value')
title('Shapiro-Wilk test')
mmfn
cd(DirResults)
saveas(gcf, sprintf('Normality_Hip.tif'));

% Knee work
figure
bar(Norm(:,7:10))
hold on
plot([0 14],[0.05 0.05],'--k')
xticks ([2:2:14])
xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
legend('K1','K2','K3','K4','p = 0.05')
ylabel('p-value')
title('Shapiro-Wilk test')
mmfn
cd(DirResults)
saveas(gcf, sprintf('Normality_Knee.tif'));

% ankle work
figure
bar(Norm(:,11:12))
hold on
plot([0 14],[0.05 0.05],'--k')
xticks ([2:2:14])
xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
legend('A1','A2','p = 0.05')
ylabel('p-value')
title('Shapiro-Wilk test')
mmfn
cd(DirResults)
saveas(gcf, sprintf('Normality_Ankle.tif'));

%% save in excel SPSS formated data 
firstCol = split(sprintf(' s%.f',1:N),' ');
Norm (2:end+1,2:end+1) = Norm;
Norm = num2cell(Norm);
Norm{1,1}=[];
Norm(2:end,1) = Trials';
Norm(1,2:end) = fld';

xlswrite('SPSSFormat.xlsx',Norm,'Normality','A1');


for kk = 1: length(fld)
    xlswrite('SPSSFormat.xlsx',ALL.(fld{kk}),fld{kk},'B2');
    xlswrite('SPSSFormat.xlsx',Trials,fld{kk},'B1');
    xlswrite('SPSSFormat.xlsx',firstCol,fld{kk},'A1');
end

% use after SPSS to calculate ES for non-parametric tests
% [Z,P,ES] = ConvertOutput_MannWhitney

%% Plot Positive (absolute)
figure
hold on
cMat = lines;
MarkerStyles = {'o','d','x','^','v','s','+','*'};
style = {'-','--',':','-.','-','--',':','-.'};
fld = {'TotPosWork','H1','H3','H4','K2','A2'};
for k = 1:length(fld)
    x = 1:length(M.(fld{k}));
    yData = M.(fld{k});
    BarData = SE.(fld{k});
    errorbar(x, yData, zeros(size(yData)),BarData, '.', 'color','k');
    plot(x,yData,style{k},...
        'MarkerFaceColor',cMat(k,:),...
        'MarkerEdgeColor',cMat(k,:),...
        'Marker',MarkerStyles{k},...
        'LineStyle','none',...
        'MarkerSize',8)
end
% p1 = plotShadedSD ([TotPosWork; H1; H3; H4; K2; A2]',...
%                     [TotPosWork_SE; H1_SE; H3_SE; H4_SE; K2_SE; A2_SE]');
ax = gca;
ax.Children = flip(ax.Children);
legend(ax.Children([2:2:length(ax.Children) 1]),{'Total work','H1','H3','H4','K2','A2','SE'})
mmfn
% xticks ([2:2:14])
% xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
xticks ([1:14])
xticklabels ({'B1' 'B2' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11' 'S12'})
ylabel(sprintf('Work \n (W/Kg)'))
ax.Position = [0.2 0.11 0.6 0.81];
ax.Legend.Position = [0.8513    0.4937    0.1063    0.1697];
ax.LineWidth = LW;
for k = 2:2:length(ax.Children)
    ax.Children(k).LineWidth = LW;
end
title('Absolute positive work')
ax.Children = flip(ax.Children); % do this to place the error bars behind the markers
ax.FontSize = FS;
cd(DirResults)
saveas(gcf, sprintf('AbsolutePositiveWork.tif'));
% plot vertical ylabel
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position = [-1 3.5 -1];
ax.Position = [0.15 0.11 0.65 0.81];
saveas(gcf, sprintf('AbsolutePositiveWork_verLabel.tif'));

%% Plot Negative (absolute)
figure
hold on
cMat = lines;
MarkerStyles = {'o','d','x','^','v','s','+','*'};
style = {'-','--',':','-.','-','--',':','-.'};
fld = {'TotNegWork','H2','K1','K3','K4','A1'};
for k = 1:length(fld)
    x = 1:length(M.(fld{k}));
    yData = M.(fld{k});
    BarData = SE.(fld{k});
    errorbar(x, yData, zeros(size(yData)),BarData, '.', 'color','k');
    plot(x,yData,style{k},...
        'MarkerFaceColor',cMat(k,:),...
        'MarkerEdgeColor',cMat(k,:),...
        'Marker',MarkerStyles{k},...
        'LineStyle','none',...
        'MarkerSize',8)
end
% p1 = plotShadedSD ([TotNegWork; H2; K1; K3; K4; A1]',...
%                     [TotNegWork_SE; H2_SE; K1_SE; K3_SE; K4_SE; A1_SE]');
ax = gca;
ax.Children = flip(ax.Children);
legend(ax.Children([2:2:length(ax.Children) 1]),{'Total work','H2','K1','K3','K4','A1','SE'})
mmfn
% xticks ([2:2:14])
% xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
xticks ([1:14])
xticklabels ({'B1' 'B2' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11' 'S12'})
ylabel(sprintf('Work \n (W/Kg)'))
ax = gca;
ax.Position = [0.2 0.11 0.6 0.81];
ax.Legend.Position = [0.8513    0.4937    0.1063    0.1697];
ax.LineWidth = LW;
for k = 2:2:length(ax.Children)
    ax.Children(k).LineWidth = LW;
end
title('Absolute negative work')
ax.Children = flip(ax.Children); % do this to place the error bars behind the markers
ax.FontSize = FS;
cd(DirResults)
saveas(gcf, sprintf('AbsoluteNeagtiveWork.tif'));
% plot vert ylabel
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position(1) = -1;
ax.Position = [0.15 0.11 0.65 0.81];
saveas(gcf, sprintf('AbsoluteNeagtiveWork_verLabel.tif'));

%% Relative work calculations
M = struct; %mean 
SE = struct; %standard error 
ALL = struct; % all data 
%Hip work (H1-H4)
%Knee work (K1-K4)
%Ankle work (A1-A2)

% select the work phases of interest 
% each column represents the mean/SE 
for k = 1:length(Trials)
    
    N = length(GroupData.TotalPosWork.(Trials{k}));  
    % hip
    ALL.H1(:,k) = GroupData.hip_flexion.RelativeWork.PosExtStance.(Trials{k})';
    M.H1(k) =  nanmean(GroupData.hip_flexion.RelativeWork.PosExtStance.(Trials{k}));
    SE.H1(k) =  nanstd(GroupData.hip_flexion.RelativeWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.H2(:,k) = GroupData.hip_flexion.RelativeWork.NegFlexStance.(Trials{k})';
    M.H2(k) =  nanmean(GroupData.hip_flexion.RelativeWork.NegFlexStance.(Trials{k}));
    SE.H2(k) =  nanstd(GroupData.hip_flexion.RelativeWork.NegFlexStance.(Trials{k}),0,2)/sqrt(N);    
    
    ALL.H3(:,k) = GroupData.hip_flexion.RelativeWork.PosFlexSwing.(Trials{k})';
    M.H3(k) =  nanmean(GroupData.hip_flexion.RelativeWork.PosFlexSwing.(Trials{k}));
    SE.H3(k) =  nanstd(GroupData.hip_flexion.RelativeWork.PosFlexSwing.(Trials{k}),0,2)/sqrt(N);
    
    ALL.H4(:,k) = GroupData.hip_flexion.RelativeWork.PosExtSwing.(Trials{k})';
    M.H4(k) =  nanmean(GroupData.hip_flexion.RelativeWork.PosExtSwing.(Trials{k}));
    SE.H4(k) =  nanstd(GroupData.hip_flexion.RelativeWork.PosExtSwing.(Trials{k}),0,2)/sqrt(N);
    
    % knee
    ALL.K1(:,k) = GroupData.knee.RelativeWork.NegExtStance.(Trials{k})';
    M.K1(k) =  nanmean(GroupData.knee.RelativeWork.NegExtStance.(Trials{k}));
    SE.K1(k) =  nanstd(GroupData.knee.RelativeWork.NegExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K2(k,:) = GroupData.knee.RelativeWork.PosExtStance.(Trials{k})';
    M.K2(k) =  nanmean(GroupData.knee.RelativeWork.PosExtStance.(Trials{k}));
    SE.K2(k) =  nanstd(GroupData.knee.RelativeWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K3(:,k) = GroupData.knee.RelativeWork.NegExtStance.(Trials{k})';
    M.K3(k) =  nanmean(GroupData.knee.RelativeWork.NegExtSwing.(Trials{k}));
    SE.K3(k) =  nanstd(GroupData.knee.RelativeWork.NegExtSwing.(Trials{k}),0,2)/sqrt(N);
    
    ALL.K4(:,k) = GroupData.knee.RelativeWork.NegFlexSwing.(Trials{k})';
    M.K4(k) =  nanmean(GroupData.knee.RelativeWork.NegFlexSwing.(Trials{k}));
    SE.K4(k) =  nanstd(GroupData.knee.RelativeWork.NegFlexSwing.(Trials{k}),0,2)/sqrt(N);
    
    % Ankle
    ALL.A1(:,k) = GroupData.ankle.RelativeWork.NegExtStance.(Trials{k})';    
    M.A1(k) =  nanmean(GroupData.ankle.RelativeWork.NegExtStance.(Trials{k}));
    SE.A1(k) =  nanstd(GroupData.ankle.RelativeWork.NegExtStance.(Trials{k}),0,2)/sqrt(N);
        
    ALL.A2(:,k) = GroupData.ankle.RelativeWork.PosExtStance.(Trials{k})';    
    M.A2(k) =  nanmean(GroupData.ankle.RelativeWork.PosExtStance.(Trials{k}));
    SE.A2(k) =  nanstd(GroupData.ankle.RelativeWork.PosExtStance.(Trials{k}),0,2)/sqrt(N);
end

%% Plot Positive (relative)
figure
hold on
cMat = lines;
MarkerStyles = {'o','d','x','^','v','s','+','*'};
style = {'-','--',':','-.','-','--',':','-.'};
fld = {'TotPosWork','H1','H3','H4','K2','A2'};
M.TotPosWork = NaN(1,length(M.H1)); % use NaN so the colours match between Relative and absolute plots
SE.TotPosWork = NaN(1,length(M.H1));
for k = 1:length(fld)
    x = 1:length(M.(fld{k}));
    yData = M.(fld{k});
    BarData = SE.(fld{k});
    errorbar(x, yData, zeros(size(yData)),BarData, '.', 'color','k');
    plot(x,yData,style{k},...
        'MarkerFaceColor',cMat(k,:),...
        'MarkerEdgeColor',cMat(k,:),...
        'Marker',MarkerStyles{k},...
        'LineStyle','none',...
        'MarkerSize',8)
end
% p1 = plotShadedSD ([Total; H1; H3; H4; K2; A2]',...
%                     [Total; H1_SE; H3_SE; H4_SE; K2_SE; A2_SE]');
ax = gca;
ax.Children = flip(ax.Children);
% start legend from 3 because the line 1 is the Total which is NaN
legend(ax.Children([4:2:length(ax.Children) 1]),{'H1','H3','H4','K2','A2','SE'})
mmfn
% xticks ([2:2:14])
% xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
xticks ([1:14])
xticklabels ({'B1' 'B2' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11' 'S12'})
ylabel(sprintf('Work \n (%% of total)'))
ax.Position = [0.2 0.11 0.6 0.81];
ax.Legend.Position = [0.8513    0.4937    0.1063    0.1697];
ax.LineWidth = LW;
for k = 2:2:length(ax.Children)
    ax.Children(k).LineWidth = LW;
end
title('Relative positve work')
ax.Children = flip(ax.Children); % do this to place the error bars behind the markers
ax.FontSize = FS;
cd(DirResults)
saveas(gcf, sprintf('RelativePositiveWork.tif'));
% plot ylabel vertical
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position(1) = -1.5;
ax.Position = [0.15 0.11 0.65 0.81];
saveas(gcf, sprintf('RelativePositiveWork_verLabel.tif'));

%% Plot Negative (relative)
figure
hold on
cMat = lines;
MarkerStyles = {'o','d','x','^','v','s','+','*'};
style = {'-','--',':','-.','-','--',':','-.'};
fld = {'TotNegWork','H2','K1','K3','K4','A1'};
M.TotNegWork = NaN(1,length(M.H1)); % use NaN so the colours match between Relative and absolute plots
SE.TotNegWork = NaN(1,length(M.H1));
for k = 1:length(fld)
    x = 1:length(M.(fld{k}));
    yData = M.(fld{k});
    BarData = SE.(fld{k});
    errorbar(x, yData, zeros(size(yData)),BarData, '.', 'color','k');
    plot(x,yData,style{k},...
        'MarkerFaceColor',cMat(k,:),...
        'MarkerEdgeColor',cMat(k,:),...
        'Marker',MarkerStyles{k},...
        'LineStyle','none',...
        'MarkerSize',8)
end
% p1 = plotShadedSD ([Total; H2; K1; K3; K4; A1]',...
%                     [Total; H2_SE; K1_SE; K3_SE; K4_SE; A1_SE]');
ax = gca;
ax.Children = flip(ax.Children);
% start legend from 3 because the line 1 is the Total which is NaN
legend(ax.Children([4:2:length(ax.Children) 1]),{'H2','K1','K3','K4','A1','SE'})
mmfn
% xticks ([2:2:14])
% xticklabels ({'Baseline' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
xticks ([1:14])
xticklabels ({'B1' 'B2' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11' 'S12'})
ylabel(sprintf('Work \n (%% of total)'))
ax.Position = [0.2 0.11 0.6 0.81];
ax.Legend.Position = [0.8513    0.4937    0.1063    0.1697];
ax.LineWidth = LW;
for k = 2:2:length(ax.Children)
    ax.Children(k).LineWidth = LW;
end
title('Relative negative work')
ax.Children = flip(ax.Children); % do this to place the error bars behind the markers
ax.FontSize = FS;
cd(DirResults)
saveas(gcf, sprintf('RelativeNegativeWork.tif'));
% plot ylabel vertical
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position(1) = -1.5;
ax.Position = [0.15 0.11 0.65 0.81];
saveas(gcf, sprintf('RelativeNegativeWork_verLabel.tif'));

%% Velocity
load([DirResults fp 'SpatioTemporal_Sept20.mat'])

N = size(MaxSpeed,2);
Vmax_OG = max(MaxSpeed(1:2,:));
% Vmax_OG(end) = MaxSpeed(end,2);
First_Percent = MaxSpeed(3,:)./Vmax_OG*100;
Vavg = struct;
Vse = struct;
CI95 = struct;
OGSpeed = MaxSpeed(1:end,:);
%remove outliers
for k = 1: size(OGSpeed,1)
   [Q,IQR,outliersQ1, outliersQ3,NoOutliers] =  quartile(OGSpeed(k,:)'); 
   OGSpeed(k,:)= NoOutliers';
end
 treadmillSpeed(treadmillSpeed==0)= NaN;
for k = 1: size(treadmillSpeed,1)
    [Q,IQR,outliersQ1, outliersQ3,NoOutliers] =  quartile(treadmillSpeed(k,:)');
    treadmillSpeed(k,:)= NoOutliers';
end

VPerc_OG = OGSpeed./Vmax_OG*100;
Vavg.OG = nanmean(VPerc_OG,2);
Vse.OG = nanstd(VPerc_OG,0,2)/sqrt(N);
CI95.OG = nanstd(VPerc_OG,0,2)/sqrt(N)*1.96;

Vmax_T = treadmillSpeed(1,:);
VPerc_T = treadmillSpeed./Vmax_T*100;
Vavg.T = nanmean(VPerc_T,2);
Vavg.T = [NaN; NaN; Vavg.T];% add the two baseline trials 
Vse.T = nanstd(VPerc_T,0,2)/sqrt(N);
Vse.T = [NaN; NaN; Vse.T];
CI95.T = nanstd(VPerc_T,0,2)/sqrt(N)*1.96;
CI95.T= [NaN; NaN; CI95.T];

%% plot individual data 
% figure 
% hold on
% for k = 1:size(VPerc_OG)
%     plot(x,VPerc_OG(:,k),'.','MarkerSize',20)
% end
% mmfn
%% plot mean(95%CI) overground and treadmill speed decreases
figure
hold on
cMat = lines;
MarkerStyles = {'o','d','x','^','v','s','+','*'};
style = {'-','--',':','-.','-','--',':','-.'};
fld = fields(Vavg);
for k = 1:length(fld)
    x = 1:length(Vavg.(fld{k}));
    yData = Vavg.(fld{k});
    BarData = Vse.(fld{k});
    errorbar(x, yData, zeros(size(yData)),BarData, '.', 'color','k');
    plot(x,yData,style{k},'MarkerFaceColor',cMat(k,:),'MarkerEdgeColor',cMat(k,:),...
        'Marker',MarkerStyles{k},'LineStyle','none','MarkerSize',8)
end

ax = gca;
ax.Children = flip(ax.Children);
legend(ax.Children([2:2:length(ax.Children) 1]),{'overground','treadmill' 'SE'})
mmfn
% xticks ([1 2:2:14])
% xticklabels ({'B1' 'B2' 'Set 2' 'Set 4' 'Set 6' 'Set 8' 'Set 10' 'Set 12'})
xticks ([1:14])
xticklabels ({'B1' 'B2' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11' 'S12'})
ylabel(sprintf(' Running speed \n(%% first sprint)'))
ax.Position = [0.25 0.11 0.6 0.81];
ax.Legend.Position = [0.85 0.60 0.11 0.10];
ax.Children = flip(ax.Children); % do this to place the error bars behind the markers
ax.FontSize = FS;
ax.LineWidth = LW;
title('')
cd(DirResults)
saveas(gcf, sprintf('SpeedChange.tif'));
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position(1) = -1;
ax.Position = [0.15 0.11 0.65 0.81];
saveas(gcf, sprintf('SpeedChange_verLabel.tif'));

%% Change in swing work vs change in speed
% 'H3','H4','K3','K4' difference
flds = {'H3','H4','K3','K4','A1','A2'};
Diff = struct;
for k = 1: length(flds)
    Diff.(flds{k}) = ALL.(flds{k})(:,end)./nanmean(ALL.(flds{k})(:,1:2),2).*100;
    [Q,IQR,outliersQ1, outliersQ3] =  quartile(Diff.(flds{k}));
    if ~isempty (outliersQ1) 
       for kk = 1:length(outliersQ1)
        Diff.(flds{k})(find(Diff.(flds{k})==outliersQ1(kk))) = NaN;
       end
    end
        
    if ~isempty (outliersQ3) 
       for kk = 1:length(outliersQ3)
        Diff.(flds{k})(find(Diff.(flds{k})==outliersQ3(kk))) = NaN;
       end
    end
end

% VPerc_OG = VPerc_OG';
Vdiff = 100-VPerc_OG(end,:);

%plot correlations (not finished...)
[ax,~,FC,LR] = tight_subplotBG(length(flds),0,[0.02 0.02],[0.1 0.1],[0.2 0.02],[250 140 1100 600]);
for k = 1:length(flds)
    x = Vdiff';
    y = Diff.(flds{k});
    x(isnan(y)) = NaN;
    x = -x;
    axes(ax(k));hold on;
    [rsquared,Rsquared_p, p] = plotCorr (x,y,1,0.05,[0 0 0],5);             % create the plot with the shaded area [plotCorr (x,y,n,Alpha,Color, MakerSize)]
    R = num2str(sqrt(rsquared));
    yticklabels(yticks)
    title([flds{k} '(r=' R ')'])
    if any(k==FC); ylabel('\Delta work');end
    if any(k==LR); xlabel('\Delta speed');end
end

%% normality 
Norm = [];
NotNormalDist = 0;
NormalDist =0;
for kk = 1: size(OGSpeed,1)
    [~,Norm(1,kk),~] = swtest(OGSpeed(kk,:),0.05);
end
NotNormalDist = NotNormalDist + nnz(find(Norm<0.05));
NormalDist = NormalDist + nnz(find(Norm>=0.05));
x1 = max(OGSpeed(1:2,:));
x2 = OGSpeed(end,:);
d = computeCohen_d(x1, x2,'paired');

% normality Step freq
Norm = [];
StepFreq (StepFreq==0) = NaN;
for kk = 1: size(StepFreq,1)
    [~,Norm(1,kk),~] = swtest(StepFreq(kk,:),0.05);
end
NotNormalDist = NotNormalDist + nnz(find(Norm<0.05));
NormalDist = NormalDist + nnz(find(Norm>=0.05));
x1 = max(StepFreq(1:2,:))';
x2 = StepFreq(end,:)';
d = computeCohen_d(x1, x2,'paired');

% normality Step length
Norm = [];
StepLength (StepLength==0) = NaN;
for kk = 1: size(StepLength,1)
    [~,Norm(1,kk),~] = swtest(StepLength(kk,:),0.05);
end
NotNormalDist = NotNormalDist + nnz(find(Norm<0.05));
NormalDist = NormalDist + nnz(find(Norm>=0.05));
x1 = nanmean(StepLength(1:2,:));
x2 = StepLength(end,:);
d = computeCohen_d(x1, x2,'paired');

% contact time 
Norm = [];
for kk = 1: size(contactTime,1)
    [~,Norm(1,kk),~] = swtest(contactTime(kk,:),0.05);
end
NotNormalDist = NotNormalDist + nnz(find(Norm<0.05));
NormalDist = NormalDist + nnz(find(Norm>=0.05));
x1 = contactTime(1,:);
x2 = contactTime(end,:);
d = computeCohen_d(x1, x2,'paired');

% contact time (% of stride time) 
mean(CTPercent(1,:));
mean(CTPercent(2,:));
d = computeCohen_d(CTPercent(1,:), CTPercent(2,:),'paired');

%% plot step location
figure
y=[]; x=[];
StepLocation(StepLocation==0)=NaN;
for k = 1:size(StepLocation,1)
    x = [x StepLocation(k,:)];
    y = [y OGSpeed(k,:)];
end
% delete NaNs and steps greater than 8.2 or lower than 5.5
y(isnan(x))=NaN;
x(isnan(y))=NaN;
idxLow = find(x<5.5);
idxHigh = find(x>8.2);
y([idxLow idxHigh]) = NaN;
x([idxLow idxHigh]) = NaN;
x = x(~isnan(x));
y = y(~isnan(y));

[r2,Rsquared_p, p] = plotCorr (x',y',1,0.05,[0.2 0.2 0.2],5);  
ylim([0 9])
xlim([0 9])
ylabel(sprintf('Max speed \n (m/s)      '))
xlabel('Step location from starting position (m)')
legend('Individual trials',sprintf('r = %.2f (p < 0.01)',sqrt(r2)),'95%CI')
mmfn
ax = gca;
ax.Position = [0.2 0.15 0.6 0.75];
ax.Children(2).LineStyle='--';
ax.FontSize = FS;
ax.LineWidth = LW;
ax.Legend.Position = [0.8513    0.4937    0.1063    0.1];

cd(DirResults)
saveas(gcf, sprintf('Speed_vs_Location.tif'));
ylabel(sprintf('Max speed (m/s)'))
ax.YLabel.Rotation = 90;
ax.YLabel.HorizontalAlignment = 'center';
ax.YLabel.Position = [-0.5 4.5 -1];
ax.Position = [0.15 0.15 0.65 0.75];
saveas(gcf, sprintf('Speed_vs_Location_verLabel.tif'));


close all 
disp(' ')
fprintf('Figures saved in %s \n',DirResults)