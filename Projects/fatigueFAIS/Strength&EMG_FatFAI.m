
% Windows 10 search for "Advanced system settings" -> Environment Variables
% Under  "System Variables" -> edit "Path" -> add OPENSIM_INSTALL_DIR and  OPENSIM_INSTALL_DIR/bin - https://www.java.com/en/download/help/path.xml

clear
clc
close all
addpath(genpath('E:\MATLAB'));                % add current folder and sub folders to path

DirC3D = 'E:\3-PhD\Data\MocapData\InputData\015\pre';
OrganiseFAI        % get directories (DirC3D; SubjFolder; DirInput; DirMocap; DirFigure; C3DFolderName;DirElaborated),subject code and demografics

DirResults = ('E:\4- Papers_Abstracts\Papers\Goncalves_EMGisom_Hip muscle ativity isometrics\Results');

IsometricTroqrueEMG 

IsometricTroqrueEMG_meanPlots

%% report data 
PlotStrengthReport

%% Running tasks

[TreadmillData,Results] = WoodwayProcessing (DirWoodway);

BatchRunningEMG_FAI


%% mean Running trials
cd(SubjFolder)
load('RunningEMG.mat')

MeanRunning = [];
[Subjects] = uigetmultiple(cd,'select all the subjects to average strength from');
Nsubjects = length (Subjects);
for ss = 1: Nsubjects
    cd(Subjects{ss})
    load strenghtData
    MeanStrengthDifference(ss+1,1:9) = StrengthDiff(1:9,2)';
end
MeanStrengthDifference(1,1:9)=StrengthDiff(1:9,1)';

ydata = cell2mat(MeanStrengthDifference(2:Nsubjects+1,:));
[Nsubjects, c] = size(ydata);
xdata = repmat(1:c, Nsubjects, 1);

MeanStrengthDiff = mean(ydata);
CI = (std(ydata)/sqrt(Nsubjects))*1.96;


br = bar(xdata(1,:),mean(ydata),'DisplayName',...
    'cell2mat(MeanStrengthDifference(2:end,:))','FaceColor',[35/255 156/255 208/255]);          %check colors https://www.rapidtables.com/web/color/RGB_Color.html
hold on
er = errorbar(xdata(1,:),MeanStrengthDiff,CI,CI,'color','k');               % error bar = (x,y,Lower,Upper)
er.LineStyle = 'none';
scatter(xdata(:), ydata(:),'MarkerEdgeColor','none','MarkerFaceColor',[.5 .5 .5]);                                                % https://stackoverflow.com/questions/30660340/categorical-scatter-plot-in-matlab
% boxplot(ydata);
ylabel('Force change(%)');
set(get(gca,'YLabel'),'Rotation',90)
title (sprintf('Force change after fatigue for %.f subjects',length(Subjects)));
xticks(1:length(MeanStrengthDifference));
xticklabels(MeanStrengthDifference(1,1:end));
xtickangle(45);
ylim([-100 50]);
yticks(-100:20:50);
legend('Mean','95%CI','Individual');
%% jumping Trials


DynamicDir = uigetdir('E:\1-PhD\3-FatigueFAI\Testing',...
    'Select folder with jumping .c3d files');
cd(DynamicDir);
folderC3D = sprintf('%s\\%s',DynamicDir,'*.c3d');
Files = dir(folderC3D);

% get the jumping trials
count = 0;
LoadBar = waitbar(0,'Copying running Trials...');
for ff = 1:length (Files)
    waitbar(ff/length (Files),LoadBar,'Copying running Trials...');
    if contains(Files(ff-count).name,'SJ') == 0
        
        Files(ff-count)=[];
        count =count+1;
    end
end

close all

%% Batch analysis 

batch_StrengthAndEMG_FAI 
