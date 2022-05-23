%BG - 2019
% PlotMeanStrengthDiff_FAI
%Script to get strength difference plots
%
%CALLBACK FUNCTIONS
%   Plot_meanWindividual



%% mean Strength Pre - Select folders
OrganiseFAI
DirResults = ([DirResults filesep 'HipIsometric']);
mkdir(DirResults)
    
PlotIndividual = 0;  % 1 = yes; 0= no; 

MeanStrengthDiff = {};
if ~exist('Subjects')~=1
    [Subjects] = uigetmultiple(DirInput,'select all the subjects to average strength from');
end
Nsubjects = length (Subjects);

%% Arrange Mean Strength data
MeanStrengthDiff={};
SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(:,SubjectCol);
SubjectAnaysed =[];
Gen = [];
FAIM = [];

for ss = 1: Nsubjects                                                       % run through all selected subject folders
    cd(Subjects{ss})
    CurrentSubject =Subjects{ss}(end-2:end);
    SubjectRow = find(strcmp(SubjectCodes,CurrentSubject));
    
    if exist('strenghtData.mat','file')==2
        load strenghtData.mat                                                       % for each participant folder, load the strength data
    else                                                                            % if the file 'strength'
        fprintf ('strenghtData does not exist in %s \n',CurrentSubject)
        continue
    end
    
    if mean(cell2mat(StrengthDiff(:,2)))==-100
        continue
    end
    
    MeanStrengthDiff(1,2:10)= StrengthDiff(:,1)';       % labels with the name of each trial
    MeanStrengthDiff(end+1,2:10)= StrengthDiff(:,2)';
    MeanStrengthDiff{end,1}= CurrentSubject;
    
    SubjectAnaysed = [SubjectAnaysed SubjectRow];
    Gen{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Sex')};
    FAIM{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Group ')};
end
                           %add labels
%% 
% format data to use in the callback function 'Plot_meanWindividual'
Channels = MeanStrengthDiff(1,2:end);
ydata = cell2mat(MeanStrengthDiff(2:end,2:end));
SubjectCodes = MeanStrengthDiff(2:end,1);

%select the number of the participant to use plot in color (RUN as a loop
%if needed)
if exist('Subject')
    ss= {Subject};
else
ss = inputdlg('select the subject to plot with color (e.g. "022")');
end
ss= find(strcmp(SubjectCodes,ss));
if isempty(ss)
   error ('subject %s does not exist or was not selected',Subject); 
end
subjectIdx = find(strcmp(SubjectCodes,SubjectCodes{ss}));     

%% Plot Mean Strength
screensize = get( 0, 'Screensize' )/1.5;
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
StrengthMeanPlot = figure('Position', [180 75 Xsize Ysize]);
    
% Plot mean data with individual points

if PlotIndividual == 0
br = Plot_meanWindividual(ydata,Channels,0,10,'DeleteIfNotNeded');

lgNames = {'Mean','95%CI'};
lg=legend(lgNames);

else
    
br = Plot_meanWindividual(ydata,Channels,subjectIdx,10);
 lgNames={};
    %% Color male and female subjects
% plot legend: 1 = Mean strength; 2= CI; 3= dividual subjects; Subject + 2 = Number of the subject + the index of Mean Strength and CI (2)
lgNames = {lgNames 'Mean','95%CI','Male','Female','You'};
Nsubjects = length(br)-2;

% color males blue and females orange
indexF = find(strcmp(Gen,'F'));
indexM = find(strcmp(Gen,'M'));
for ii = indexF
    br(ii).MarkerFaceColor = [0.8500 0.3250 0.0980];            % orange
end

%% Color male and female subjects
lgNames = {lgNames 'Mean','95%CI','Male','Female','You'};
% marker controls 'o' and FAIM '^'
indexFAIM = find(strcmp(FAIM,'FAIM'))';
indexControl = find(~strcmp(FAIM,'FAIM'))';
for ff = 1:length(indexFAIM)        
        Ndot = indexFAIM (ff)+2;                                        % (add 2 because the first 2 variables are the Bar and SD)
        br(Ndot).MarkerFaceColor = [0.8500 0.3250 0.0980];              % orange      
end    

lg=legend(br([1:3,indexF(1),subjectIdx+2]),lgNames);
end

ylb= ylabel({'Strength change (%)';'(post-pre)'}, 'Rotation',0);
ylb.Position = [-3 mean(ylim) -1.0000];
% set plot position
set(lg,'color','none','Location', 'northeastoutside');
mmfn
set(gca, 'FontSize',14,'Position' ,[0.25 0.1963 0.5 0.7281])

%% save data 
cd(DirResults);
saveas(gcf, sprintf('StrengthDiff-%s.jpeg',SubjectCodes{subjectIdx(1)}))

TorqueDiff = ydata;
save StrengthData  TorqueDiff Channels SubjectCodes -append
close all
