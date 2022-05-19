%% linear regression - BG
function Eq = plotRegressions (data,labels,Xtext,Ytext,N)
[~, Ncol] = size(data);

if nargin<3
    Xtext = 'Session1';
    Ytext = 'Session2';
end

if nargin<5
    N = 1;
end

% set figure parameter
screensize = get( 0, 'Screensize' )*0.8;        % 89% of window size
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
PlotRegression = figure('Position', [180 75 Xsize Ysize]);

PlotCol =ceil(sqrt(Ncol/2));
PlotRow =Ncol/2/PlotCol;
for ii = 1:Ncol/2
    Figure.Plot(ii) = subplot(PlotCol,PlotRow,ii);
end
data(data==0) = NaN;

for ii = 1:2:Ncol
    
    PairData = rmmissing(data(:,ii:ii+1));
    y = (PairData(:,1));
    x = (PairData(:,2));
    LimitPlot = round(max(max(x,y)));
    
    
    p = polyfit(x,y,N);
    
    x2 = 1:LimitPlot/100:LimitPlot;
    y2 = polyval(p,x2);
    [R,P] = corrcoef (x,y);
    
    plotN =(ii+1)/2;
    plot(Figure.Plot(plotN),x,y,'o',x2,y2);
    xlim(Figure.Plot(plotN),[0 LimitPlot*1.1])
    ylim(Figure.Plot(plotN),[0 LimitPlot*1.1])
    
    for e= 1:length(p)
    s = sprintf('y = %.2fx + %.2f \n R^2 = %.2f \n p= %.2f ',p(1),p(2),R(2)^2,P(2));
    end
    text(Figure.Plot(plotN),LimitPlot*0.1,LimitPlot*0.8,s);
    xlabel(Figure.Plot(plotN),Xtext)
    ylabel (Figure.Plot(plotN),Ytext)
    title (Figure.Plot(plotN),labels((ii)))
    
    
    for e= 1:length(p)
        Eq(plotN,e) = p(e);
    end
     Eq(plotN,e+1) = R(2)^2;
end