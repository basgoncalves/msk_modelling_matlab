%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot joint work data
%--------------------------------------------------------------------------

%% AbsoluteTotalWork

N = 18;
idx= struct;
idx.Total = [];
idx.Positive =[];
idx.Negative =[];

filename = 'PosWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
PlotLabels = {sprintf('Positive')};
PlotData = sum(TrialData,2);
idx.Total(end+1) = size(PlotData,2);

filename = 'NegWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
PlotLabels(end+1) = {sprintf('Negative')};
PlotData(:, end+1) = -sum(TrialData,2);
idx.Total(end+1) = size(PlotData,2);

%% Plot data 
Mean=[];
Mean(1,:) = mean(PlotData (1:N,:),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,:),1);
SD = [];
SD(1,:) = std(PlotData (1:N,:),0,1);
SD(2,:) = std(PlotData (N+1:2*N,:),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work \n (J/kg)');
Xtics = PlotLabels(:);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'',FigureLegend,IndividualData,15); 
resizeFigure (0.2,0.51)
B= gca;
B.Position =[0.3 0.2 0.5 0.7];
B.Legend.Position =[0.87 0.8 0.0865 0.1259];
ylim ([-10 10])
ylb = B.YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';

%% create a rectangle 
LeftEdges = B.Children(end).XData - 0.5;                               % find the left edges of each bar group 
RightEdges = B.Children(end).XData + 0.5;                              % find the right edges of each bar group                     
PlotBoxIdx = [1];                                               % determine the indices of the bars to plot a rectangle around (change if needed)
for ii = PlotBoxIdx
X = [LeftEdges(ii) RightEdges(ii) RightEdges(ii) LeftEdges(ii)];            % set Y dmensions 
Y = [min(ylim) min(ylim) max(ylim)  max(ylim)];                                         % set X dimensions
f = fill(X,Y,'k');                                                      % create rectangle around the bars
set(f,'FaceColor', [0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.3);   % set rectangle color, Edgecolor and transparency
end

legend off

