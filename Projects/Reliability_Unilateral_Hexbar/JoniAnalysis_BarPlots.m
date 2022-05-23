
clear;clc;close all;
fp = filesep;
currentPath = matlab.desktop.editor.getActive;
pwd = fileparts(currentPath.Filename);
addpath(genpath(pwd));

MainDir = 'E:\DataFolder\Joni\Data';
SaveDir = 'E:\DataFolder\Joni\ResultsApril2020';
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

Data = importdata('E:\DataFolder\Joni\ResultsApril2020\MaxForce.csv');
ID = Data.textdata(2:end,1);
Sex = Data.textdata(2:end,3);
Leg = Data.textdata(2:end,4);
MaxForce = Data.data(:,1);

Data = importdata('E:\DataFolder\Joni\ResultsApril2020\MaxForce_BW.csv');
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

figure
[ha, ~] = tight_subplot(2,1,0.08,0.08,0.12);
set(gcf, 'Position', [960    75   547   892]);
Variables = {'MaxForce' 'MaxForce_BW'};
Ylb = {'Force (N)' 'Force (N/BW)'};
Xt = {{'' ''} {'left' 'right'}};
lg = {{'male' 'female'} {}};
for v = 1: length(Variables)
    
    Leg = {'left' 'right'};
    Sex = {'male' 'male'};
    Nmale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{1}),Variables{v}});
    Ind = []; Ind(1:Nmale,1) = 1;
    M = []; lCI =[]; uCI=[];
    for i = 1:2
        I = DataSet{ismember(DataSet.Leg,Leg{i})& ismember(DataSet.Sex,Sex{i}),Variables{v}};
        [M(i),lCI(i),uCI(i)] = ConfidenceInterval(I,0.05);
        Ind(1:length(I),i+1)= I;
    end
    
    Leg = {'left' 'right'};
    Sex = {'female' 'female'};
    Nfemale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{1}),Variables{v}});
    rows = [size(Ind,1)+1:size(Ind,1)+Nfemale];
    Ind(rows,1) = 2;
    for i = 1:2
        I = DataSet{ismember(DataSet.Leg,Leg{i})& ismember(DataSet.Sex,Sex{i}),Variables{v}};
        [M(2,i),lCI(2,i),uCI(2,i)] = ConfidenceInterval(I,0.05);
        Ind(rows,i+1)= I;
    end
    rows = [size(Ind,1)+1:size(Ind,1)+Nmale-Nfemale];
    Ind(rows,1) = 2;
    Ind(rows,2:3) = NaN;
    CI = uCI-M;
    axes(ha(v))
    BarBG(M',CI',Ylb{v},Xt{v},[],lg{v},Ind,12,15)
end
cd(SaveDir)
saveas (gcf,[SaveDir fp 'Figure1_flipped.png'])
%%  Plot Mean and CI per sex (Max and max/BW
figure
[ha, ~] = tight_subplot(2,1,0.08,0.08,0.12);
set(gcf, 'Position', [960    75   547   892]);
Variables = {'MaxForce' 'MaxForce_BW'};
Ylb = {'Force (N)' 'Force (N/BW)'};
Xt = {{'' ''} {'male' 'female'}};
lg = {{'right' 'left'} {}};
for v = 1: length(Variables)
    Leg = {'right' 'right'};
    Sex = {'male' 'female'};
    Nmale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{1}),Variables{v}});
    Ind = []; Ind(1:Nmale,1) = 1;
    M = []; lCI =[]; uCI=[];
    for i = 1:2
        I = DataSet{ismember(DataSet.Leg,Leg{i})& ismember(DataSet.Sex,Sex{i}),Variables{v}};
        [M(i),lCI(i),uCI(i)] = ConfidenceInterval(I,0.05);
        Ind(1:length(I),i+1)= I;
    end
    
    Leg = {'left' 'left'};
    Sex = {'male' 'female'};
    Nfemale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{1}),Variables{v}});
    rows = [size(Ind,1)+1:size(Ind,1)+Nfemale];
    Ind(rows,1) = 2;
    for i = 1:2
        I = DataSet{ismember(DataSet.Leg,Leg{i})& ismember(DataSet.Sex,Sex{i}),Variables{v}};
        [M(2,i),lCI(2,i),uCI(2,i)] = ConfidenceInterval(I,0.05);
        Ind(rows(1:length(I)),i+1)= I;
    end
    Ind(Ind==0) = NaN;
    CI = uCI-M;
    
    axes(ha(v))
    BarBG(M',CI',Ylb{v},Xt{v},[],lg{v},Ind,12,15)
end

cd(SaveDir)
saveas (gcf,[SaveDir fp 'Figure1.png'])