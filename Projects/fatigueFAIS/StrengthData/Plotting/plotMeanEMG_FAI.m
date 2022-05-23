%% Goncalves,BG (2019)
%plotMeanEMG_FAI
%
%INPUT
%   Subjects = cell array with the directories of each folder to use
%
%CALLBACK FUNCTIONS
%
%
OrganiseFAI
Nsubjects = length (Subjects);
nRow = 11;              % do not use Plantar flexion

PlotIndividual = 0;     %

% create figure
screensize = get( 0, 'Screensize' )/3;
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
Multiplots = figure('Position', [180 75 Xsize*2.5 Ysize]);
Nplot =1;

%select the number of the participant to use plot in color (RUN as a loop
%if needed)
if ~exist('subjectIdx') || isempty(subjectIdx)
    subjectIdx = inputdlg('select the subject to plot with color (e.g. "022")' );
    ss= strcmp(SubjectCodes(2:end),subjectIdx);
    subjectIdx = find(strcmp(SubjectCodes(2:end),SubjectCodes{ss}));
end


for ii = 1:length(plotMuscles)                % Eg. 1 2 3
    
    subplot (1,length(plotMuscles),ii)
    MeanEMGPre={};
    SubjectAnaysed =[];
    Gen = {};
    FAIM = {};
    
    for ss = 1: Nsubjects
        cd(Subjects{ss})
        CurrentSubject =Subjects{ss}(end-2:end);
        SubjectRow = find(strcmp(SubjectCodes,CurrentSubject));
        
        if exist('maxEMG.mat','file')==2
            load('maxEMG.mat')                                                     % for each participant folder, load maxEMG
        else                                                                            % if the file 'strength'
            fprintf ('maxEMG does not exist in %s \n',CurrentSubject)
            continue
        end
        
        Muscles = muscles;
        colMuscle = plotMuscles(ii)+1;           % find column of the muscle (idx of the muscle +1)
        LabelsTrials =  MaxEMGPre(1:nRow+1,1);
        idx_Max = find(strcmp(LabelsTrials, MaxEMGTrial));
        
        indivEMG = cell2mat(MaxEMGPre(2:nRow+1,colMuscle));
        maxEMG = indivEMG(idx_Max-1);
        
        % add data to the MeanEMGPre variable
        MeanEMGPre(1:nRow+1,1)= LabelsTrials;       % labels with the name of each trial
        MeanEMGPre(1,end+1)= {CurrentSubject};
        MeanEMGPre(2:nRow+1,end) = num2cell(indivEMG/maxEMG*100);
        SubjectAnaysed = [SubjectAnaysed SubjectRow];
        Gen{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Sex')};
        FAIM{end+1,1} = demographics{SubjectRow,strcmp(labelsDemographics,'Group ')};
    end
    
    Channels = MeanEMGPre(2:end,1)';
    ydata = cell2mat(MeanEMGPre(2:nRow+1,2:end))';
    SubjectCodes = MeanEMGPre(1,2:end)';
    
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
    
    
    if PlotIndividual == 0
        
        br = Plot_meanWindividual(ydata,Channels,0,10,'DeleteIfNotNeded');
        
        if ii == length(plotMuscles)
            % plot legend: 1 = Mean strength; 2= CI; 3= dividual subjects; Subject + 2 = Number of the subject + the index of Mean Strength and CI (2)
            lgNames = {'Mean','95%CI'};
            lg=legend(lgNames);
        elseif ii ~= 1            
            yticklabels('');  
        else
            ylabel (sprintf('Max EMG(%% of %s)',MaxEMGTrial));
            set(get(gca,'YLabel'),'Rotation',90)
        end
   
    else
        
        % 1 = bar; 2 = SD; 3... = scatter plots
        br=Plot_meanWindividual(ydata,Channels,subjectIdx,20);
              
        % color males blue and females orange
        indexF = find(strcmp(Gen,'F'));
        indexM = find(strcmp(Gen,'M'));
        
        % marker controls 'o' and FAIM '^'
        indexFAIM = find(strcmp(FAIM,'FAIM'))';
        indexControl = find(~strcmp(FAIM,'FAIM'))';
        for ff = 1:length(indexFAIM)
            Ndot = indexFAIM (ff)+2;                                        % (add 2 because the first 2 variables are the Bar and SD)
            br(Ndot).MarkerFaceColor = [0.8500 0.3250 0.0980];              % orange
        end
        
       if ii == length(plotMuscles)
            % plot legend: 1 = Mean strength; 2= CI; 3= dividual subjects; Subject + 2 = Number of the subject + the index of Mean Strength and CI (2)
            lgNames = {'Mean','95%CI','Cam morphology','Control','You'};
            lg=legend(br([1:2,indexFAIM(1)+2,indexControl(1)+2,subjectIdx+2]),lgNames);
            
        elseif ii ~=1
            ylabel ('');
            yticklabels('');
            
        else
             ylabel (sprintf('Max EMG(%% of %s)',MaxEMGTrial));
            set(get(gca,'YLabel'),'Rotation',90)
        end
    end
    
    title (sprintf('EMG %s',Muscles{plotMuscles(ii)}))
    set(gca,'FontSize',12)
    set(gcf,'Color',[1 1 1]);
    set(gca,'box', 'off')
    
end

lg.Position = [0.89 0.82 0.07 0.15];
set(lg,'color','none','Location', 'best');
legend('boxoff')


fprintf('\n',PlotIndividual)
fprintf('\n',PlotIndividual)
fprintf('PlotIndividual set to %d (1 = with individual data; 0 = without individual data) \n',PlotIndividual)
fprintf('\n',PlotIndividual)

