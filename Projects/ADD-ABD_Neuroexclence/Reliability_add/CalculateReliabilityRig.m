%% Script with different sub scripts to help analyisng data for Reliability Rig


%% Normality TestDiff and identify outliersFinalData_NoOutliers
description = TorqueDataAll.LabelsAll;
TotalData = TorqueDataAll.FinalData;
TestDiff = multiTestDif (TotalData);
[FinalData,Outliers] = multiOutliers (TotalData,description,TestDiff);

TorqueDataAll.Outliers_FinalData = Outliers;
TorqueDataAll.TestDiff_FinalData = TestDiff;
TorqueDataAll.FinalData_NoOutliers = FinalData;

%% Normality DataNewtons_NoOutliers
description = TorqueDataAll.LabelsAll;
TotalData = TorqueDataAll.DataNewtons;
TestDiff = multiTestDif (TotalData);
[FinalData,Outliers] = multiOutliers (TotalData,description,TestDiff);

TorqueDataAll.Outliers_DataNewtons = Outliers;
TorqueDataAll.TestDiff_DataNewtons = TestDiff;
TorqueDataAll.DataNewtons_NoOutliers = FinalData;

%% Normality Validity
description = TorqueDataAll.LabelsValidity;
TotalData = TorqueDataAll.Validity;
TestDiff = multiTestDif (TotalData);
[FinalData,Outliers] = multiOutliers (TotalData,description,TestDiff);

TorqueDataAll.Outliers_Validity = Outliers;
TorqueDataAll.TestDiff_Validity = TestDiff;
TorqueDataAll.Validity_NoOutliers = FinalData;
save TorqueDataAll TorqueDataAll

%% Calculate Reliability HipRig

description = TorqueDataAll.LabelsAll;

TotalData = TorqueDataAll.FinalData_NoOutliers;
RelFinalData_NoOutliers = multiRel (TotalData,description,'C-1');

TotalData = TorqueDataAll.DataNewtons_NoOutliers;
RelNewtons = multiRel (TotalData,description,'C-1');

description = TorqueDataAll.LabelsValidity;
TotalData = TorqueDataAll.Validity_NoOutliers;
RelValidity = multiRel (TotalData,description,'C-1');

description = demographics.LabelsAll;
TotalData = demographics.Data;
RelAntrop = multiRel (TotalData,description,'C-1');

save Reliability RelNewtons RelFinalData_NoOutliers RelAntrop RelValidity

%% Calculate test difference correlations
TestDiff = TorqueDataAll.TestDiff_FinalData(:,1:14);
[~,X]= size(TestDiff);

ii = 1;

for ii = 1:X/2
    data = rmmissing([TestDiff(:,ii) TestDiff(:,ii+6)]);
    [R,P] = corrcoef (data(:,1),data(:,2));
    
    pPearson(ii) = P(1,2);                                                      % get only one value from the 2x2 matrix above
    rPearson(ii) = R(1,2);
    
end

%% plots ICC

ICCmean =  cell2mat(RelValidity_Consistency(3,2:end));
errors = cell2mat(RelValidity_Consistency(5,2:end))-cell2mat(RelValidity_Consistency(4,2:end));

bar(ICCmean)
hold on
errorbar(ICCmean,errors,'o')
e.Color = 'black';

%% Regresion equations to estimation of true torque value from rig

% calculate the regression equations and get the trend lines for each pair
data =  TorqueDataAll.Validity;
labels =  {'Abduction' '' 'Adduction' '' 'Extension' '' 'Flexion' '' ...
    'Internal Rotation' '' 'External Rotation '''};
Xtext ='Rig (Nm)';
Ytext ='MDD (Nm)';
Eq = plotRegressions (data,labels,Xtext,Ytext);
close all
PredictedRig = [];

labels =  {'Abduction' 'Adduction' 'Extension' 'Flexion' ...
    'Internal Rotation' 'External Rotation'};

[~, Ncol] = size(data);
data(data==0) = NaN;

%% Blad-Altman analysis corrected values - in Newton.meter
% predict True torque based on equaions and rig data
for ii = 1:2:Ncol
    MDD = (data(:,ii));
    Rig = (data(:,ii+1));
    PredictedRig (:,ii) = MDD;
    
    EqNumber =(ii+1)/2;
    PredictedRig (:,ii+1) = MDD.*Eq(EqNumber,1)+Eq(EqNumber,2);
    [baAH,fig] = BlandAltman_BG(PredictedRig(:,ii:ii+1));
    title(labels{EqNumber})
end


% generate new figure to plot all the subplots in
screensize = get( 0, 'Screensize' )*0.8;        % 89% of window size
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
PlotRegression = figure('Position', [180 75 Xsize Ysize]);

PlotCol =ceil(sqrt(Ncol/2));
PlotRow =Ncol/2/PlotCol;
for ii = 1:Ncol/2
    PlotRegression(ii) = subplot(PlotCol,PlotRow,ii);
end
N_Figures = ii+1;               % get the number of the new figure 


% Now copy contents of each figure over to destination figure
% Modify position of each axes as it is transferred
% https://au.mathworks.com/matlabcentral/answers/101273-how-can-i-put-existing-figures-in-different-subplots-in-another-figure-in-matlab-6-5-r13
for i = 1:Ncol/2
    figure(i)
    h = get(gcf,'Children');
    newh = copyobj(h,N_Figures);
    for j = 1:length(newh)
        posnewh = get(newh(j),'Position');
        possub  = get(PlotRegression(i),'Position');
        set(newh(j),'Position',...
        [possub(1) possub(2) possub(3) possub(4)])
    end
    delete(PlotRegression(i));
    close (figure(i))
end
figure(N_Figures)
suptitle('Blad-Altman analysis corrected values')
saveas(gca,sprintf('Blad-Altman analysis corrected values.jpeg'))
close all

%% Blad-Altman analysis corrected values - in Percentage
% predict True torque based on equaions and rig data
for ii = 1:2:Ncol
    MDD = (data(:,ii));
    Rig = (data(:,ii+1));
    PredictedRig (:,ii) = MDD;
    
    EqNumber =(ii+1)/2;
    PredictedRig (:,ii+1) = MDD.*Eq(EqNumber,1)+Eq(EqNumber,2);
    [baAH,fig] = BlandAltmanPercentage_BG(PredictedRig (:,ii:ii+1));
    title(labels{EqNumber})
end



% generate new figure to plot all the subplots in
screensize = get( 0, 'Screensize' )*0.8;        % 89% of window size
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
PlotRegression = figure('Position', [180 75 Xsize Ysize]);

PlotCol =ceil(sqrt(Ncol/2));
PlotRow =Ncol/2/PlotCol;
for ii = 1:Ncol/2
    PlotRegression(ii) = subplot(PlotRow,PlotCol,ii);
end
N_Figures = ii+1;               % get the number of the new figure 


% Now copy contents of each figure over to destination figure
% Modify position of each axes as it is transferred
% https://au.mathworks.com/matlabcentral/answers/101273-how-can-i-put-existing-figures-in-different-subplots-in-another-figure-in-matlab-6-5-r13
for i = 1:Ncol/2
    figure(i)
    h = get(gcf,'Children');
    newh = copyobj(h,N_Figures);
    for j = 1:length(newh)
        posnewh = get(newh(j),'Position');
        possub  = get(PlotRegression(i),'Position');
        set(newh(j),'Position',...
        [possub(1) possub(2) possub(3) possub(4)])
    end
    delete(PlotRegression(i));
    close (figure(i))
end
figure(N_Figures)
suptitle('Blad-Altman analysis corrected values - in Percentage')
saveas(gca,sprintf('Blad-Altman(percentage) analysis corrected values.jpeg'))

%% Plot Regressions of measured and estimated data 
Eq_pre = plotRegressions (data,labels,Xtext,Ytext);
suptitle('Rig vs MDD Torque before regression')

Eq_Post = plotRegressions (PredictedRig,labels,Xtext,Ytext);
suptitle('Predicted Rig Torque')


%% 
data = addData;
labels = description;

[groupdata,newlabels] = groupcol (data,labels,groups);