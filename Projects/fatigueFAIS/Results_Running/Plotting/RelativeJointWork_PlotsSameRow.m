%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot joint work data
%--------------------------------------------------------------------------

%% RelativeJointWork_PlotsSameRow

cd(DirResults)
load JointWork.mat
joints ={'Hip','Knee','Ankle'};

N = 18;

filename = 'PosWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
TPW = sum(TrialData,2);  % total positive work

filename = 'NegWork';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_fullGait,Labels,{filename},2);
TNW = -sum(TrialData,2);  % total negative work


SumPosWork= [];
SumNegWork =[];
TotalHipWork = [];
TotalKneeWork = [];
TotalAnkleWork = [];
idx.Positive =[];
idx.Negative =[];

%           hip positive flexion early swing
filename = 'pfW';               
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels = {'Hip early swing - H3'};
PlotData = TrialData(:,1)./TPW*100;
SumPosWork= sum([SumPosWork TrialData(:,1)],2);     %add to sum of positive work
idx.Positive(end+1) = size(PlotData,2);


% knee negative extension early swing
filename = 'neW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Knee early swing - K3'};
PlotData(:, end+1) = -TrialData(:,2)./TNW*100;
SumNegWork= sum([SumNegWork TrialData(:,2)],2);      %add to sum of negative work
idx.Negative(end+1) = size(PlotData,2);

% knee negative flexion late swing
filename = 'nfW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Knee late swing - K4'};
PlotData(:, end+1) = -TrialData(:,2)./TNW*100;
SumNegWork= sum([SumNegWork TrialData(:,2)],2);      %add to sum of negative work
idx.Negative(end+1) = size(PlotData,2);

%           hip positive extension late swing
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Swing,Labels,{filename},2);
PlotLabels(end+1) = {'Hip late swing - H4'};
PlotData(:, end+1) = TrialData(:,1)./TPW*100;
SumPosWork= sum([SumPosWork TrialData(:,1)],2);     %add to sum of positive work
idx.Positive(end+1) = size(PlotData,2);

%              hip positive extension early stance
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Hip early stance - H1'};
PlotData(:, end+1) = TrialData(:,1)./TPW*100;
SumPosWork= sum([SumPosWork TrialData(:,1)],2);     %add to sum of positive work
idx.Positive(end+1) = size(PlotData,2);

% knee and ankle negative extension early stance
filename = 'neW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Knee early stance - K1'};
PlotLabels(end+1) = {'Ankle  early stance - A1'};
PlotData(:, end+1) = -TrialData(:,2)./TNW*100;
idx.Negative(end+1) = size(PlotData,2);
PlotData(:, end+1) = -TrialData(:,3)./TNW*100;
idx.Negative(end+1) = size(PlotData,2);
SumNegWork= sum([SumNegWork TrialData(:,2:3)],2);     %add to sum of negative work

%               knee and ankle positive extension mid late stance
filename = 'peW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Knee mid stance - K2'};
PlotLabels(end+1) = {'Ankle late stance- A2'};
PlotData(:, end+1) = TrialData(:,2)./TPW*100;
idx.Positive(end+1) = size(PlotData,2);
PlotData(:, end+1) = TrialData(:,3)./TPW*100;
idx.Positive(end+1) = size(PlotData,2);
SumPosWork= sum([SumPosWork TrialData(:,2:3)],2);     %add to sum of positive work


% hip flexion negative late stance
filename = 'nfW';
[TrialData,MeanLabels,IDxData] = findData (AbsWork_Stance,Labels,{filename},2);
PlotLabels(end+1) = {'Hip late stance - H2'};
PlotData(:, end+1) = -TrialData(:,1)./TNW*100;
SumNegWork= sum([SumNegWork TrialData(:,1)],2);     %add to sum of negative work
idx.Negative(end+1) = size(PlotData,2);


PercentageOfNegativeWork = mean(SumNegWork./TNW*100);
PercentageOfPositiveWork = mean(SumPosWork./TPW*100);

% remove everything before dash from names
for ii = 1:length(PlotLabels)
    idxDash = findstr(PlotLabels{ii},'-');
    if ~isempty(idxDash)
        PlotLabels{ii} = PlotLabels{ii}(idxDash+2:end);
    end
end

%% plots data for positive and negative work
Mean=[];
Mean(1,:) = mean(PlotData (1:N,:),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,:),1);
SD = [];
SD(1,:) = std(PlotData (1:N,:),0,1);
SD(2,:) = std(PlotData (N+1:2*N,:),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work     \n(%% of total work)');
Xtics = PlotLabels(:);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'',FigureLegend,IndividualData,15); 
B= gca;
B.Position =[0.2 0.2 0.7 0.7];
B.Legend.Position =[0.87 0.8 0.0865 0.1259];
ylim ([0 60])
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
