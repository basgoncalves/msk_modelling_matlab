%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% plots_corrJointWork_MaxSpeed
% use with CorrelationsJointWork
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------

%% plots_corrJointWork_MaxSpeed
cMat = convertRGB([176, 104, 16;16, 157, 176;136, 16, 176;176, 16, 109;31, 28, 28]);  % color scheme 2 (Bas)
f1 = figure;
axes1 = axes('Parent',f1,'Position',[0.147421524663677 0.11 0.757578475336323 0.815]);
hold(axes1,'on');
Ycol = find(contains (CorrelationLabels,Yname));
Xcol = find(contains (CorrelationLabels,'Velocity'));
N = length(Ycol);
LBtxt={};

% loop through groups
for ii = 1:N
    col = Ycol(ii);
    G1 = WorkData(:,1)==1;     % index of the group
    G2 = WorkData(:,1)==2;
    
    GroupData = [abs(WorkData(G1,col)) abs(WorkData(G2,col))];
    %     GroupData = deleteZeros (GroupData,2);
     
    y = GroupData(:,1);        % work pre
    x = WorkData(G1,Xcol);       % speed pre
    
    [rsquared,Rsquared_p, p] = plotCorr (x,y,1,0.05,cMat(ii,:),10);             % create the plot with the shaded area [plotCorr (x,y,n,Alpha,Color, MakerSize)]
    
    set(p(1),'Marker',Styles{ii},'MarkerSize',MSize,'MarkerFaceColor',cMat(ii,:),'MarkerEdgeColor','none')
    set(p(2),'LineStyle',':','LineWidth',2,'Color',cMat(ii,:))
    c = corrcoef(x,y); r(ii) = c(1,2); pval(ii) = Rsquared_p;
    
    % add caption 
    LBtxt{ii} = sprintf('%s (r=%.2f)',CorrelationLabels{col},r(ii));

end

xlim ([0,8])
% print the pvalues 
for yy = 1:length(Yname)
fprintf ('r^2 for %s = %.3f | pvalue for %s = %.3f \n',Yname{yy}, r(yy),Yname{yy}, pval(yy))
end

% plotVert (0,{'-'})
% plot ([min(xlim) max(xlim)],[0 0],'Color',[0.4 0.4 0.4]) %line crossing zero

ax= gca;
ax.Children = flip(ax.Children);
% ax.YAxisLocation = 'right';        % SET LOCATION OF Y AXIS

if contains(LegOn,'on')
% lg = legend (ax.Children([1:3:9,8,9]),sprintf('hip (r^2 = %.2f)',r(1)),sprintf('knee (r^2 = %.2f)',r(2)),sprintf('ankle (r^2 = %.2f)',r(3)));
lg = legend (ax.Children([1:3:9]),'hip','knee','ankle');
set (lg, 'Box', 'off','FontSize',20)
end

% yt = yticks;  
% PosXlb = min(ylim)-(abs(xt(2)-yt(1))/4*3);
% xlabel (XLab,'Position',[mean(xlim) PosXlb 0],'HorizontalAlignment','center')

ylb = ylabel ('Work (J/kg)','VerticalAlignment','bottom','HorizontalAlignment','center', 'Rotation', 90);

xlabel (XLab,'HorizontalAlignment','center')
% ylb = ylabel (YLab,'VerticalAlignment','bottom','HorizontalAlignment','center', 'Rotation', 90);

PosTit_y = max(ylim)+abs(max(ylim))*0.3;
PosTit_x = min(xlim)-(abs(xt(2)-xt(1))/2);          % y label position at 4/3 of one tick space before the min of x axis 
title(Titl,'Position',[PosTit_x PosTit_y 0],'VerticalAlignment','middle','HorizontalAlignment','left', 'Rotation', 0,'FontSize',FS);

ax = gca;
ax.Children = flip(ax.Children);        % flip the data again for when the figures are merged in (CorrelationsJointWork)
LBtxt = flip (LBtxt);
lg = legend(ax.Children([3:3:3*N]),LBtxt);  % each series has 2 lines (scatter and trend) plus 1 patch (CI)
lg.Position = [0.6381    0.9405    0.2464    0.0774];

mmfn
ax.FontSize = FS;
ax.Position = [0.14 0.2 0.76 0.75];

