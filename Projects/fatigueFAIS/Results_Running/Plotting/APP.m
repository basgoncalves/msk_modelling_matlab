%% APP
% arrange plot joint powers

if ~exist('FS')
    answer = inputdlg('please select font size (e.g. 12) or create vairable called "FS"');
    FS = str2num(answer{1});
end

xlb = xlabel('');
xlbPos = xlb.Position;

%% axis titles and positions

ax = gca;
% ax.XAxisLocation = 'origin';
% ax.YAxisLocation = 'origin';


ax.Children = flip(ax.Children);
Lstyles = {'-','-.'};
MStyles = {'^','diamond'};
for ii = 1: length(ax.Children)% perform double nth order butterworth filter on several columns of data
    ax.Children(ii).Color = cMat(ii,:);
    ax.Children(ii).LineWidth = 1.5;
      ax.Children(ii).LineStyle =Lstyles{ii};
%     ax.Children(ii).Marker = MStyles{ii};
%     ax.Children(ii).MarkerFaceColor =cMat(ii,:);
%     ax.Children(ii).MarkerSize = 3;
%     ax.Children(ii).MarkerIndices = [1:8:length(ax.Children(ii).XData)];
end
ax.Children = flip(ax.Children);

% x label
xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
set(gca,'box', 'off', 'FontSize', FS);
set(gcf,'Color',[1 1 1]);
xlb = xlabel ('Gait cycle (s)');
xlb.Position(2)= xlbPos(2)*1.2;
xlb.VerticalAlignment = 'top';
set (xlb,'FontSize',FS,'VerticalAlignment','top','HorizontalAlignment','center')

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

% 
% oldLim = ylim;
% ylim([0 200]);
ylb = ylabel(sprintf('Joint Power (W/Kg)'));
ylb.FontSize = FS;
% Pos_ylb = ylb.Position;
% ylim(oldLim);
% ylb.Position(1) = Pos_ylb(1); 

%% xtick labels with only 2 decimal points
xlim ([0 size(Angle,1)])
xticks([0:size(Angle,1)/2:size(Angle,1)])

TrialTime = size(Angle,1)/fs;
xtic  = 0:TrialTime/(length(xticks)-1):TrialTime;          % timeTrial / number of ticks = length of each time interval
tickLabels={};
for xt = 1:length(xtic)
    tickLabels{xt} = sprintf('%.2f',xtic(xt));
end
tickLabels{1}= '0';
xticklabels (tickLabels);
% make horizontal line line at zero
 
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

plotFootContact(data,FootContact)  % data from 'RunningBiomechPlots_BG'

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