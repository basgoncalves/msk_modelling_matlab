%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Compare all iterations of CEINMS exe and check best RMSE with torque
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   SimulationsDir = [char] directory of the your ceinms simulations for
%   one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% CompareCEINMSIterations
function CompareCEINMSIterations(SimulationsDir,side,itr)
tic
fp = filesep;

%% organise folders and directories
DirID = [fileparts(fileparts(fileparts(fileparts(SimulationsDir)))) fp 'inverseDynamics'];
DirIK = strrep(DirID,'inverseDynamics','inverseKinematics');
DirC3D = strrep(fileparts(DirID),'ElaboratedData','InputData');

OrganiseFAI

cd(SimulationsDir)
[~,trialName]  = fileparts(SimulationsDir);
trialName = split(trialName,'_beta');
trialName = trialName{1};


% find the iterations from CEINMS (use if doing multiple comparions, eg:
% change Gamma values)
files = dir(SimulationsDir);
files(1:2) = [];
% delete names that are not files
idx = find(~[files.isdir] );
files(idx) = [];
idx =[];
if exist('itr')
    for ii = 1:length(files)
        n = split(files(ii).name,'_');
        n = str2num(n{end});
        if sum(n==itr)==0
            idx(end+1) = ii;
        end        
    end
end
files(idx) = [];
OrderedFiles = natsortfiles({files.name}');

LW = 2;
Xlab = '% gait cycle';
%% define labels
s = lower(side{1});
% labels to load from the STO/MOT files

coordinates = {['hip_flexion_' s];['knee_angle_' s];...
    ['ankle_angle_' s]};

moments = {['hip_flexion_' s '_moment'];['knee_angle_' s '_moment'];...
    ['ankle_angle_' s '_moment']};

CEINMS_moments = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};

EMGmuscles = {'        VM','        VL','        RF','       GRA',...
    '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
    '        GL','       TFL','   GLUTMAX'}; % the spaces are part of the names


CEINMS_muscles = {['vasmed_' s];['vaslat_' s];['recfem_' s];['grac_' s];['tibant_' s];...
 ['addlong_' s];['semiten_' s];['bflh_' s];['gasmed_' s];['gaslat_' s];['tfl_' s];['glmax1_' s]};

fprintf('finding Gait Cycle... \n')
%%  load ID, IK and measaured EMG
GaitCycle = TimeWindow_FatFAIS(DirC3D,trialName,side);

MatchWord = 1; % 1= yes; 0 = no;
[ID_os,Labels] = LoadResults_BG ([DirID fp trialName fp 'inverse_dynamics.sto'],...
    GaitCycle,moments,MatchWord);

[IK_os,Labels_IK] = LoadResults_BG ([DirIK fp trialName fp 'IK.mot'],...
    GaitCycle,coordinates,MatchWord);

[EMG,Labels] = LoadResults_BG ([ElaborationFilePath fp trialName fp 'emg.mot'],...
    GaitCycle,EMGmuscles,MatchWord);

% load model to normalise the muscle forces
CEINMSModel = [fileparts(fileparts(fileparts(SimulationsDir))) fp ...
    'calibration\calibrated\calibratedSubject.xml'];

%% compare Joint moments
toc
fprintf('comparing moments from ID and CEINMS... \n')
figure
Xlab = '% gait cycle';
x = [1:101]';
for kk = 1:length(moments)
    % kinematics
    subplot (2,3,kk)
    hold on
    plot(x,IK_os(:,kk))
    mmfn_CEINMS
    ylim ([-40 150])
    tt = Labels_IK{kk};
    
    % define the titles 
    if contains(tt,'hip_flexion')
        tt = sprintf('    %s  \n (- ext)                   (+ flex)',tt);
    elseif contains(tt,'knee_angle')
        tt = sprintf('    %s  \n (- ext)                   (+ flex)',tt);
    elseif contains(tt,'ankle_angle')
        tt = sprintf('         %s  \n        (- plant)                (+ dorsi)',tt);
    end
    
    title(tt,'Interpreter','none')
    % x Labels and x ticks
    xticks('')
    %y ticks
    if kk ~= 1
        yticks('')
    else% first plot
        ylabels = ylabel('Angle (Deg)');
    end
    
    % moments
    subplot (2,3,kk+3)
    hold on
    plot(x,ID_os(:,kk))
    
    mmfn_CEINMS
    % x Labels and x ticks
    xlabel(Xlab)
    
    %y ticks
    if kk ~= 1
        yticks('')
    else% first plot
        ylabels = ylabel('Moment (Nm)');
    end
    
    ylim([-400 400])
    
end

lg = {'ID'}; %legend text
RMSE_mom = [];
for k = 1:length(OrderedFiles)
    
    fname = OrderedFiles{k};
    itr = regexp(files(k).name,'\d*','Match');
    itr = itr{1};
    fprintf([fname '\n'])
    %load CIENMS Torques
    [ID_itr,Labels] = LoadResults_BG ([SimulationsDir  fp fname fp 'Torques.sto'],...
        GaitCycle,CEINMS_moments,MatchWord);
    
    % load log for each iteration
    LOG = [SimulationsDir  fp fname fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    lg{k+1} = ['|A=' m{1}{4} '|B=' m{1}{7} '|G=' m{1}{end}];
    RMSE ='|RMSE ';
    for kk = 1:length(CEINMS_moments)
        subplot (2,3,kk+3)
        y = ID_itr(1:end,kk);
        plot(x,y)
        % Rsquared
        [r, pvalue] = corrcoef(ID_os(:,kk),y);
        rsq = num2str(round(r(1,2)^2,2));
        pvalue = pvalue(1,2);
        % RMSE
        R = round(rms(ID_os(:,kk)-y)/range(y)*100,1);
        RMSE_mom(k,kk) = R;
        RMSE = [RMSE CEINMS_moments{kk}(1:3) '=' num2str(R) '% |'];
        mmfn_CEINMS
    end
    lg{k+1}= sprintf('A=%s|B=%s|G=%s \n %s',m{1}{4},m{1}{7},m{1}{end},RMSE);

%     lg{k+1} =  [lg{k+1} RMSE];
end

l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.7468    0.4065    0.2377    0.1800];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.55   0.1100    0.18    0.3];
f.Children(3).Position = [0.55    0.5838    0.18    0.3];
f.Children(4).Position = [0.32   0.1100    0.18    0.3];
f.Children(5).Position = [0.32   0.5838    0.18    0.3];
f.Children(6).Position = [0.1   0.1100    0.18    0.3];
f.Children(7).Position = [0.1   0.5838    0.18    0.3];

cd(SimulationsDir)
saveas(gcf,'JointMoments.jpeg')
%% plot error for each momnet
figure
b = bar(RMSE_mom, 'FaceColor','flat');
xticklabels({files.name})
lg = legend(CEINMS_moments);
lg.FontSize = 12;
lg.Orientation ='horizontal';
lg.Position = [0.5    0.9    0.1    0.05];
lg.Interpreter ='latex';
ylabel('Moment RMSE (% range)')
ax = gca;
ax.Position = [0.25    0.1100    0.6    0.70];
cmap = colormap(parula);
for k = 1:length(CEINMS_moments)
    b(k).CData = cmap(5*k,:);
end
mmfn

cd(SimulationsDir)
saveas(gcf,'JointMoments_RMSE.jpeg')
%% compare excitations
fprintf('comparing measured and CEINMS activations... \n')
figure
Xlab = '% gait cycle';
x = [1:101]';
nrows = ceil(sqrt(length(EMGmuscles)));
for kk = 1:length(EMGmuscles)
    subplot (nrows,nrows,kk)
    hold on
    plot(x,EMG(:,kk))
    mmfn_CEINMS
    % x Labels and x ticks
    if kk > length(EMGmuscles)-nrows
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk ~= [1:nrows:length(EMGmuscles)]
        yticks('')
    elseif kk == 5 % first plot of the second row
        ylabels = ylabel('Excitation (relative max isom)');
        ylabels.Rotation = 90;
        ylabels.HorizontalAlignment = 'center';
    end
    ylim([0 1.5])
    
    %title
    title(strtrim(EMGmuscles{kk}))
end

lg = {'Measured EMG'}; %legend text
RMSE_exc = [];
for k = 1:length(OrderedFiles)% loop through CEINMS iterations for the same trial
    
    fname =  OrderedFiles{k};
    itr = regexp(fname,'\d*','Match');
    itr = itr{1};
    % load CEINMS activations
    [EMG_itr,Labels] = LoadResults_BG ([SimulationsDir  fp fname fp 'AdjustedEmgs.sto'],...
        GaitCycle,CEINMS_muscles,0);
    
    %     [ACT,Labels] = LoadResults_BG ([SimulationsDir  fp files(k).name fp 'Activations.sto'],...
    %         GaitCycle,CEINMS_muscles,0);
    
    % load log for each iteration
    LOG = [SimulationsDir  fp fname fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    
    %     lg{k+2} = ['activation'];
    for kk = 1:length(CEINMS_muscles) % loop through muscles
        subplot (nrows,nrows,kk)
        %Adj EMG
        y = EMG_itr(1:end,kk);
        plot(x,y)
        %         %Activations
        %         y = ACT(1:end,kk);
        %         plot(x,y)
        % Rsquared
        [r, pvalue] = corrcoef(EMG(:,kk),y);
        rsq = num2str(round(r(1,2)^2,2));
        pvalue = pvalue(1,2);
        % RMSE as a percentage of the range
        R = round(rms(EMG(:,kk)-y)/range(y)*100,1);
        RMSE_exc(k,kk) = R;
        RMSE = num2str(R);
        xPos = max(xlim)*0.5;
        yPos = max(ylim)*(0.95-0.08*k);
        %         text(xPos,yPos,['RMSE/r^2(' itr ')=' RMSE '/' rsq])
        mmfn_CEINMS
    end
    
    m1 = num2str(round(mean(RMSE_exc(k,:)),1));
    m2 = num2str(round(max(RMSE_exc(k,:)),1));
    lg{k+1}= sprintf('           |A=%s|B=%s|G=%s \n RMSmean=%s%% | RMSmax=%s%%',m{1}{4},m{1}{7},m{1}{end},m1,m2);
end

l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.79    0.39    0.195    0.2];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.62    0.2    0.14    0.15];
f.Children(3).Position = [0.45    0.2    0.14    0.15];
f.Children(4).Position = [0.25    0.2    0.14    0.15];
f.Children(5).Position = [0.08    0.2    0.14    0.15];
% middle row
f.Children(6).Position = [0.62    0.45      0.14    0.15];
f.Children(7).Position = [0.45   0.45    0.14    0.15];
f.Children(8).Position = [0.25    0.45    0.14    0.15];
f.Children(9).Position = [0.08    0.45    0.14    0.15];
% top row
f.Children(10).Position = [0.62    0.70      0.14    0.15];
f.Children(11).Position = [0.45    0.70    0.14    0.15];
f.Children(12).Position = [0.25    0.7    0.14    0.15];
f.Children(13).Position = [0.08    0.7    0.14    0.15];


cd(SimulationsDir)
saveas(gcf,'Excitations.jpeg')
%% plot error for each muscle
figure
b = bar(RMSE_exc, 'FaceColor','flat');
xticklabels({files.name})
lg = legend(CEINMS_muscles);
lg.FontSize = 12;
lg.Position = [0.87    0.5269    0.0731    0.3869];
ylabel('EMG RMSE (% range)')
ax = gca;
ax.Position = [0.25    0.1100    0.6    0.8150];
cmap = colormap(parula);
for k = 1:length(RMSE_exc)
    b(k).CData = cmap(5*k,:);
end
mmfn

cd(SimulationsDir)
saveas(gcf,'Excitations_RMSE.jpeg')
%% muscle forces (measured EMG muscles)
fprintf('plotting muscle forces... \n')
figure
Xlab = '% gait cycle';
x = [1:101]';
y= zeros(101,1);
nrows = ceil(sqrt(length(EMGmuscles)));
MF = struct;
% create subplots
for kk = 1:length(EMGmuscles)
    subplot (nrows,nrows,kk)
    hold on
    plot(x,y) 
    mmfn_CEINMS
    % x Labels and x ticks
    if kk > length(EMGmuscles)-nrows
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk ~= [1:nrows:length(EMGmuscles)]
%         yticks('')
    elseif kk == 5 % first plot of the second row
        ylabels = ylabel('Muscle Force (0 to max isom)');
        ylabels.Rotation = 90;
        ylabels.HorizontalAlignment = 'center';
    end
    
    %title
    title(strtrim(EMGmuscles{kk}))
end
RMSE =[];
rsq =[];
lg = {''}; %legend text

%plot muscle forces
for k = 1:length(files)% loop through CEINMS iterations for the same trial
    
    % load CEINMS activations
    [MForce,Labels] = LoadResults_BG ([SimulationsDir  fp files(k).name fp 'MuscleForces.sto'],...
        GaitCycle,CEINMS_muscles,0);
    
    NormForce = NormMuscleForce(CEINMSModel,MForce,Labels);

    % load log for each iteration
    LOG = [SimulationsDir  fp files(k).name fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    lg{k+1} = ['A=' m{1}{4} '|B=' m{1}{7} '|G=' m{1}{end}];
     
    for kk = 1:length(CEINMS_muscles) % loop through muscles
        subplot (nrows,nrows,kk)
        %normalise to max isom force
        plot(x,NormForce(:,kk))
        mmfn_CEINMS
    end
    
end


l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.81    0.4113    0.1578    0.2624];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.65    0.2    0.14    0.15];
f.Children(3).Position = [0.48    0.2    0.14    0.15];
f.Children(4).Position = [0.28    0.2    0.14    0.15];
f.Children(5).Position = [0.1    0.2    0.14    0.15];
% middle row
f.Children(6).Position = [0.65    0.45      0.14    0.15];
f.Children(7).Position = [0.48   0.45    0.14    0.15];
f.Children(8).Position = [0.28    0.45    0.14    0.15];
f.Children(9).Position = [0.1    0.45    0.14    0.15];
% top row
f.Children(10).Position = [0.65    0.70      0.14    0.15];
f.Children(11).Position = [0.48    0.70    0.14    0.15];
f.Children(12).Position = [0.28    0.7    0.14    0.15];
f.Children(13).Position = [0.1    0.7    0.14    0.15];

cd(SimulationsDir)
saveas(gcf,'MuscleForces.jpeg')
%% norm muscle fibre velocity
fprintf('plotting muscle fibre velocities... \n')
figure

x = [1:101]';
y= zeros(101,1);
nrows = ceil(sqrt(length(EMGmuscles)));
for kk = 1:length(EMGmuscles)
    subplot (nrows,nrows,kk)
    hold on
    plot(x,y)
    % x Labels and x ticks
    if kk > length(EMGmuscles)-nrows
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk ~= [1:nrows:length(EMGmuscles)]
        yticks('')
    elseif kk == 5 % first plot of the second row
        ylabels = ylabel('(- short)      Norm fibre velocity       (len +)');
    end
    mmfn_CEINMS
    %title
    title(strtrim(EMGmuscles{kk}))
end

lg = {''}; %legend text
for k = 1:length(files)% loop through CEINMS iterations for the same trial
    
    % load CEINMS activations
    [MVel,Labels] = LoadResults_BG ([SimulationsDir  fp files(k).name fp 'NormFibreVelocities.sto'],...
        GaitCycle,CEINMS_muscles,0);
    
    % load log for each iteration
    LOG = [SimulationsDir  fp files(k).name fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    lg{k+1} = ['A=' m{1}{4} '|B=' m{1}{7} '|G=' m{1}{end}];
    
    for kk = 1:length(CEINMS_muscles) % loop through muscles
        subplot (nrows,nrows,kk)
        
        y = MVel(1:end,kk);
        plot(x,y)
        ylim([-1.5 1.5])
        mmfn_CEINMS
        
    end
    
end

l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.81    0.4113    0.1578    0.2624];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.65    0.2    0.14    0.15];
f.Children(3).Position = [0.48    0.2    0.14    0.15];
f.Children(4).Position = [0.28    0.2    0.14    0.15];
f.Children(5).Position = [0.1    0.2    0.14    0.15];
% middle row
f.Children(6).Position = [0.65    0.45      0.14    0.15];
f.Children(7).Position = [0.48   0.45    0.14    0.15];
f.Children(8).Position = [0.28    0.45    0.14    0.15];
f.Children(9).Position = [0.1    0.45    0.14    0.15];
% top row
f.Children(10).Position = [0.65    0.70      0.14    0.15];
f.Children(11).Position = [0.48    0.70    0.14    0.15];
f.Children(12).Position = [0.28    0.7    0.14    0.15];
f.Children(13).Position = [0.1    0.7    0.14    0.15];

cd(SimulationsDir)
saveas(gcf,'FibreVelocity.jpeg')
%% norm muscle fibre length
fprintf('plotting muscle fibre lengths... \n')
figure
Xlab = '% gait cycle';
x = [1:101]';
y= zeros(101,1);
nrows = ceil(sqrt(length(EMGmuscles)));

MAmuscles = {['vasmed_' s];['vaslat_' s];['recfem_' s];['grac_' s];['tibant_' s];['addlong_' s];...
    ['semiten_' s];['bflh_' s];['gasmed_' s];['gaslat_' s];['tfl_' s];['glmax1_' s]};

[FL_MA,Labels] = LoadResults_BG ([DirMA fp trialName fp '_MuscleAnalysis_FiberLength.sto'],...
    GaitCycle,MAmuscles,MatchWord);


for kk = 1:length(EMGmuscles)
    subplot (nrows,nrows,kk)
    hold on
    plot(x,y)
    % x Labels and x ticks
    if kk > length(EMGmuscles)-nrows
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk ~= [1:nrows:length(EMGmuscles)]
%         yticks('')
    elseif kk == 5 % first plot of the second row
        ylabels = ylabel('Norm fibre length');
        ylabels.Rotation = 90;
        ylabels.HorizontalAlignment = 'center';
    end
    mmfn_CEINMS
    %title
    title(strtrim(EMGmuscles{kk}))
end

lg = {''}; %legend text
for k = 1:length(files)% loop through CEINMS iterations for the same trial
    
    % load CEINMS activations
    [FL,Labels] = LoadResults_BG ([SimulationsDir  fp files(k).name fp 'NormFibreLengths.sto'],...
        GaitCycle,CEINMS_muscles,0);
    
    % load log for each iteration
    LOG = [SimulationsDir  fp files(k).name fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    lg{k+1} = ['A=' m{1}{4} '|B=' m{1}{7} '|G=' m{1}{end}];
    
    for kk = 1:length(CEINMS_muscles) % loop through muscles
        subplot (nrows,nrows,kk)
        
        y = FL(1:end,kk);
        plot(x,y)
%         ylim([0 2])
        mmfn_CEINMS
    end
    
end

l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.81    0.4113    0.1578    0.2624];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.65    0.2    0.14    0.15];
f.Children(3).Position = [0.48    0.2    0.14    0.15];
f.Children(4).Position = [0.28    0.2    0.14    0.15];
f.Children(5).Position = [0.1    0.2    0.14    0.15];
% middle row
f.Children(6).Position = [0.65    0.45      0.14    0.15];
f.Children(7).Position = [0.48   0.45    0.14    0.15];
f.Children(8).Position = [0.28    0.45    0.14    0.15];
f.Children(9).Position = [0.1    0.45    0.14    0.15];
% top row
f.Children(10).Position = [0.65    0.70      0.14    0.15];
f.Children(11).Position = [0.48    0.70    0.14    0.15];
f.Children(12).Position = [0.28    0.7    0.14    0.15];
f.Children(13).Position = [0.1    0.7    0.14    0.15];


cd(SimulationsDir)
saveas(gcf,'FibreLength.jpeg')
%% tendon lengths
fprintf('plotting tendon lengths... \n')
figure
Xlab = '% gait cycle';
x = [1:101]';
y= zeros(101,1);
nrows = ceil(sqrt(length(EMGmuscles)));

for kk = 1:length(EMGmuscles)
    subplot (nrows,nrows,kk)
    hold on
    plot(x,y)
    % x Labels and x ticks
    if kk > length(EMGmuscles)-nrows
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk ~= [1:nrows:length(EMGmuscles)]
%         yticks('')
    elseif kk == 5 % first plot of the second row
        ylabels = ylabel('Tendon length (m)');
        ylabels.Rotation = 90;
        ylabels.HorizontalAlignment = 'center';
    end
    mmfn_CEINMS
    %title
    title(strtrim(EMGmuscles{kk}))
end

lg = {''}; %legend text
for k = 1:length(files)% loop through CEINMS iterations for the same trial
    
    % load CEINMS activations
    [TL,Labels] = LoadResults_BG ([SimulationsDir  fp files(k).name fp 'TendonLengths.sto'],...
        GaitCycle,CEINMS_muscles,0);
    
    % load log for each iteration
    LOG = [SimulationsDir  fp files(k).name fp 'out.log'];
    Txt = importdata (LOG, ' ', 100000);
    [m,ln] = findLine(Txt,'Using alpha = ',0);
    lg{k+1} = ['A=' m{1}{4} '|B=' m{1}{7} '|G=' m{1}{end}];
    
    for kk = 1:length(CEINMS_muscles) % loop through muscles
        subplot (nrows,nrows,kk)
        
        y = TL(1:end,kk);
        plot(x,y)
        mmfn_CEINMS
    end
    
end

l = legend(lg);
l.FontSize = 12;
l.Box = 'off';
l.Position = [0.81    0.4113    0.1578    0.2624];
% adjust plot positions
f = gcf;
% bottom row
f.Children(2).Position = [0.65    0.2    0.14    0.15];
f.Children(3).Position = [0.48    0.2    0.14    0.15];
f.Children(4).Position = [0.28    0.2    0.14    0.15];
f.Children(5).Position = [0.1    0.2    0.14    0.15];
% middle row
f.Children(6).Position = [0.65    0.45      0.14    0.15];
f.Children(7).Position = [0.48   0.45    0.14    0.15];
f.Children(8).Position = [0.28    0.45    0.14    0.15];
f.Children(9).Position = [0.1    0.45    0.14    0.15];
% top row
f.Children(10).Position = [0.65    0.70      0.14    0.15];
f.Children(11).Position = [0.48    0.70    0.14    0.15];
f.Children(12).Position = [0.28    0.7    0.14    0.15];
f.Children(13).Position = [0.1    0.7    0.14    0.15];


cd(SimulationsDir)
saveas(gcf,'TendonLength.jpeg')

close all
%% save data
cd(SimulationsDir)

