function [velocityMax,LabelsVmax] = HorizontalVelocity_FAI_BG (SubjectFoldersElaborated,sessionName,CheckTrialNames)


if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end


DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
%generate the first subject
OrganiseFAI


for ff = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    OrganiseFAI
    
    DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
    mkdir(DirFigRunBiomech);
    Files = dir(sprintf('%s\\%s',DirIDResults,'*.sto'));
    oldChar='_';
    newChar='-';
    Files = replaceCharacters (oldChar,newChar,Files);    % Replace chanrarcters and reorganise alphabetically
    FileNames={};
    for ii=1:size(Files,1)
        FileNames{ii} = erase(Files(ii).name,'_inverse_dynamics.sto');
    end
    
    
    LRFAI           % load results results FAI
    
    Ntrials = length(Files);
    %% max velocity
    
    
    velocityMax=[];
    LabelsVmax = {};
    ContactTime = [];
    for ii = 1: length(CheckTrialNames)
        
        if ~isempty(find(contains(FileNames, CheckTrialNames{ii})))
            
            
            DirC3DFile = [DirC3D filesep CheckTrialNames{ii} '.c3d'];
            Markers = {'USACR','RSACR', 'LSACR'};
            
            % define gait cycle to use 
            load([DirIK filesep 'GaitCycle-' CheckTrialNames{ii}]);  
            
            
            GaitCycle = GaitCycle.ToeOff-GaitCycle.FirstFrameC3D;
            velocityMax(end+1) = maxSpeedMarkers (DirC3DFile, Markers,GaitCycle);
            LabelsVmax{end+1} = CheckTrialNames{ii};
            
            
            ContactTime(end+1) = findData(Run.ContactTime,FileNames,CheckTrialNames{ii});
            
            
        else
            velocityMax(end+1) = NaN;
            LabelsVmax{end+1} = CheckTrialNames{ii};
            ContactTime(end+1) = NaN;
            
        end
        
    end
    
    %% plot velocity in percentage
    figure
    y = velocityMax/max(velocityMax(1:2))*100;
    x = 1:length(velocityMax);
    plot(x,y,'.','MarkerSize',20,'Color','k')
    
    title(sprintf('participant %s',Subject))
    ylim([50 110]);
    hold on
    set(gca,'box', 'off', 'FontSize', 15);
    xticks(1:length(LabelsVmax));
    xticklabels (strrep(LabelsVmax,'_',' '))
    xtickangle(45)
    ylabel('max horizontal velocity(%)')
    set(gcf,'Color',[1 1 1]);
    
    idxLast = find(y>0);
    PercentChange =  sprintf('percent change = %.1f%%', 100- y(idxLast(end)));
    xRange = xlim;
    yRange= ylim;
    xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
    
    text(xRange(2)/2,yRange(2)*0.6,PercentChange,'FontSize', s, 'Color', c);
    
    cd(DirFigRunBiomech)
    saveas(gca, 'MaxVelocity_percentage.jpeg')
    
    %% plot velocity in m/s
    figure
    y = velocityMax;
    x = 1:length(velocityMax);
    plot(x,y,'.','MarkerSize',20,'Color','k')
    title(sprintf('participant %s',Subject))
    yax = ylim;
    ylim([yax(1)*0.5  yax(2)*1.5]);
    hold on
    set(gca,'box', 'off', 'FontSize', 15);
    set(gcf,'Color',[1 1 1]);
    xticks(1:length(LabelsVmax));
    xticklabels (strrep(LabelsVmax,'_',' '))
    xtickangle(45)
    ylabel('max horizontal velocity (m/s)')
    
    
    cd(DirFigRunBiomech)
    saveas(gca, 'MaxVelocity.jpeg')
    close all
    %% save data in indiviudal folder
    cd(DirElaborated)
    save maxRunningVelocity velocityMax LabelsVmax ContactTime
    
    cd(DirResults)
    load ('MaxRuningVelocity')
    
    idxSubject = str2double(Subject);
    MaxRuningVelocity(1:length(velocityMax),idxSubject) = velocityMax';
    
    save MaxRuningVelocity MaxRuningVelocity 
    
end

close all
