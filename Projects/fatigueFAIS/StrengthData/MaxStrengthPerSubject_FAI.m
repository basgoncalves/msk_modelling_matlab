%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
%Script to get max strength per subject
%
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   MaxStrength_FAI
%   getMaxTrials (GroupData,labels)
%   MultiBarPlot
%-------------------------------------------------------------------------
%INPUT
%-------------------------------------------------------------------------
%OUTPUT
%--------------------------------------------------------------------------

%% MaxStrengthPerSubject_FAI 

% name of the trials that should be in each folder
Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post','KE_post','KF_post','PF_post'};
DynamicTrials = {'SJ','SLSback','SLSfront','RestrictSquat','SquatNorm'};

StrengthDir = [Dir.Elaborated fp 'StrengthData'];
DirResultsIsom = [Dir.Results fp 'HipIsometric'];
cd(DirResultsIsom)
StrengthTrials = MaxStrength_FAI(Dir.Input,Isometrics_pre,saveDir, 0);                               %get the maximum strength 

% figure with indivudal max trials
figure
bb = bar(cell2mat(StrengthTrials(2,:)));
xticklabels (StrengthTrials(1,:))
xtickangle (45)
[~,Ntrials] = size(StrengthTrials);
xticks(1:Ntrials)
mmfn
set(gca,'TickLabelInterpreter','none')
set(gca,'FontSize',10)

% find the trials that are named "post" and colour them black
bb.FaceColor = 'flat';
for k = 1:Ntrials
    if contains(StrengthTrials(1,k),'post','IgnoreCase',true)
        colour = 0.4;
    else
        colour = 0.7;
    end
    bb.CData(k,:) = [colour colour colour];         % colour bars 
end

SubjFolder = cd;
idcs   = strfind(SubjFolder,'\');
SubjFolder = SubjFolder(1:idcs(end)-1);

% name subject
subject = SubjFolder(end-2:end);

StrengthTrials =StrengthTrials';                                % flip the array
GroupData = cell2mat(StrengthTrials(1:end,2));
labels = StrengthTrials (1:end,1);

% find the max for each condition (e.g. HE1,HE2,HE3...)
[MaxStrength,IdxMax_strength] = getMaxTrials (GroupData,labels);
MaxStrength(1,:)=[];

% find the mean for each condition (e.g. HE1,HE2,HE3...)
[MeanTrials,SDTrials] = getMeanTrials (GroupData,labels);

fprintf ('Max Strength trials complete \n')

%% order trials

NewMaxStrength=MaxStrength;
count=1;                                                            % use to count the number 
for ii = 1:length (Isometrics_pre)
    
    idx_pre = find(strcmpi(Isometrics_pre{ii},MaxStrength(:,1)));
    if isempty(idx_pre)~=1
        PreStr = MaxStrength{idx_pre,2};
        NewMaxStrength{count,1} = Isometrics_pre{ii};                   %Name pre trial
        NewMaxStrength{count,2} = PreStr;                               % data pre trial
        count=count+1;
    else
        PreStr = 0;
        NewMaxStrength{count,1} = Isometrics_pre{ii};                   % Name pre trial
        NewMaxStrength{count,2} = PreStr;                               % data pre trial
        count=count+1;
    end
    
    idx_post = find(strcmpi(Isometrics_post{ii},MaxStrength(:,1)));
    
    if isempty(idx_post)~=1
        PostStr = MaxStrength{idx_post,2};
        NewMaxStrength{count,1} = Isometrics_post{ii};            % name post trial
        NewMaxStrength{count,2} = PostStr;                            % data post trial
        count=count+1;
    else
        PostStr = 0;
        NewMaxStrength{count,1} = Isometrics_post{ii};                   %Name pre trial
        NewMaxStrength{count,2} = PostStr;                               % data pre trial
        count=count+1;
    end
    
end

MaxStrengthPre = NewMaxStrength(1:2:end,:);

fprintf ('Max Strength trials ordered \n')

%% plot max force pre and post

[Nrow,Ncol] = size (NewMaxStrength);
GroupData = cell2mat(NewMaxStrength(1:Nrow,2:Ncol));
labels = NewMaxStrength (1:end,1);
YLabel = 'Force(N)';
Channels = {sprintf('Force - %s_NewCalibration',subject)};

% bar plot Max force per trial
MultiBarPlot (GroupData,Channels,labels,YLabel);
source = sprintf('%s\\BarPlots.mat',cd);
destination = sprintf('%s\\MaxForce_Plots.mat',cd);
movefile(source, destination)

cd(Dir.Results);
mkdir('MaxStrength');
cd(sprintf('%s\\MaxStrength',DirResultsIsom))

nameTrial = (sprintf('%s-%s.jpeg','MaxForce',SubjectInfo.ID)); 
saveas(gcf,nameTrial)

%% pre post diff 
StrengthDiff={};
for ii = 1:2:length (NewMaxStrength)
    idx = strcmpi(Isometrics_pre{1},NewMaxStrength(:,1));
    StrengthDiff{ii,1} = NewMaxStrength{ii,1};
    StrengthDiff{ii,2} = (NewMaxStrength{ii+1,2}-NewMaxStrength{ii,2})/NewMaxStrength{ii,2}*100;
end

StrengthDiff= StrengthDiff(~cellfun('isempty',StrengthDiff));  %delete empty cells
StrengthDiff=reshape(StrengthDiff,length(StrengthDiff)/2,2);
StrengthDiff(10:12,:)=[];                                      % delete KF, KE and PF


disp ('Strength diff calculated')

figure
bar(cell2mat(StrengthDiff(1:end,end)));
xticks(1:length(StrengthDiff));
xticklabels(StrengthDiff(1:end,1));
set(gca,'TickLabelInterpreter','none','Position' ,[0.35 0.1963 0.5 0.7281]);
xtickangle(45)
ylb = ylabel({'Strength change(%)';'(post-pre)'}, 'Rotation',0);
ylb.Position = [-4 -25.0000 -1.0000];
title (sprintf('Force change after fatigue - %s',subject),'Interpreter','none');
mmfn % make mi figure look nice

cd (saveDir)
save strenghtData StrengthTrials MaxStrength NewMaxStrength MaxStrengthPre StrengthDiff

cd(DirResultsIsom);
SaveFolder = sprintf('%s\\strengthDiff',DirResultsIsom);
mkdir(SaveFolder);

nameTrial = (sprintf('%s-%s.jpeg','strengthDiff',SubjectInfo.ID)); 
saveas(gcf,[SaveFolder fp nameTrial])

%% plot the Standard deviation of the PRE and POST trials (as a percentage of the mean)

cd (SubjFolder)
disp ('Strength trials saved')
close all