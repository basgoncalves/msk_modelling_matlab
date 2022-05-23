%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot joint work data
%--------------------------------------------------------------------------

%% AbsoluteJointWork_PlotsStaked

cd(DirResults)
load JointWork.mat
joints ={'Hip','Knee','Ankle'};

N = 18;
idx= struct;
idx.Total = [];
idx.Positive =[];
idx.Negative =[];

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
PlotLabels(end+1) = {'Hip early swing - H3'};
PlotData(:, end+1)  = TrialData(:,1);
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


%% Plot data 
% Mean=[];
% Mean(1,:) = mean(PlotData (1:N,idx.Total),1);         
% Mean(2,:) = mean(PlotData (N+1:2*N,idx.Total),1);
% SD = [];
% SD(1,:) = std(PlotData (1:N,idx.Total),0,1);
% SD(2,:) = std(PlotData (N+1:2*N,idx.Total),0,1);
% IndividualData = [AbsWork_fullGait(:,1) PlotData(:,idx.Total)];
% FigureLegend = {'Pre','Post','SD'};
% ylb = sprintf('Work \n (J/kg)');
% Xtics = PlotLabels(idx.Total);
% % plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
% BarBG (Mean',SD',ylb,Xtics,'',FigureLegend,IndividualData,15); 
% B= gca;
% B.Position =[0.2 0.45 0.7 0.46];
% ylim ([-10 10])
% ylb = B.YLabel;
% ylb.Rotation = 0;
% ylb.HorizontalAlignment = 'right';
% ylb.VerticalAlignment = 'middle';

% plots data for total, positive and negative work

Mean=[];
Mean(1,:) = mean(PlotData (1:N,idx.Positive),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,idx.Positive),1);
SD = [];
SD(1,:) = std(PlotData (1:N,idx.Positive),0,1);
SD(2,:) = std(PlotData (N+1:2*N,idx.Positive),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData(:,idx.Positive)];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work \n (J/kg)');
Xtics = PlotLabels(idx.Positive);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'','',IndividualData,15); 
B= gca;
B(end).Position =[0.2 0.45 0.7 0.46];
% ylim ([-3 3])
ylb = B(end).YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';


Mean=[];
Mean(1,:) = mean(PlotData (1:N,idx.Negative),1);         
Mean(2,:) = mean(PlotData (N+1:2*N,idx.Negative),1);
SD = [];
SD(1,:) = std(PlotData (1:N,idx.Negative),0,1);
SD(2,:) = std(PlotData (N+1:2*N,idx.Negative),0,1);
IndividualData = [AbsWork_fullGait(:,1) PlotData(:,idx.Negative)];
FigureLegend = {'Pre','Post','SD'};
ylb = sprintf('Work \n (J/kg)');
Xtics = PlotLabels(idx.Negative);
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
BarBG (Mean',SD',ylb,Xtics,'','',IndividualData,15); 
B(end+1)= gca;
B(end).Position =[0.2 0.45 0.7 0.46];
% ylim ([-3 3])
ylb = B(end).YLabel;
ylb.Rotation = 0;
ylb.HorizontalAlignment = 'right';
ylb.VerticalAlignment = 'middle';
MainFig = figure;
fullscreenFig(0.7,0.5)
for ii = 1: length(B)
    mergeFigures (B(ii), MainFig,[length(B) 1],ii)
    mergeFigures (B(ii), MainFig,[length(B) 1],ii)
end

hAxes = findobj(MainFig, 'Type', 'Axes');
hAxes(1).Position = [0.2 0.1 0.7 0.35];  %move plot down amd increase verical size to reduce white space
hAxes(2).Legend.Position = [0.89 0.75 0.06 0.12];  %move plot down amd increase verical size to reduce white space
hAxes(2).Position = [0.2 0.6 0.7 0.35];  %move plot down amd increase verical size to reduce white space
