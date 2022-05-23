%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot joint work data
%--------------------------------------------------------------------------

%% RelativeJointWork_PlotsStacked


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
Mean(1,:) = mean(PlotData (1:N,idx.Positive),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,idx.Positive),1);
SD = [];
SD(1,:) = std(PlotData (1:N,idx.Positive),0,1);
SD(2,:) = std(PlotData (N+1:2*N,idx.Positive),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData(:,idx.Positive)];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work     \n(%% of total \n positive work)');
Xtics = PlotLabels(idx.Positive);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'',FigureLegend,IndividualData,15); 
B= gca;
B.Legend.Position =[0.95 0.8 0.0865 0.1259];
B.Position =[0.2 0.45 0.7 0.46];
ylim ([0 60])
ylb = B.YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';


% plots data for negative work
Mean=[];
Mean(1,:) = mean(PlotData (1:N,idx.Negative),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,idx.Negative),1);
SD = [];
SD(1,:) = std(PlotData (1:N,idx.Negative),0,1);
SD(2,:) = std(PlotData (N+1:2*N,idx.Negative),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData(:,idx.Negative)];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work     \n(%% of total \n negative work)');
Xtics = PlotLabels(idx.Negative);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'','',IndividualData,15); 
B2= gca;
B2.Position =[0.2 0.45 0.7 0.46];
ylim ([0 60])
ylb = B2.YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';

MainFig = figure;
fullscreenFig(0.7,0.5)
mergeFigures (B, MainFig,[2 1],1)
mergeFigures (B2, MainFig,[2 1],2)
hAxes = findobj(MainFig, 'Type', 'Axes');
hAxes(1).Position = [0.2 0.1 0.7 0.35];  %move plot down amd increase verical size to reduce white space
hAxes(2).Legend.Position = [0.89 0.75 0.06 0.12];  %move plot down amd increase verical size to reduce white space
hAxes(2).Position = [0.2 0.6 0.7 0.35];  %move plot down amd increase verical size to reduce white space
