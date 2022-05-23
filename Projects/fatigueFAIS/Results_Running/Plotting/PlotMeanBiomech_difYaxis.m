% PlotMeanBiomech_difYaxis
% plot mean Biomechanics



MainFig = figure;
fullscreenFig(0.9,0.6) % callback function
FS = 14;
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
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylb = ylabel('(-)ext  flex(+)','FontSize',FS);
Pos = ylb.Position;
xticklabels('')
% left side text 
txt = sprintf('Kinematics \n (rad)');
TextKin = text(Pos(1)*1.2,Pos(2),txt);
set(TextKin,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

% Angular velocity
s4 = subplot (Nrow,Ncol,Ncol+col);
p4 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)ext  flex(+)','FontSize',FS);
xticklabels('')
% left side text 
txt = sprintf('Angular velocity \n (rad/sec)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

% Moments
s7 = subplot (Nrow,Ncol,2*Ncol+col);
p7 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);  
hold on
APP_mean                                                           % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)ext  flex(+)','FontSize',FS);
xticklabels('')
% left side text 
txt = sprintf('Internal joint \n moment \n (Nm.kg^-^1)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

% Powers
s10 = subplot (Nrow,Ncol,3*Ncol+col);
p10 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);           
hold on
APP_mean                                                         % arrange power plots (axis, labels, font size, vertical lines, ticks)
ylabel('(-)absor  gener(+)','FontSize',FS);
xlabel ('Gait cycle (%)');
% left side text 
txt = sprintf('Joint power \n (W.kg^-^1)');
TextAngVel = text(Pos(1)*1.2,Pos(2),txt);
set(TextAngVel,'Position', [Pos(1)*3,Pos(2)],'Rotation',0,...
    'FontSize',FS,'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontName', 'Times New Roman');

%% Knee
cd(DirResults)
[MeanAngle,SDAngle, MeanAngVel,SDAngVel,MeanMoment,SDMoment,MeanPowers,SDPowers] = plotNames (MeanRun,'knee');
col = col+1;                                                            % second column

% Knee Kinematics
s2 = subplot (Nrow,Ncol,col);
p2 = plotShadedSD (MeanAngle,SDAngle/sqrt(N)*1.96);
t2 = title (sprintf('Knee'),'FontWeight','Normal');
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')


% Knee Angular velocity
s5 = subplot (Nrow,Ncol,Ncol+col);                                  % 2nd row
p5 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
ylim([-20 20]);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')


% Knee Moments

s8 = subplot (Nrow,Ncol,2*Ncol+col);                                % 3rd row 
p8 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')


% Knee Powers

s11 = subplot (Nrow,Ncol,3*Ncol+col);                               % 4th row
p11 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xlabel ('Gait cycle (%)');

%% Ankle plots
cd(DirResults)
[MeanAngle,SDAngle, MeanAngVel,SDAngVel,MeanMoment,SDMoment,MeanPowers,SDPowers] = plotNames (MeanRun,'ankle');
col = col+1;

% Kinematics
s3 = subplot (Nrow,Ncol,col);
p3 = plotShadedSD (MeanAngle,SDAngle/sqrt(N)*1.96);
t3 =title (sprintf('Ankle'),'FontWeight','Normal');
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')


% Angular velocity
s6 = subplot (Nrow,Ncol,Ncol+col);
p6 = plotShadedSD (MeanAngVel,SDAngVel/sqrt(N)*1.96);
hold on
APP_mean                                                            % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')

%  Moments
s9 = subplot (Nrow,Ncol,2*Ncol+col);
p9 = plotShadedSD (MeanMoment,SDMoment/sqrt(N)*1.96);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xticklabels('')


%  Powers
s12 = subplot (Nrow,Ncol,3*Ncol+col);
p12 = plotShadedSD (MeanPowers,SDPowers/sqrt(N)*1.96);
hold on
APP_mean                                                             % arrange power plots (axis, labels, font size, vertical lines, ticks)
xlabel ('Gait cycle (%)');

%% legend
% lg = legend ({'Mean pre','SE pre','Mean post','SE post','Mean foot contact baseline',...
%     'Mean foot contact last trial','SE foot contact baseline','SE foot contact last trial'});
lg = legend ({'Mean pre','95%CI pre','Mean post','95%CI post'});

set (lg,'Position',[0.89,0.45,0.092,0.13],'Box','off','FontSize',FS*0.8,'NumColumns',1)
% spt = suptitle(sprintf('Joint mechanics before and after 12x30meter sprints - N = %.f',N),'FontName', 'Times New Roman');

set(spt,'Position',[0.41,-0.039,0]);

cd([DirFigure filesep 'External_Biomechanics'])
saveas(MainFig, sprintf('MeanBiomechanics_Running.jpeg'));
