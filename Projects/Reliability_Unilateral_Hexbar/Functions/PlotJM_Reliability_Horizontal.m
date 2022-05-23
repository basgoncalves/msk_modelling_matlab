%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Create a new figure with a bar graph and the data given
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%
%INPUT
%   yData = double with row = one group / each column = one series (color)
%   ErrorBars =  asolute value of SD, SE or CI
%   Ylb = y label text (string)
%   Xticks = xticks labels (double)
%   Titl = title text (string)
%   Lgd = legend text (cell vector)
%   IndivData = first column must be the group number
%   FontSize (defaut = 50)
%   MarkerSize (deafult = 5)
%
%   icons = one icon for cols and one for rows (default{'*'})
%-------------------------------------------------------------------------
%OUTPUT
%   b = figure handle
%--------------------------------------------------------------------------

function b = PlotJM_Reliability_Horizontal (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize,MarkerSize)

if exist('FontSize')&&~isempty(FontSize)
    FS = FontSize;
else
    FS = 50;
end
if ~exist('MarkerSize')||isempty(MarkerSize)
    MarkerSize = 5;
end


%% individual data if needed
nbars = size(yData, 2);
y = 1:nbars;
hold on
if exist('IndivData')&&~isempty(IndivData)
    for c = 1: size(IndivData,2)-1
        
        indCol = IndivData(:,2+c-1);
        xBar =[];
        for i = 1:nbars
            G = IndivData(:,1)==i;
            x = indCol(G);
            xBar =[xBar x];
        end
      
        sc = plot(xBar',y','.',...
            'MarkerSize',MarkerSize,...
            'MarkerEdgeColor',  [.7 .7 .7],...
            'MarkerFaceColor', [.5 .5 .5]);
    end
end
%% plot mean and error data

b = plot(yData,y);            % each row = one group / each column = one series (color)
b.LineStyle = 'none';
b.Marker = '.';
b.MarkerSize = MarkerSize*2;
b.MarkerFaceColor = 'k';
b.MarkerEdgeColor = 'k';

if exist('ErrorBars')&&~isempty(ErrorBars)
    PosBar = ErrorBars; NegBar = ErrorBars;
    er = errorbar(yData,y, NegBar,PosBar,'horizontal', '.', 'color','k');
    er.LineWidth = 1.5;
end
ylim([y(1)-1 y(end)+1])

%% labels and title

if exist('Ylb')&&~isempty(Ylb)
    yl = xlabel(Ylb);
    yl.VerticalAlignment ='top';
end

if exist('Xtics')&&~isempty(Xtics)
    yt = strrep(Xtics,'_',' '); % to ignore _ as undersores (comment if not needed)
    yticks(y)
    yticklabels(yt')
    ytickangle(0)
end

if exist('Titl')&&~isempty(Titl)
    title(Titl,'FontWeight','Normal','VerticalAlignment','bottom')
end

if exist('Lgd')&&~isempty(Lgd)
    legend(Lgd,'FontWeight','Normal','Interpreter','none')
end

mmfn_JM

a=gca;
a.FontSize = FS;

