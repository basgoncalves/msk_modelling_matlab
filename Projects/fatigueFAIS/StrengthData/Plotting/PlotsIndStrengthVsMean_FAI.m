%BG - 2019
%Script to get mean strength plots fo
%
%CALLBACK FUNCTIONS
%   MaxStrength_FAI
%   getMaxTrials (GroupData,labels)
%   Plot_meanWindividual



%% PlotsMeanStrength_FAI
% mean Strength Pre - Select folders
function PlotsIndStrengthVsMean_FAI (SubjectFoldersElaborated, sessionName)


if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;
    
PlotIndividual = 0;

MeanStrength_Pre = {};


%% Plot Mean Strength
MeanStrength_Pre={};
SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(:,SubjectCol);
ss= 1;
SubjectAnaysed = [];
Gen={};
Group={};
Nsubjects = length (SubjectFoldersElaborated);

for ss = 1: Nsubjects                                                       % run through all selected subject folders
    
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ss},filesep);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    DirStrengthData = strrep(DirStrengthData,OldSubject,Subject);
    SubjectRow = find(strcmp(SubjectCodes,Subject));
    
    cd(DirStrengthData)
    CurrentSubject = Subject;
   
    if exist('strenghtData.mat','file')==2
        load strenghtData.mat                                                       % for each participant folder, load the strength data
    else                                                                            % if the file 'strength'
        fprintf ('strenghtData does not exist in %s \n',CurrentSubject)
        continue
    end
    
    if isempty(demographics{SubjectRow,strcmp(labelsDemographics,'GT - Knee pad')})
         fprintf ('moment arms for subject %s do not exist \n',CurrentSubject)
        continue
    end
    
    
    Marm_GT2Knee = round(demographics{SubjectRow,strcmp(labelsDemographics,'GT - Knee pad')},2);
    Marm_GT2Ankle = round(demographics{SubjectRow,strcmp(labelsDemographics,'GT - Ankle pad')},2);
    Marm_Pat2Ankle = round(demographics{SubjectRow,strcmp(labelsDemographics,'Pat-Ankle pad')},2);
    
    BodyMass = demographics{SubjectRow,strcmp(labelsDemographics,'Weight')};                                           % get the Body mass for each subject
    momArm_all = round([Marm_GT2Knee;Marm_GT2Ankle;Marm_GT2Ankle;Marm_GT2Ankle;Marm_GT2Knee;Marm_GT2Ankle;Marm_GT2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle]./100,2);
    if isempty(momArm_all)
        sprintf ('moment arms for subject %s do not exist',CurrentSubject);
        continue
    end
    TorqueValues = (cell2mat(MaxStrengthPre(1:11,2)).*momArm_all./BodyMass)';
    MeanStrength_Pre(1,2:12)= MaxStrengthPre(1:11,1)';        %add labels
    MeanStrength_Pre(end+1,2:12)= num2cell(TorqueValues);
    MeanStrength_Pre{end,1}= CurrentSubject;
    SubjectAnaysed = [SubjectAnaysed SubjectRow];
    Gen{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Sex')};
    Group{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Group ')};
end

demographicsAnalysed = demographics(SubjectAnaysed,:);


% format data to use in the callback function 'Plot_meanWindividual'
Channels = MeanStrength_Pre(1,2:end);
ydata = cell2mat(MeanStrength_Pre(2:end,2:end));
SubjectCodes = MeanStrength_Pre(2:end,1);


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

% create figure
screensize = get( 0, 'Screensize' )/1.5;
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
StrengthMeanPlot = figure('Position', [180 75 Xsize Ysize]);


if PlotIndividual == 0
    
    br = Plot_meanWindividual(ydata,Channels,subjectIdx,10,'DeleteIfNotNeded');
    lgNames = {'Mean others','95%CI','You'};
    lg=legend(br([1,2,subjectIdx+2]),lgNames);
    
else
    
    
    % Plot mean data with individual points
    br = Plot_meanWindividual(ydata,Channels,subjectIdx,16);
    % color males blue and females orange
    indexF = find(strcmp(Gen,'F'));
    indexM = find(strcmp(Gen,'M'));
    for ii = 1:length(indexF)
        dotN = indexF(ii);
        br(dotN+2).MarkerFaceColor = [0.8500 0.3250 0.0980];            % orange
    end
    
    % plot legend: 1 = Mean strength; 2= CI; 3= dividual subjects; Subject + 2 = Number of the subject + the index of Mean Strength and CI (2)
    lgNames = {'Mean Strength','95%CI','Male','Female','You'};
    lg=legend(br([1,2,indexM(3)+2,indexF(3)+2,subjectIdx+2]),lgNames);
    
end


Nsubjects = length(br)-2;

% set plot dimensions and positions
set(gca, 'FontSize',14)
ylb = ylabel('Max strength (Nm/kg)');
ylb.Position = [-1.5 mean(ylim) -1.0000];
set(lg,'color','none','Location', 'northeastoutside');
mmfn
set(gca, 'FontSize',14,'Position' ,[0.22 0.1963 0.52 0.7281])

cd(DirResultsIsom);
saveas(gcf, sprintf('StrengthComparison-%s.jpeg',SubjectCodes{subjectIdx(1)}))

TorqueData = ydata;
save StrengthData  TorqueData Channels SubjectCodes
% end
close all