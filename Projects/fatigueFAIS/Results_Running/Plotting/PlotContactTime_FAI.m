%BG - 2019
% PlotContactTime_FAI
%Script to plot  contact time to all participants 
%
%CALLBACK FUNCTIONS
%   Plot_meanWindividual



%% Select folders
OrganiseFAI
cd([DirMocap filesep 'ElaboratedData'])
[SubjectFoldersElaborated] = uigetmultiple('','select multiple subjects Elaborated Folders');
Nsubjects = length (SubjectFoldersElaborated);

%% Arrange Mean data
CT={};      %Contact time
SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(:,SubjectCol);
Labels = {};

for ss = 1: Nsubjects                                                       % run through all selected subject folders
    smfai % get directories elaborated data
    cd([SubjectFoldersElaborated{ss} filesep sessionName])
    
    CurrentSubject =SubjectFoldersElaborated{ss}(end-2:end);
    SubjectRow = find(strcmp(SubjectCodes,CurrentSubject));
    
    if exist('maxRunningVelocity.mat','file')==2
        load maxRunningVelocity.mat                                                       % for each participant folder, load the strength data
    else                                                                            % if the file 'strength'
        fprintf ('maxRunningVelocity does not exist in %s \n',CurrentSubject)
        CT(ss+1,:)=num2cell(nan(1,12));
        CT{ss+1,1}= CurrentSubject;
        continue
    end
    
    
    Ncol  = size(velocityMax,2);
    CT(ss+1,2:Ncol+1)= num2cell(ContactTime);
    CT{ss+1,1}= CurrentSubject;
    
    if length(Labels) < length(LabelsVmax)
    Labels = LabelsVmax;
    end
    
end


CT(1,2:Ncol+1)=Labels;                              %add labels
%% Plot
% format data to use in the callback function 'Plot_meanWindividual'
Channels = CT(1,2:end);
ydata = cell2mat(CT(2:end,2:end));
SubjectCodes = CT(2:end,1);
currentSubjects = find(ismember (demographics(:,SubjectCol),SubjectCodes));

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
    
% Plot mean data with individual points
br = Plot_meanWindividual(ydata,Channels,subjectIdx,10);

% plot legend: 1 = Mean strength; 2= CI; 3= dividual subjects; Subject + 2 = Number of the subject + the index of Mean Strength and CI (2)
lgNames = {'Mean','95%CI','Male','Female'};
Nsubjects = length(br)-2;

for l=  1:length(subjectIdx)
    lgNames{end+1}= sprintf('%s',SubjectCodes{subjectIdx(l)});  
end

% color males blue and females orange
Gen = demographics(:,strcmp(labelsDemographics,'Sex'));
indexF = find(strcmp(Gen,'F'))';                % index of female subjects
indexM = find(strcmp(Gen,'M'))';                % index of male subjects

[~,indexF]=intersect(currentSubjects,indexF);  % gives index of currentSubjects that contains the values in indexF
[~,indexM]=intersect(currentSubjects,indexM);
for ii = indexF'+2
    br(ii).MarkerFaceColor = [0.8500 0.3250 0.0980];            % orange
end
       
        if indexM(1)+2 ==subjectIdx+2       % if the first male == the subject idx 
            indexM = indexM(2);
        end
            
         if indexF(1)+2 ==subjectIdx+2       % if the first male == the subject idx 
            indexF = indexF(2);
        end
            
lg=legend(br([1:2,indexM(1)+2,indexF(1)+2,subjectIdx+2]),lgNames);
ylb= ylabel({'Contact time (ms)'}, 'Rotation',0);
ylb.Position = [-4 mean(ylim) -1.0000];
% set plot position
set(lg,'color','none','Location', 'northeastoutside');
mmfn
set(gca, 'FontSize',14,'Position' ,[0.25 0.1963 0.5 0.7281])


cd(DirFigure);
mkdir([DirFigure filesep 'StrengthData' filesep SubjectCodes{subjectIdx(1)}]);      % new folder
cd([DirFigure filesep 'StrengthData' filesep SubjectCodes{subjectIdx(1)}])

saveas(gcf, sprintf('ContactTime-%s.jpeg',SubjectCodes{subjectIdx(1)}))

% end
close all