%BG - 2019
%Script to get max strength plots for the biomechanics report
%
%CALLBACK FUNCTIONS
%   MaxStrength_FAI
%   getMaxTrials (GroupData,labels)
%   Plot_meanWindividual



%% PlotStrengthReport

saveDir = [Dir.Results fp 'ReportFigures' fp SubjectInfo.ID];
mkdir(saveDir)
DirStrengthData = [Dir.Elaborated fp 'StrengthData'];

if contains(SubjectInfo.Intramuscular,'YES')
    plotIntramusular = 1;
else
    plotIntramusular = 0;
end

%% PlotStrengthReport
% run through all selected subject folders
cd(DirStrengthData)
CurrentSubject = SubjectInfo.ID;

if exist('strenghtData.mat','file')==2
    load strenghtData.mat                                                       % for each participant folder, load the strength data
else                                                                            % if the file 'strength'
    fprintf ('strenghtData does not exist in %s \n',CurrentSubject)
    return
end

Marm_GT2Knee = SubjectInfo.GT2Knee;
Marm_GT2Ankle = SubjectInfo.GT2Ankle;
Marm_Pat2Ankle = SubjectInfo.Pat2Ankle;

BodyMass = SubjectInfo.Weight;                                           % get the Body mass for each subject
momArm_all = [Marm_GT2Knee;Marm_GT2Ankle;Marm_GT2Ankle;Marm_GT2Ankle;Marm_GT2Knee;Marm_GT2Ankle;Marm_GT2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle;Marm_Pat2Ankle]./100;
if isempty(momArm_all)
    sprintf ('moment arms for subject %s do not exist',CurrentSubject);
    return
end

TorqueValues = (cell2mat(MaxStrengthPre(1:11,2)).*momArm_all)';
MeanStrength_Pre = {};
MeanStrength_Pre(1,2:12)= MaxStrengthPre(1:11,1)';                                          % add labels
MeanStrength_Pre(end+1,2:12)= num2cell(TorqueValues);                                       % add values
MeanStrength_Pre(:,[3:5,11,12])= [];                                                        % remove the combined and knee tasks

% data from Casarteli et al (2011)
MeanStrength_Pre{end+1,2}= 1.66;    % extension
MeanStrength_Pre{end,3}= 1.17;      % flexion
MeanStrength_Pre{end,4}= 2.17;      % adduction
MeanStrength_Pre{end,5}= 2.03;      % abduction
MeanStrength_Pre{end,6}= 0.56;      % external rotation
MeanStrength_Pre{end,7}= 0.55;      % internal rotation

% format data to use in the callback function 'Plot_meanWindividual'
Channels = MeanStrength_Pre(1,2:end);
ydata = cell2mat(MeanStrength_Pre(2:end,2:end));
ylb = 'Max strength [Nm/kg]';
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
figure
BarBG (ydata',[],ylb,Channels,'',{'You' sprintf('Normative data \n(Casartelli et al. 2011)')},[],16);
ax = gca;
ax.Position = [0.25 0.15 0.65 0.8];
mmfn

cd(saveDir)
saveas(gcf, sprintf('Strength.jpeg',SubjectInfo.ID))
close all
%% strength difference
MeanStrengthDiff ={};
MeanStrengthDiff(1,2:10)= StrengthDiff(:,1)';       % labels with the name of each trial
MeanStrengthDiff(end+1,2:10)= StrengthDiff(:,2)';
MeanStrengthDiff(:,[3:5])= [];                                                        % remove the combined and knee tasks

% format data to use in the callback function 'Plot_meanWindividual'
Channels = MeanStrengthDiff(1,2:end);
ydata = cell2mat(MeanStrengthDiff(2:end,2:end));
ylb = 'Change in strength [%]';
% plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
figure
BarBG (ydata',[],ylb,Channels,{},{},[],16);
ax = gca;
ax.Position = [0.3 0.15 0.65 0.8];
mmfn
cd(saveDir)
saveas(gcf, sprintf('Strength_Fat.jpeg',SubjectInfo.ID))
close all
%% EMG
cd(DirStrengthData)
if exist('maxEMG.mat','file')==2
    load('maxEMG.mat')
    load strenghtData.mat
else
    fprintf ('maxEMG does not exist in %s \n',CurrentSubject)
    return
end

muscles = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF'};

muscleGroups = {'Gmax','ST','BF'};                              % Hip extensors
muscleGroups(end+1,1:2) = {'RF','TFL'};                         % Hip flexors
muscleGroups(end+1,1:4) = {'Gmed','PIR','OI','QF'};             % Deep hip muscles


EMGTrials = {'HE';'HF';'HE'};
nRow = 11;              % do not use Plantar flexion
count = 'A';            % count letter of the alphabet in the loop
c = 0;                  % count loops

B= figure;
% [ha, pos] = tight_subplot(4,4,0.05,0.05,0.08);
% set(gcf, 'Position', [107 76 1728 895]);

for mm = 1:size(muscleGroups,1)         % loop through all the muscle groups
    
    idxNonEmpty = find(~cellfun(@isempty,muscleGroups(mm,:)));
    plotMuscles = find(contains (muscles,muscleGroups(mm,idxNonEmpty)));
    
    for ii = 1:length(plotMuscles)
        c = c+1;
        MaxEMGTrial = EMGTrials{mm};
        colMuscle = plotMuscles(ii)+1;           % find column of the muscle (idx of the muscle +1)
        LabelsTrials =  MaxEMGPre(1:nRow+1,1);
        idx_Max = find(strcmp(LabelsTrials, MaxEMGTrial));
        
        indivEMG = cell2mat(MaxEMGPre(2:nRow+1,colMuscle));
        maxEMG = indivEMG(idx_Max-1);
        
        % add data to the MeanEMGPre variable
        MeanEMGPre ={};
        MeanEMGPre(1:nRow+1,1)= LabelsTrials;       % labels with the name of each trial
        MeanEMGPre(2:nRow+1,end+1) = num2cell(indivEMG/maxEMG*100);
        %MeanEMGPre(3:5,:)=[];       %delete rows
        
        
        % format data to use in the callback function 'Plot_meanWindividual'
        Channels =  MaxStrengthPre(1:11,1);
        %Channels (2:4) = [];
        ydata = cell2mat(MeanEMGPre(2:end,2:end));
        ylb = sprintf('Muscle activation \n[%% of %s]',MaxEMGTrial);
        Titl = muscles{plotMuscles(ii)};
        
        %plot bar with individual data (yData,ErrorBars,Ylb,Xtics,Titl,Lgd,IndivData,FontSize)
        figure
        BarBG (ydata',[],'',Channels,Titl,{},[],50);
        B(c) = gcf;
        B(c).Children.XTickLabelRotation = 45;
        B(c).Children.Position([2,4]) = [0.2 0.7];
        B(c).Children.YLabel.String = ylb;
        B(c).Children.YLabel.Position(1) = -2;
        MatColor = convertRGB ([252, 102, 3]);
        
        idx = find(strcmp(LabelsTrials(2:end),MaxEMGTrial)); %index of the plot to )
        unibar = bar (idx,ydata(idx));
        unibar.FaceColor = MatColor;                 % change color of a single
    end
    
end

% edit labels
br = B(end);
lgNames = {'Data normalised to this trial'};
lg = legend (br.Children.Children(1),lgNames);

% Merge figures


MainFig = figure;
fullscreenFig(0.9,0.7)
c = 0;              % count loops
count = 'A'-1;      %define a letter
PTM = [11:19];    %Plots To Merge
for ii = PTM
    c = c+1;
    mergeFigures(B(ii),MainFig,[3,4],c)
end

Position = [ 0.7484    0.1338    0.1566    0.1853];                % plot 1 botom right
Position(end+1,:) = [0.5422   0.1338    0.1566    0.1853];         % plot 2 (3,3)
Position(end+1,:) = [0.3361    0.1338    0.1566    0.1853];
Position(end+1,:) = [0.1300    0.1338    0.1566    0.1853];        % plot 5 (3,1)
Position(end+1,:) = [0.5422    0.4335    0.1566    0.1853];
Position(end+1,:) = [0.3361     0.4335    0.1566    0.1853];       % plot 7 (2,1)
Position(end+1,:) = [0.7    0.7331    0.1566    0.1853];
Position(end+1,:) = [0.45    0.7331    0.1566    0.1853];          % plot 9 (1,3)
Position(end+1,:) = [0.2    0.7331    0.1566    0.1853];
c = 0;
for ii = 2:10
    c = c+1;
    MainFig.Children(ii).Position = Position(c,:);
end

% position of the legend
MainFig.Children(1).Position = [ 0.8210    0.3843    0.1297    0.0280];

for ii = [2:4,6,8:9]
    MainFig.Children(ii).YLabel.String = '';
end

% delete plots relative to the intramuscular EMGs
if plotIntramusular == 0
    
    delete(MainFig.Children(2))
    delete(MainFig.Children(1))
    delete(MainFig.Children(1))
    delete(MainFig.Children(1))
    
    MainFig.Children(1)
    lg = legend (MainFig.Children(1).Children(1), lgNames);
    MainFig.Children(1).Position = [0.85 0.30 0.03 0.05]; %legend
    MainFig.Children(2).Position = [0.5422    0.12000    0.25    0.3];
    MainFig.Children(3).Position = [0.25    0.12000    0.25    0.3];
    MainFig.Children(4).Position = [0.72    0.6    0.25    0.3];
    MainFig.Children(5).Position = [0.43    0.6    0.25    0.3];
    MainFig.Children(6).Position = [0.13    0.6    0.25    0.3];
end
cd(saveDir)
saveas(gcf, sprintf('EMG_Strength.jpeg'))
%%
close all
