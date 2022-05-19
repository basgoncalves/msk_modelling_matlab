% mmfn_corrJointWork_2
% use with CorrelationsJointWork

cMat = convertRGB([176, 104, 16;16, 157, 176;136, 16, 176;176, 16, 109;31, 28, 28]);  % color scheme 2 (Bas)

f1 = figure;
axes1 = axes('Parent',f1,'Position',[0.147421524663677 0.11 0.757578475336323 0.815]);
hold(axes1,'on');
Ycol = find(contains (LabelsRM,Yname));
Xcol = find(contains (LabelsRM,Xname));
N = max (AbsWorkRM(:,1));       % number of traces in traces (correlations)
rsquared = [];
Rsquared_p =[];
for ii = 1:N
    G1 = AbsWorkRM(:,1)==ii;
    if size(AbsWorkRM(G1,Ycol),2)>1
        y = diff(AbsWorkRM(G1,Ycol),1,2);
    else 
        y = (AbsWorkRM(G1,Ycol));
    end
    x = AbsWorkRM(G1,Xcol);
    
     [rsquared(end+1),Rsquared_p(end+1), p] = plotCorr (x,y,1,0.05,cMat(ii,:));
  
    
    set(p(1),'Marker',Styles{ii},'MarkerSize',MSize,'MarkerFaceColor',cMat(ii,:),'MarkerEdgeColor','none')
    set(p(2),'LineStyle',':','LineWidth',2,'Color',cMat(ii,:))
    c = corrcoef(x,y); r(ii) = c(1,2)^2;
end

CorrSpeedWork(end+1,:)= rsquared;           % variable with the coefficients of determintation
CorrSpeedWork_P(end+1,:) = Rsquared_p;

xlim([3 7])
ylim ([0 8])
set(gca,'YAxisLocation','origin')
plot ([min(xlim) max(xlim)],[0 0],'Color',[0.4 0.4 0.4]) %line crossing zero

ax= gca;

if contains(LegOn,'on')
% lg = legend (ax.Children([1:3:9,8,9]),sprintf('hip (r^2 = %.2f)',r(1)),sprintf('knee (r^2 = %.2f)',r(2)),sprintf('ankle (r^2 = %.2f)',r(3)));
lg = legend (ax.Children([10,7,4]),'hip','knee','ankle');
set (lg, 'Box', 'off','FontSize',20)
end

Nxspaces = length(xticks)-1;
Xoffset = (max(xlim)-min(xlim))/(Nxspaces);         % devide by

Nyspaces = length(yticks)-1;
Yoffset = (max(ylim)-min(ylim))/(Nyspaces);         % devide by


xlabel (XLab,'Position',[mean(xlim) min(ylim)-Yoffset 0],'HorizontalAlignment','center')
ylb = ylabel (YLab,'Position',[min(xlim)-Yoffset mean(ylim) 0],'VerticalAlignment','top','HorizontalAlignment','center', 'Rotation', 90);
title(Titl,'Position',[min(xlim) max(ylim)+Yoffset 0],'VerticalAlignment','middle','HorizontalAlignment','right', 'Rotation', 0);
mmfn

ax.FontSize = FS;

xlabel (XLab,'Position',[mean(xlim) min(ylim)-Yoffset 0],'HorizontalAlignment','center')
ylb = ylabel (YLab,'Position',[min(xlim)-Yoffset mean(ylim) 0],'VerticalAlignment','top','HorizontalAlignment','center', 'Rotation', 90);
title(Titl,'Position',[min(xlim)-Yoffset max(ylim)+Yoffset 0],'VerticalAlignment','middle','HorizontalAlignment','right', 'Rotation', 0);
