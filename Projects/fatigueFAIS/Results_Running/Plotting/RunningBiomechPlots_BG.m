
% RunningBiomechPlots_BG

fp = filesep;
if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end

%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
clear TrialNames
ff = 1;

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
    
    
    %% Hip plots
    Cols = find(contains(Labels,SubjecTrialNames));
    PFig = figure;
    fullscreenFig(0.9,0.6) % callback function
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'hip_flexion',Cols);
    fcut = 10;
    Power = matfiltfilt(1/fs, fcut, 2, Power);
    Moment = matfiltfilt(1/fs, fcut, 2, Moment);
    AngVel = matfiltfilt(1/fs, fcut, 2, AngVel);
    Angle = matfiltfilt(1/fs, fcut, 2, Angle);
    
    N = size(Angle,2);
    col = 2; % first column to plot
    % kinematics
    s1 = subplot (Nrow,Ncol,col);
    data = Angle;
    p1 = plot(Angle);
    title (sprintf('Hip'),'FontWeight','Normal')
    hold on
    ylim(YLimKin)
    APP                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
    ylb.String = ('(-) ext | flex (+)');
    xlabel('')
    xticklabels('')
    Pos = ylb.Position;
    txt = sprintf('Angle \n (rad)');
    TextKin = text(Pos(1)*1.2,Pos(2),txt);
    set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
        'FontSize',FS,'HorizontalAlignment','right',...
        'VerticalAlignment','middle', 'FontName', 'Times New Roman');
    lg = legend ('Pre','Post');
    set (lg,'Location','best','FontSize', FS*0.7)
    lg.Box='off';
    
    
    % Angular velocity
    s4 = subplot (Nrow,Ncol,Ncol+col);
    data = AngVel;
    p4 = plot (AngVel);
    hold on
    ylim(YLimVel)
    APP                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
    ylb.String = ('(-) ext | flex (+)');
    xlabel('');xticklabels('');
    txt = sprintf('Angular \n velocity \n (rad/s)');
    TextKin = text(Pos(1)*1.2,Pos(2),txt);
    set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
        'FontSize',FS,'HorizontalAlignment','right',...
        'VerticalAlignment','middle', 'FontName', 'Times New Roman');
    
    % Moments
    s7 = subplot (Nrow,Ncol,2*Ncol+col);
    data = Moment;
    p7 = plot (Moment);
    hold on
    ylim([-5 5])
    APP                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
    ylb.String =('(-)ext | flex(+)');
    xlabel('');xticklabels('');
    txt = sprintf('Moment \n (Nm/kg)');
    TextKin = text(Pos(1)*1.2,Pos(2),txt);
    set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
        'FontSize',FS,'HorizontalAlignment','right',...
        'VerticalAlignment','middle', 'FontName', 'Times New Roman');
    
    % Powers
    s10 = subplot (Nrow,Ncol,3*Ncol+col);
    data = Power;
    p10 = plot (Power);
    hold on
    ylim([-40 40])
    APP                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
    ylb.String =('(-)absor | gener(+)');
    txt = sprintf('Power \n (W/kg)');
    TextKin = text(Pos(1)*1.2,Pos(2),txt);
    set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
        'FontSize',FS,'HorizontalAlignment','right',...
        'VerticalAlignment','middle', 'FontName', 'Times New Roman');
    
    
    
    %% Knee Kinematics plots
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'knee',Cols);
    N = size(Angle,2);
    col = 3;
    % smooth data
    fcut = 10;
    Power = matfiltfilt(1/fs, fcut, 2, Power);
    Moment = matfiltfilt(1/fs, fcut, 2, Moment);
    AngVel = matfiltfilt(1/fs, fcut, 2, AngVel);
    Angle = matfiltfilt(1/fs, fcut, 2, Angle);
    
    % Knee Kinematics
    s2 = subplot (Nrow,Ncol,col); % 2nd row
    data = Angle;
    p2 = plot(Angle);
    for ii = 1: length(p1)
        p2(ii).Color = cMat(ii,:);
    end
    title (sprintf('Knee'),'FontWeight','Normal')
    hold on
    ylim(YLimKin)
    APP                                                             %arrange power plots
    ylb.String = ('');
    xlabel('');xticklabels('');
    
    
    % Knee Angular velocity
    s5 = subplot (Nrow,Ncol,Ncol+col);
    data = AngVel;
    p5 = plot (AngVel);
    
    for ii = 1: length(p1)
        p5(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimVel)
    APP                                                             %arrange power plots
    ylb.String = ('');
    xlabel('');xticklabels('');
    
    
    % Knee Moments
    s8  = subplot (Nrow,Ncol,2*Ncol+col);
    data = Moment;
    p8 = plot (Moment);
    for ii = 1: length(p1)
        p8(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimM)
    APP                                                             %arrange power plots
    ylb.String =('');
    xlabel('');xticklabels('');
    
    % Knee Powers
    s11 = subplot (Nrow,Ncol,3*Ncol+col);
    data = Power;
    p11 = plot (Power);
    for ii = 1: length(p1)
        p11(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimP)
    APP                                                             %arrange power plots
    ylb.String =('');
    
    %% Ankle plots
    
    [Angle, AngVel, Moment,Power,FootContact] =  plotNames_ind (Run,'ankle',Cols);
    N = size(Angle,2);
    
    col=col+1;
    
    % smooth data
    fcut = 10;
    Power = matfiltfilt(1/fs, fcut, 2, Power);
    Moment = matfiltfilt(1/fs, fcut, 2, Moment);
    AngVel = matfiltfilt(1/fs, fcut, 2, AngVel);
    Angle = matfiltfilt(1/fs, fcut, 2, Angle);
    
    % Kinematics
    s3 = subplot (Nrow,Ncol,col);
    data = Angle;
    p3 = plot(Angle);
    for ii = 1: length(p1)
        p3(ii).Color = cMat(ii,:);
    end
    title (sprintf('Ankle'),'FontWeight','Normal')
    hold on
    ylim(YLimKin)
    APP                                                             %arrange power plots
    ylb.String = ('');
    xlabel('');xticklabels('');
    
    % Angular velocity
    s6 = subplot (Nrow,Ncol,Ncol+col);
    data = AngVel;
    p6 = plot (AngVel);
    for ii = 1: length(p1)
        p6(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimVel)
    APP                                                             %arrange power plots
    ylb.String = ('');
    xlabel('');xticklabels('');
    
    %  Moments
    
    s9 = subplot (Nrow,Ncol,2*Ncol+col);
    data = Moment;
    p9 = plot (Moment);
    for ii = 1: length(p1)
        p9(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimM)
    APP                                                             % arrange power plots
    ylb.String =('');
    xlabel('');xticklabels('');
    
    %  Powers
    s12 = subplot (Nrow,Ncol,3*Ncol+col);
    data = Power;
    p12 = plot (Power);
    for ii = 1: length(p1)
        p12(ii).Color = cMat(ii,:);
    end
    hold on
    ylim(YLimP)
    APP                                                             %arrange power plots
    ylb.String =('');
    
    %%
    f= gcf;
    N = length(f.Children);
    for ii=[1:8]                                                    % plots from columns 2 and 3
        N2 = length(f.Children(ii).Children);
        f.Children(ii).FontSize;
        f.Children(ii).YTickLabel ='';                              % clear tick labels
    end
    
    % check the children that are axis
    SubplotCount= [];
    for ii = 1:N
        if contains (class(f.Children(ii)),'Axes')
            SubplotCount(end+1) = ii;
        end
    end
    
    % squeeze plots 1st row
    s2.Position(1) = s1.Position(1)+ s1.Position(3)+0.02;
    s3.Position(1) = s2.Position(1)+ s2.Position(3)+0.02;
    % squeeze plots 2nd row
    s5.Position(1) = s4.Position(1)+ s4.Position(3)+0.02;
    s6.Position(1) = s5.Position(1)+ s5.Position(3)+0.02;
    % squeeze plots 3rd row
    s8.Position(1) = s7.Position(1)+ s7.Position(3)+0.02;
    s9.Position(1) = s8.Position(1)+ s8.Position(3)+0.02;
    % squeeze plots 4th row
    s11.Position(1) = s10.Position(1)+ s10.Position(3)+0.02;
    s12.Position(1) = s11.Position(1)+ s11.Position(3)+0.02;
    %% Save
    
    % suptitle(sprintf('Participant %s', Subject),'FontName', 'Times New Roman')
    
    DirFigExtBiomech = [DirFigure filesep 'JointWork_RS' filesep 'IndividualData'];
    mkdir(DirFigExtBiomech)
    cd(DirFigExtBiomech)
    saveas(gca, sprintf('All Biomechanics %s.jpeg',Subject));    
end

close all
clear TrialNames