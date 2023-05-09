%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Create a new figure with a bar graph and the data given
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%
%INPUTS
%   1 yData = double with row = one group / each column = one series (color)
%   2 ErrorBars =  asolute value of SD, SE or CI
%   3 Ylb = y label text (string)
%   4 Xticks = xticks labels (double)
%   5 Titl = title text (string)
%   6 Lgd = legend text (cell vector)
%   7 IndivData = first column must be the group number
%   8 FontSize (defaut = 50)
%   9 MarkerSize (deafult = 5)
%
%   icons = one icon for cols and one for rows (default{'*'})
%-------------------------------------------------------------------------
%OUTPUT
%   b = figure handle
%--------------------------------------------------------------------------

function b = BarBG (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize,MarkerSize)

if nargin > 7  && ~isempty(FontSize)
    FS = FontSize;
else
    FS = 50;
end
b = bar (yData);            % each row = one group / each column = one series (color)
hold on
ncol = size(yData, 1);
nbars = size(yData, 2);

if exist('ErrorBars')&&~isempty(ErrorBars)
    % Calculating the width for each bar group
    barwidth = min(0.8, nbars/(nbars + 1.5));
    nbars = size(ErrorBars,2);
    cMat = colorBG(0,nbars);  % color scheme 2 (Bas)
    PosBar = ErrorBars; NegBar = ErrorBars;
    for i = 1:nbars
        x = (1:ncol) - barwidth/2 + (2*i-1) * barwidth / (2*nbars);
        PosBar(find(yData(:,i)<0),i) = 0;
        NegBar(find(yData(:,i)>=0),i) = 0;
        er = errorbar(x, yData(:,i), NegBar(:,i),PosBar(:,i), '.', 'color','k');
        b(i).FaceColor = cMat(i,:);
    end
end

%% individual data if needed
if exist('IndivData')&&~isempty(IndivData)  
    for c = 1: size(IndivData,2)-1
        
        MaxNRows = [];
        for i = 1:nbars;MaxNRows = max([MaxNRows length(find(IndivData(:,1)==i))]); end

        indCol = IndivData(:,2+c-1);
        xBar =[];
        yBar =[];
        for i = 1:nbars
            G = IndivData(:,1)==i;
            y = indCol(G);
            x = repmat(c - barwidth/2 + (2*i-1) * barwidth / (2*nbars),size(y,1),1);  % x= position of each bar Repeated by the number of rows of yData
            if length(y)<MaxNRows;  y(end+1:MaxNRows) = NaN;x(end+1:MaxNRows) = NaN; end
            xBar =[xBar x];
            yBar =[yBar y];    
        end
    
        if ~exist('MarkerSize')||isempty(MarkerSize)
            MarkerSize = 5;
        end
        
        sc = plot(xBar, yBar,'.',...
            'MarkerSize',MarkerSize,...
            'MarkerEdgeColor',  [.7 .7 .7],...
            'MarkerFaceColor', [.5 .5 .5]);

    end
end


%% labels and title

if exist('Ylb')&&~isempty(Ylb)
    yl = ylabel(Ylb);
    yl.VerticalAlignment ='bottom';
end

if exist('Xtics')&&~isempty(Xtics)
    xt = strrep(Xtics,'_','\_'); % to ignore _ as undersores (comment if not needed)
    xticklabels(xt')
    xtickangle(45)
    %     ax = gca;
    %     ax.TickLabelInterpreter='latex';
elseif isempty(Xtics)
    xticklabels(Xtics)
end

if exist('Titl')&&~isempty(Titl)
    title(Titl,'FontWeight','Normal','VerticalAlignment','bottom')
end

if exist('Lgd')&&~isempty(Lgd)
    legend(Lgd,'FontWeight','Normal','Interpreter','none')
end

mmfn_inspect

a=gca;
a.FontSize = FS;

