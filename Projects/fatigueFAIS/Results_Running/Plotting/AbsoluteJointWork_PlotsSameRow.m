%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot joint work data
%--------------------------------------------------------------------------

%% AbsoluteJointWork_PlotsSameRow

cd(DirResults)
load JointWork.mat
joints ={'Hip','Knee','Ankle'};

N = 18;
idx= struct;
idx.Total = [];
idx.Positive =[];
idx.Negative =[];
cMat = convertRGB([176, 104, 16;16, 157, 176;136, 16, 176;176, 16, 109;31, 28, 28]);  % color scheme 2 (Bas)


filename = 'PosWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
PlotLabels = {'Total Positive'};
PlotData = sum(TrialData,2);
idx.Total(end+1) = size(PlotData,2);

filename = 'NegWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
PlotLabels(end+1) = {'Total Negative'};
PlotData(:, end+1) = -sum(TrialData,2);
idx.Total(end+1) = size(PlotData,2);

%           hip positive flexion early swing
filename = 'pfW';               
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels = {'Hip early swing - H3'};
PlotData  = TrialData(:,1);
idx.Positive(end+1) = size(PlotData,2);

% knee negative extension early swing
filename = 'neW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Knee early swing - K3'};
PlotData(:, end+1) = -TrialData(:,2);
idx.Negative(end+1) = size(PlotData,2);

% knee negative flexion late swing
filename = 'nfW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Knee late swing - K4'};
PlotData(:, end+1) = -TrialData(:,2);
idx.Negative(end+1) = size(PlotData,2);

%           hip positive extension late swing
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Hip late swing - H4'};
PlotData(:, end+1) = TrialData(:,1);
idx.Positive(end+1) = size(PlotData,2);

%              hip positive extension early stance
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Hip early stance - H1'};
PlotData(:, end+1) = TrialData(:,1);
idx.Positive(end+1) = size(PlotData,2);

% knee and ankle negative extension early stance
filename = 'neW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Knee early stance - K1'};
PlotLabels(end+1) = {'Ankle  early stance - A1'};
PlotData(:, end+1) = -TrialData(:,2);
idx.Negative(end+1) = size(PlotData,2);
PlotData(:, end+1) = -TrialData(:,3);
idx.Negative(end+1) = size(PlotData,2);

%               knee and ankle positive extension mid late stance
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Knee mid stance - K2'};
PlotLabels(end+1) = {'Ankle late stance- A2'};
PlotData(:, end+1) = TrialData(:,2);
idx.Positive(end+1) = size(PlotData,2);
PlotData(:, end+1) = TrialData(:,3);
idx.Positive(end+1) = size(PlotData,2);

% hip flexion negative late stance
filename = 'nfW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Hip late stance - H2'};
PlotData(:, end+1) = -TrialData(:,1);
idx.Negative(end+1) = size(PlotData,2);

% remove everything before dash from names
for ii = 1:length(PlotLabels)
    idxDash = findstr(PlotLabels{ii},'-');
    if ~isempty(idxDash)
        PlotLabels{ii} = PlotLabels{ii}(idxDash+2:end);
    end
end

CorrelationData = PlotData;
CorrelationLabels = PlotLabels;

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
B= gca;
B.Position =[0.2 0.2 0.7 0.7];
B.Legend.Position =[0.87 0.8 0.0865 0.1259];
ylim ([-3 3])
ylb = B.YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';

%% create a rectangle 
LeftEdges = B.Children(end).XData - 0.5;                               % find the left edges of each bar group 
RightEdges = B.Children(end).XData + 0.5;                              % find the right edges of each bar group                     
PlotBoxIdx = [1 4 5 8 9];                                               % determine the indices of the bars to plot a rectangle around (change if needed)
for ii = PlotBoxIdx
X = [LeftEdges(ii) RightEdges(ii) RightEdges(ii) LeftEdges(ii)];            % set Y dmensions 
Y = [min(ylim) min(ylim) max(ylim)  max(ylim)];                                         % set X dimensions
f = fill(X,Y,'k');                                                      % create rectangle around the bars
set(f,'FaceColor', [0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.3);   % set rectangle color, Edgecolor and transparency
end
legend(FigureLegend)

F1 = gcf;

%% plot Total work 

AbsoluteTotalWork


% max horizontal velocity
filename = 'Velocity';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
CorrelationData = [AbsWork_Stance(:,1) CorrelationData PlotData TrialData];
CorrelationLabels = [Labels(1) CorrelationLabels PlotLabels 'Velocity'];

save JointWork_correlationData CorrelationData CorrelationLabels

F2 = gcf;
%% merge figures

MainFig = figure;

mergeFigures(F1,MainFig,[1,2],2)
mergeFigures(F2,MainFig,[1,2],1)
fullscreenFig(0.7,0.5)
% set parameters figure 1 (total work)
ax = MainFig.Children(1);
set(ax,'Position', [0.1 0.2 0.15 0.7], 'FontSize',FS)
MainFig.Children(1).XTickLabel={};  

% make tick laels have two lines
xPos = ax.Children(end).XData;      %position of the text
yPos = ax.XLabel.Position(2);      %position of the text
% tick label positive
text(ax,xPos(1),yPos, sprintf('Total \n positive'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 
% tick label negative
text(ax,xPos(2),yPos, sprintf('Total \n negative'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 

yPos = ax.Children(end).YData*1.6;      % y  position of the bars

% star position negative 
StarPosition = [2];
for ii = StarPosition
tt = text(ax,xPos(ii),yPos(ii), sprintf('*'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 
end
% star position positive 
StarPosition = [1];
for ii = StarPosition
tt = text(ax,xPos(ii),yPos(ii), sprintf('*'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 
end


% set parameters figure 2 (joint work)
ax = MainFig.Children(3);
set(ax,'Position', [0.3 0.2 0.6 0.7], 'FontSize',FS)
ax.YLabel.String = '';

xPos = ax.Children(end).XData;          % x position of the text
yPos = ax.Children(end).YData*1.6;      % y position of the text

% star position negative 
StarPosition = [2 3 6];
for ii = StarPosition
tt = text(ax,xPos(ii),yPos(ii), sprintf('*'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 
end

% star position positive 
StarPosition = [1 4];
for ii = StarPosition
tt = text(ax,xPos(ii),yPos(ii), sprintf('*'),'HorizontalAlignment', 'center',...
    'FontName', 'Times New Roman','FontSize', FS); 
end


% set parameters legend
ax = MainFig.Children(2);
set(ax,'Position', [0.8 0.7 0.2 0.1],'FontSize',FS)


