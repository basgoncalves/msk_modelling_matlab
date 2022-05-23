
clear;clc;close all; fp = filesep;
currentPath = matlab.desktop.editor.getActive; pwd=currentPath.Filename;
CD='';while ~contains(CD,'DataProcessing-master'); [pwd,CD]=fileparts(pwd);end
addpath(genpath([pwd fp CD]));

currentPath = matlab.desktop.editor.getActive; pwd=currentPath.Filename;
CD='';while ~contains(CD,'MATLAB'); [pwd,CD]=fileparts(pwd);end

MainDir = [pwd 'DataFolder\Joni\Data'];
SaveDir = [fileparts(MainDir) fp 'ResultsApril2020'];
TaskFolders = dir(MainDir);TaskFolders(1:2) = [];

%% reliability
for ii = 1:length(TaskFolders)
    DataDir = [TaskFolders(ii).folder fp TaskFolders(ii).name fp 'male'];
    JoniReliability(DataDir)
    
    DataDir = [TaskFolders(ii).folder fp TaskFolders(ii).name fp 'female'];
    JoniReliability(DataDir)
end

%% compare men/women and left/right - Trapbar (Force N_Peak and )

TaskFolders([1 2 5 6 7]) = [];

Data = importdata([SaveDir fp '\MaxForce.csv']);
ID = Data.textdata(2:end,1);
Sex = Data.textdata(2:end,3);
Leg = Data.textdata(2:end,4);
MaxForce = Data.data(:,1);

Data = importdata([SaveDir fp '\MaxForce_BW.csv']);
MaxForce_BW = Data.data(:,1);

DataSet = table(ID,Sex,Leg,MaxForce,MaxForce_BW);
DataSet.Sex = nominal(DataSet.Sex);
DataSet.Leg = nominal(DataSet.Leg);

% Force = Outcome Varible ~ Fixed variable + Random variables
lme = fitlme(DataSet,'MaxForce ~ Sex*Leg + Leg ',...
'DummyVarCoding','effects');
A1 = anova(lme)

lme = fitlme(DataSet,'MaxForce_BW ~ Sex*Leg + Leg ',...
'DummyVarCoding','effects');
A2 = anova(lme)

p = {'right' 'left' 'male' 'female'};
[H, p{2,1}, W] = swtest(DataSet{ismember(DataSet.Leg,'right'),'MaxForce'});
[H, p{2,2}, W] = swtest(DataSet{ismember(DataSet.Leg,'left'),'MaxForce'});
[H, p{2,3}, W] = swtest(DataSet{ismember(DataSet.Sex,'male'),'MaxForce'});
[H, p{2,4}, W] = swtest(DataSet{ismember(DataSet.Sex,'female'),'MaxForce'});

[H, p{3,1}, W] = swtest(DataSet{ismember(DataSet.Leg,'right'),'MaxForce_BW'});
[H, p{3,2}, W] = swtest(DataSet{ismember(DataSet.Leg,'left'),'MaxForce_BW'});
[H, p{3,3}, W] = swtest(DataSet{ismember(DataSet.Sex,'male'),'MaxForce_BW'});
[H, p{3,4}, W] = swtest(DataSet{ismember(DataSet.Sex,'female'),'MaxForce_BW'});

%% mean differences male vs female
Male = DataSet{ismember(DataSet.Sex,'male'),'MaxForce'};
Female = DataSet{ismember(DataSet.Sex,'female'),'MaxForce'};
[M,lCI,uCI] = ConfidenceInterval(Male,0.05)
[M,lCI,uCI] = ConfidenceInterval(Female,0.05)
[H,P,Npvalue,MD,uCI,lCI]  = compar2groups(Male,Female,0.05,2) 

Male = DataSet{ismember(DataSet.Sex,'male'),'MaxForce_BW'};
Female = DataSet{ismember(DataSet.Sex,'female'),'MaxForce_BW'};
[M,lCI,uCI] = ConfidenceInterval(Male,0.05);
sprintf('%.f(%.f to %.f)',M,lCI,uCI)
[M,lCI,uCI] = ConfidenceInterval(Female,0.05);
sprintf('%.f(%.f to %.f)',M,lCI,uCI)
[H,P,Npvalue,MD,uCI,lCI]  = compar2groups(Male,Female,0.05,2);
sprintf('%.f(%.f to %.f)',MD,lCI,uCI)

%% Plot Mean and CI per leg 
% CreatePlot_Jorg(DataSet,FullYaxis,Horizontal)
CreatePlot_Jorg(DataSet,1,0)
cd(SaveDir)
saveas (gcf,[SaveDir fp 'Figure1_FullYaxis_Vertical.png'])

CreatePlot_Jorg(DataSet,0,0)
saveas (gcf,[SaveDir fp 'Figure1_Vertical.png'])

CreatePlot_Jorg(DataSet,1,1)
saveas (gcf,[SaveDir fp 'Figure1_FullYaxis_Horizontal.png'])

CreatePlot_Jorg(DataSet,0,1)
saveas (gcf,[SaveDir fp 'Figure1_Horizontal.jpeg'])
close all
