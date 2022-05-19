%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% copy a figure into another 
%-------------------------------------------------------------------------
%INPUT
%   FigToCopy = handle of figure to copy to main figure
%   MainFig = name of the new figure to transfer the old figure to
%   Nsubfigs = Number of subfigures ([Nrows, Ncol])
%   CurrentFigNumber = place of the old figure in the new figure
%   
%-------------------------------------------------------------------------
%OUTPUT
%--------------------------------------------------------------------------

%% mergeFigures 
function mergeFigures (FigToCopy, MainFig,NrowNcols,CurrentFigNumber)

%% copy to main figure
% select current figure
OriginalAx = findobj(FigToCopy,'Type','axes');
handle = get(OriginalAx(end),'Children');
PositionPixOld = get(gca,'Position');
PositionPixOld ([1;3])= PositionPixOld ([1;3])*FigToCopy.Position (3);
PositionPixOld ([2;4])= PositionPixOld ([2;4])*FigToCopy.Position (4);

FS_tt = OriginalAx.Title.FontSize;
FS_xlab = OriginalAx.XLabel.FontSize;
FS_ylab = OriginalAx.YLabel.FontSize;
Text = findobj(FigToCopy, 'Type', 'Text');
for i= 1:length(Text)
FS_txt(i) = Text(i).FontSize;
end


figure(MainFig);
SubPlAx = subplot(NrowNcols(1),NrowNcols(2),CurrentFigNumber);  % Nsubfigs must contain [Nrows, Ncol]) 
FS = SubPlAx.FontSize;      % font size to match all the plots
copyobj(handle,SubPlAx);
xlb = xlabel(OriginalAx(end).XLabel.String);
ylb = ylabel(OriginalAx(end).YLabel.String);
xticks (OriginalAx(end).XTick); xticklabels(OriginalAx(end).XTickLabel); xtickangle (OriginalAx(end).XTickLabelRotation);
yticks (OriginalAx(end).YTick); yticklabels(OriginalAx(end).YTickLabel); ytickangle (OriginalAx(end).YTickLabelRotation);


set (xlb,...
    'HorizontalAlignment',OriginalAx(end).XLabel.HorizontalAlignment,...
    'VerticalAlignment',OriginalAx(end).XLabel.VerticalAlignment);

set (ylb,...
    'HorizontalAlignment',OriginalAx(end).YLabel.HorizontalAlignment,...
    'VerticalAlignment',OriginalAx(end).YLabel.VerticalAlignment);

% title 
tt = title(OriginalAx.Title.String);
tt.FontSize = OriginalAx.Title.FontSize;
tt.FontWeight = OriginalAx.Title.FontWeight;
tt.FontName = OriginalAx.Title.FontName;
tt.Position = OriginalAx.Title.Position;
tt.HorizontalAlignment = OriginalAx.Title.HorizontalAlignment;
tt.VerticalAlignment = OriginalAx.Title.VerticalAlignment;
tt.Interpreter = OriginalAx.Title.Interpreter;

ylim(OriginalAx.YAxis.Limits)
yl = ylim;

ratio = mean(SubPlAx.Position(3:4)./OriginalAx.Position(3:4));
SubPlAx.FontSize = OriginalAx.FontSize*ratio;
SubPlAx.Title.FontSize = FS_tt*ratio;
SubPlAx.Title.Position = OriginalAx.Title.Position;

SubPlAx.XLabel.FontSize = FS_xlab*ratio;
SubPlAx.YLabel.FontSize = FS_ylab*ratio;
SubPlAx.XAxisLocation = OriginalAx.XAxisLocation;
SubPlAx.YAxisLocation = OriginalAx.YAxisLocation;
SubPlAx.XAxis.Limits = OriginalAx.XAxis.Limits;
SubPlAx.YAxis.Limits = OriginalAx.YAxis.Limits;
SubPlAx.ZAxis.Limits = OriginalAx.ZAxis.Limits;
SubPlAx.XLabel.Position = OriginalAx.XLabel.Position;
SubPlAx.XLabel.Rotation = OriginalAx.XLabel.Rotation;
SubPlAx.YLabel.Position = OriginalAx.YLabel.Position;
SubPlAx.YLabel.Rotation = OriginalAx.YLabel.Rotation;
%match font size to all axis
N =  length(MainFig.Children);
for ii = 1:N
    if contains(class(MainFig.Children(ii)),'Axes')
        MainFig.Children(ii).FontSize = OriginalAx.FontSize*ratio;
    end    
end


%find zero for a normal plot;
figure
zeroAxes = axes; zeroAxes = zeroAxes.Position; close gcf
% reajuts the new plot to match the relative position of the old plot

%   |--------:----------------------------|
%   x1       p                           x2
% distance ratio(p) = (p-x1)/(x2-x1)
xRatio = (OriginalAx.Position(1)-zeroAxes(1))/zeroAxes(3);
yRatio = (OriginalAx.Position(2)-zeroAxes(2))/zeroAxes(4);

% final postion = NewIntialZero + (distance ratio * oldLength)
oldLength_x = SubPlAx.Position(3);
newXPos = SubPlAx.Position(1)+(xRatio*SubPlAx.Position(3));
newYPos = SubPlAx.Position(2)+(yRatio*SubPlAx.Position(4));

% final length 
newXLength = SubPlAx.Position(3)*OriginalAx.Position(3)/zeroAxes(3);
newYLength = SubPlAx.Position(4)*OriginalAx.Position(4)/zeroAxes(4);

% scale X and Y axis
SubPlAx.Position = [newXPos, newYPos, newXLength, newYLength];
NewText = findobj(SubPlAx, 'Type', 'Text');
for i= 1:length(Text)
NewText(i).FontSize =FS_txt(i)*ratio;
end

LegendUse=[];
for ii = 1:length(OriginalAx.Children)
    if ~isempty(OriginalAx.Children(ii).DisplayName)
        LegendUse=[LegendUse ii];
    end
end

if ~isempty(OriginalAx.Legend)%&& isempty(findobj(MainFig,'Type','legend'))
       
    lhd = legend(flip(SubPlAx.Children(LegendUse)));
    lhd.Box = OriginalAx.Legend.Box;
    lhdSize = get(lhd,'FontSize');  
    set(lhd,'FontSize',lhdSize,'Location',OriginalAx.Legend.Location,...
        'Interpreter',OriginalAx.Legend.Interpreter);

    
end


set(gcf,'Color',[1 1 1]);
set(gca,'box', 'off')


