%% Basilio Goncalves 2020
% PlotPowerBursts
%
%CALLBACKS
% shadePower
% shadePower

%% start script
smfai


%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
clear TrialNames

for ff = 1:length(SubjectFoldersElaborated)
    
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = folderParts{end};
    DirElaborated = strrep(DirElaborated,OldSubject,Subject);
    
    LRFAI           % load results results FAI
    
    
    set(0,'DefaultAxesFontName', 'Times New Roman')
    TrialNames  = {'Run_baselineA1' 'RunL1'};
    
    AllNames = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
        'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};
    SubjecTrialNames = findClosedText (Labels,TrialNames,AllNames);
    
    c3dData = btk_loadc3d([DirC3D filesep SubjecTrialNames{1} '.c3d']);
    fs = c3dData.marker_data.Info.frequency;
    
    cMat = convertRGB([176, 104, 16;16, 157, 176;136, 16, 176;176, 16, 109;31, 28, 28]);  % color scheme 2 (Bas)
    
    
    FS = 16;
    Nyticks= 4;
    Ncol = 5;   %number of columns in the figure
    Nrow = 4;   % number of rows in the figure
    
    YLimKin =[-1 3]; YLimVel =[-20 20]; YLimM =[-5 5]; YLimP =[-40 40];
    %%  plots
    Cols = find(contains(Labels,SubjecTrialNames));
    PFig = figure;
    hold on 
    fcut = 10;
    
    % hip
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'hip_flexion',Cols);
    LStyle = ':';LineColor = [0 0 0]; PlotMarker = '^'; LWidth=1;
    shadePower         % generate plot 
    
    % knee 
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'knee',Cols);
    LStyle = '-'; LineColor = [0.3 0.3 0.3]; PlotMarker = 'square'; LWidth=1;
    shadePower         % generate plot 
    
    % ankle 
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'ankle',Cols);
    LStyle = '-';LineColor = [0 0 0]; PlotMarker = 'none'; LWidth=2;
    shadePower          % generate plot 
    
    ax = gca;
    ax.Children = flip(ax.Children);
    % find all the lines and get their index
    LineIndex=[];
    for ll = 1:length(ax.Children)
        if contains(class(PFig.Children.Children(ll)),'Line')
            LineIndex =  [LineIndex ll];
        end
    end
    ax.Children = flip(ax.Children);
    %% arrange plot
    
    
    xlb = xlabel('Gait cycle (s)');
    xlbPos = xlb.Position;
    set(gca,'box', 'off', 'FontSize', FS);
    set(gcf,'Color',[1 1 1]);
    
    %define x ticks
    xlim ([0 length(Angle(~isnan(Angle)))])
    xticks ([0:length(Angle(~isnan(Angle)))/5:length(Angle(~isnan(Angle)))]) % create 5 ticks 
    xlb.VerticalAlignment = 'middle';
    set (xlb,'FontSize',FS,'VerticalAlignment','top','HorizontalAlignment','center')
    
    TrialTime = length(Angle(~isnan(Angle)))/fs;
    xtic  = 0:TrialTime/(length(xticks)-1):TrialTime;        % timeTrial / number of ticks = length of each time interval
    
    for xt = 1:length(xtic)
        tickLabels{xt} = sprintf('%.2f',xtic(xt));
    end
    tickLabels{1} = '0';
    xticklabels (tickLabels);
    
    mmfn % make figure nice
    
    % adjust the size of the plot
    ax = gca;
    ax.Position = [0.30 0.14 0.6 0.75];
    ax.FontSize = 18;
    
    % ylabel and text 
    ylim([-50 50])
    ylb = ylabel(sprintf('(-) absor | gener (+)'));
    ylb.FontSize = ax.FontSize*0.9;
    ylb.Color = [0 0 0];
    
    txt = text(ylb.Position(1), 0,sprintf('Joint \n power \n (W/kg)')); % y text
    set (txt,'Position',[ylb.Position(1)*1.8, 0] ,'HorizontalAlignment', 'right',...
        'FontSize', ax.FontSize,'FontName','Times New Roman')
    
    % create vertical line for foot contact
    lines={'k','--k',':k','.k','k','--k',':k','.k'};
    for FC = 1:length(FootContact)
        Ymax = max(ylim);
        Ymin = min(ylim);
        data = Angle(:,FC);
        Xpos = mean(FootContact(FC))*length(data(~isnan(data)))/100;
        plot ([Xpos Xpos],[Ymin Ymax],lines{FC})
    end
    
    % legend
    ax.Children = flip(ax.Children);
    lg = legend(ax.Children([LineIndex,2,6]),{'Hip','Knee','Ankle','Flexor Work','Extensor Work'},'FontSize',12);
    lg.Box = 'off';
    
    cd(DirFigure);
    mkdir([DirFigure filesep 'IndividualData' filesep Subject]);      % new folder
    cd([DirFigure filesep 'IndividualData' filesep Subject])
    saveas(gcf, sprintf('PowerBursts-%s.jpeg',Subject))
    
    DirFigExtBiomech = [DirFigure filesep 'External_Biomechanics' filesep 'IndividualData'];
    mkdir(DirFigExtBiomech)
    cd(DirFigExtBiomech)
   saveas(gca, sprintf('PowerBursts-%s.jpeg',Subject));   
end

close all
