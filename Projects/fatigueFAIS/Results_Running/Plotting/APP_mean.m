%% APP_mean
% arrange plot joint powers
% use with Plot Mean Biomech

if ~exist('FS')
    answer = inputdlg('please select font size (e.g. 12) or create vairable called "FS"');
    FS = str2num(answer{1});
end


%% y axis range and ticks

if range(ylim)/10>1
    ylim(round(ylim))
    yticks(round(min(ylim):range(ylim)/Nyticks:max(ylim)))
    yt = yticks; 
else 
    yl= ylim;
    yl = [floor(yl(1)) ceil(yl(2))]; 
    ylim(yl)
    yticks(round(min(yl):range(yl)/Nyticks:max(yl),1))
    
end

%% Axis origin and xlabel position
 cMat = convertRGB([176, 104, 16;16, 157, 176;136, 16, 176;176, 16, 109;31, 28, 28]);  % color scheme 2 (Bas)

ax = gca;
ax.Children = flip(ax.Children);

Lstyles = {'-','-.'};
MStyles = {'hexagram','*'};
c = gray;
colormap('gray');
for ii = 1:2:length(ax.Children)
    colorIdx = (ii+1)/2;
    ax.Children(ii).Color = cMat(colorIdx,:);
    ax.Children(ii).LineWidth = 2;
    ax.Children(ii).LineStyle =Lstyles{colorIdx};
%     ax.Children(ii).Marker = MStyles{colorIdx};
%     ax.Children(ii).MarkerFaceColor =cMat(colorIdx,:);
%     ax.Children(ii).MarkerSize = 1;
%     ax.Children(ii).MarkerIndices = [1:5:length(ax.Children(ii).XData)];
end

ax.Children = flip(ax.Children);


xlb = xlabel('');
xlbPos = xlb.Position;
xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
set(gca,'box', 'off', 'FontSize', FS);
set(gcf,'Color',[1 1 1]);
xlb.Position(2)= xlbPos(2)*1.2;
xlb.VerticalAlignment = 'middle';
set (xlb,'FontSize',FS,'VerticalAlignment','top','HorizontalAlignment','center')


%% xticks
xlim([0 110])
xticks([0:50:100]);        % timeTrial / number of ticks = length of each time interval)

plot ([min(xlim) max(xlim)], [0 0],'Color', [0.15 0.15 0.15])
%% make the y axis show positive and negative values
 yt = yticks;
 
if max(yt) <=0                % if y axis ends in Zero
    yt = yticks;
    yt = yt(end-1);
    ylim([min(ylim) -yt])          % add one tick above zero
    
elseif min(yt) >=0            % if y axis starts in Zero
    yt = yticks;
    yt = yt(1+1);
    ylim([-yt max(ylim)])          % add one tick below zero
    
end
%% foot contact = vertical bars
color =convertRGB ([129, 148, 163]);            % grey (see https://bit.ly/39DayNS)

plotVert(MeanFootContact,{'-','-'},{'k',color},{1,1});          % (data,LineStyle,LineColor,LineWidth)
plotVert(MeanFootContact + SDFootContact/sqrt(N)*1.96,{':','--'},{'k',color});
plotVert(MeanFootContact - SDFootContact/sqrt(N)*1.96,{':','--'},{'k',color});
%% text 
% Arrow = text(Xpos,Ymax,'\leftarrow');
% TextHS = text(Xpos*1.2,Ymax,'Foot Strike');
% set(Arrow,'Position', [Xpos,Ymax],'Rotation',0,'FontSize',FS,'HorizontalAlignment','left','VerticalAlignment','top');
% set(TextHS,'Position', [Xpos,Ymax],'Rotation',0,'FontSize',FS,'HorizontalAlignment','left','VerticalAlignment','top');


%% legend  - place legend at XX% of the length and centered in height
%         XX = 0.8;
%         lhd = legend (LegendNames,'Interpreter','none','Location','best');
%         pos = get(lhd,'Position'); pos(1)= XX; pos(2)=(1-pos(4))/4;
%         set(lhd,'Position',pos);