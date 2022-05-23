%% BatchRunningEMG_FAI
%
% Basilio Goncalves 2019

% select the 

[Subjects] = uigetmultiple(SubjFolder,'select all subjects folders in InputDataFolder');
Nsubjects = length (Subjects);

for ss = flip(1: Nsubjects)
    cd(Subjects{ss})
    if ~exist('maxEMG.mat')
        Subjects(ss)=[];
    end
end
%% Loop through subjects
Nsubjects = length (Subjects);
for ss = flip(1: Nsubjects)
     cd(Subjects{ss})
     DirC3D = [Subjects{ss} filesep 'pre'];
% data = btk_c3d2trc();
OrganiseFAI

% Specify folder directories based on system used - prompt asks user to select inputData folder
cd(DirInput)

LegCol = find(strcmp(labelsDemographics,'Measured Leg'));

cd(SubjFolder)
load ('maxEMG.mat');

if contains(demographics(SubjectRow,LegCol),'R')
    LegTested =  1;               % Right = 1 Left = 2
elseif contains(demographics(SubjectRow,LegCol),'L')
    LegTested =  2;
else
    disp('please specify tested leg')
end

[RunningEMG,RunningEvents,RawEMGrunning,TimeNormalizedEMG] = RunningEMG_FAI (DirC3D,MaxEMG_permuscle,LegTested);       % running EMG already normalised
RunningTrials = fields(RunningEMG);

mydir  = pwd;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);
cd(SubjFolder)

save RunningEMG RunningEMG RunningEvents RunningTrials TimeNormalizedEMG

%% Figure Running

PlotRunningEMG_FAI
close all

sprintf ('%s - EMG running done',Subject)
end