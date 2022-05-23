% PlotMeanBiomech
% plot mean Biomechanics

MainFig = figure;
fullscreenFig(0.9,0.6) % callback function
FS = 16;
Nyticks= 4;
Ncol = 5;   %number of columns in the figure
Nrow = 4;   % number of rows in the figure

YLimKin =[-1 3]; YLimVel =[-20 20]; YLimM =[-5 5]; YLimP =[-40 40];

set(0,'DefaultAxesFontName', 'Times New Roman')
cd(DirResults)
load ('MeanRunningBiomechanics.mat')    

%% hip flexion 
[MeanAngle,SDAngle, MeanAngVel,SDAngVel,MeanMoment,SDMoment,MeanPowers,SDPowers,MeanFootContact,SDFootContact] = plotNames (MeanRun,'hip_flexion');

N = size(MeanRun.Labels,1);

col = 2;    % column to plot the next graphs
% kinematics
s1 = subplot (Nrow,Ncol,col);
p1 = plotShadedSD (MeanAngle,SDAngle/sqrt(N)*1.96);
t1 = title (sprintf('Hip'),'FontWeight','Normal');
ylim(YLimKin)
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylb = ylabel('(-)ext | flex(+)','FontSize',FS);
Pos = ylb.Position;
xticklabels('')
% left side text 
txt = sprintf('Angle \n (rad)');
TextKin = text(Pos(1)*1.2,Pos(2),txt);
set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');
ax = gca;
hAxis = flip(ax.Children);
lg = legend (hAxis([1,3]),{'Mean pre','Mean post'});
set (lg,'Position',[0.3759 0.8549 0.0655 0.08],'Box','off','FontSize',FS*0.7)


% Angular velocity
s4 = subplot (Nrow,Ncol,Ncol+col);
p4 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
ylim(YLimVel);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)ext | flex(+)','FontSize',FS);
xticklabels('')
% left side text 
txt = sprintf('Angular \n velocity \n (rad/s)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

% Moments
s7 = subplot (Nrow,Ncol,2*Ncol+col);
p7 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);  
ylim(YLimM);
hold on
APP_mean                                                           % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)ext | flex(+)','FontSize',FS);
xticklabels('')
% left side text 
txt = sprintf('Moment \n (Nm/kg)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

% Powers
s10 = subplot (Nrow,Ncol,3*Ncol+col);
p10 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);           
hold on
ylim(YLimP);
APP_mean                                                         % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)absor | gener(+)','FontSize',FS);
xlabel ('Gait cycle (%)');
% left side text 
txt = sprintf('Power \n (W/kg)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');


% plot vertical lines and text 
% plotVert (30,{'-'},{'k'})   % plot verical line 
% plotVert (82.5,{'-'},{'k'})   % plot verical line 
TextPosition = [17.1,52,75.9,92];
% [TextPosition,~] = ginput(4)'                                           % uncomment and use to find text position
txt = {'H3' 'H4' 'H1' 'H2'};
TextPower(TextPosition,txt,FS*0.7)

%% Knee
cd(DirResults)
[MeanAngle,SDAngle, MeanAngVel,SDAngVel,MeanMoment,SDMoment,MeanPowers,SDPowers] = plotNames (MeanRun,'knee');
col = col+1;                                                            % second column

% Knee Kinematics
s2 = subplot (Nrow,Ncol,col);
p2 = plotShadedSD (MeanAngle,SDAngle/sqrt(N)*1.96);
t2 = title (sprintf('Knee'),'FontWeight','Normal');
ylim(YLimKin)
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')


% Knee Angular velocity
s5 = subplot (Nrow,Ncol,Ncol+col);                                  % 2nd row
p5 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
ylim(YLimVel);
ylim([-20 20]);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')


% Knee Moments

s8 = subplot (Nrow,Ncol,2*Ncol+col);                                % 3rd row 
p8 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);
ylim(YLimM);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')


% Knee Powers

s11 = subplot (Nrow,Ncol,3*Ncol+col);                               % 4th row
p11 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);
ylim(YLimP);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xlabel ('Gait cycle (%)');
yticklabels('')

% plot vertical lines and text 
% plotVert (32.8,{'-'},{'k'})   % plot verical line 
% plotVert (80.5,{'-'},{'k'})   % plot verical line 
TextPosition = [15.1 51.1 74.6 89];
% [TextPosition,~] = ginput(4)                                           % uncomment and use to find text position
txt = {'K3' 'K4' 'K1' 'K2'};
TextPower(TextPosition,txt,FS*0.7)

%% Ankle plots
cd(DirResults)
[MeanAngle,SDAngle, MeanAngVel,SDAngVel,MeanMoment,SDMoment,MeanPowers,SDPowers] = plotNames (MeanRun,'ankle');
col = col+1;

% Kinematics
s3 = subplot (Nrow,Ncol,col);
p3 = plotShadedSD (MeanAngle,SDAngle/sqrt(N)*1.96);
t3 =title (sprintf('Ankle'),'FontWeight','Normal');
ylim(YLimKin)
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')


% Angular velocity
s6 = subplot (Nrow,Ncol,Ncol+col);
p6 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
ylim(YLimVel);
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')

%  Moments
s9 = subplot (Nrow,Ncol,2*Ncol+col);
p9 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);
ylim(YLimM);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')
yticklabels('')


%  Powers
s12 = subplot (Nrow,Ncol,3*Ncol+col);
p12 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);
ylim(YLimP);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xlabel ('Gait cycle (%)');
yticklabels('')
% plotVert (84.3,{'-'},{'k'})   % plot verical line 
TextPosition = [77.9,92.9];
% [TextPosition,~] = ginput(4)'                                           % uncomment and use to find text position
txt = {'A1' 'A2'};
TextPower(TextPosition,txt,FS*0.7)

%% sqeeze plots
    % squeeze plots 1st row
    s2.Position(1) = s1.Position(1)+ s1.Position(3)+0.03;
    s3.Position(1) = s2.Position(1)+ s2.Position(3)+0.02;
    % squeeze plots 2nd row
    s5.Position(1) = s4.Position(1)+ s4.Position(3)+0.03;
    s6.Position(1) = s5.Position(1)+ s5.Position(3)+0.02;
    % squeeze plots 3rd row
    s8.Position(1) = s7.Position(1)+ s7.Position(3)+0.03;
    s9.Position(1) = s8.Position(1)+ s8.Position(3)+0.02;
    % squeeze plots 4th row
    s11.Position(1) = s10.Position(1)+ s10.Position(3)+0.03;
    s12.Position(1) = s11.Position(1)+ s11.Position(3)+0.02;    
%% Save

cd([DirFigure filesep 'JointWork_RS'])
saveas(MainFig, sprintf('MeanBiomechanics_Running.jpeg'));


    
