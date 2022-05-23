%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select bad trials from by visually analysing data from a c3d file 
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   checkEMGdata_multiple
%   MaxEMG_FAI
%   MultiBarPlot
%-------------------------------------------------------------------------
%OUTPUT
%    
%--------------------------------------------------------------------------

%% CheckEMG_isometricTrials_FAI
OrganiseFAI

mydir  = pwd;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);
StrengthFolder = ([SubjFolder filesep 'strength']);

% checkEMGdataFAI
muscleString = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF','Force'};

checkEMGdata_multiple (StrengthFolder, muscleString)
uiwait(gcf)

cd(SubjFolder)
load('BadTrials.mat');
cd(DirC3D)
load ('maxEMG.mat');
BadTrials = BadTrials(1:end-1,:);             %all trials without the Force column

for col = 1: size(BadTrials,2)
    for row = 1:size(BadTrials,1)
        if BadTrials{row,col} == 2
            EMGdataAll{row+1, col+1}=NaN;
        end
    end    
end
cd(SubjFolder)

save maxEMG EMGdataAll -append

%% rerun EMG analyis

cd(SubjFolder)
load maxEMG

[MaxEMGTrials,IdxMaxEMG] = MaxEMG_FAI(SubjFolder,EMGdataAll,DirC3D);
sprintf ('Individual EMG plots and Max EMGs - done')


[Nrow,Ncol] = size (MaxEMGTrials);
GroupData = cell2mat(MaxEMGTrials(2:Nrow,2:Ncol));
labels = MaxEMGTrials (2:end,1);
YLabel = 'EMG(mV)';
Channels = MaxEMGTrials (1,2:end);
TextBar = cell2mat(IdxMaxEMG(2:Nrow,2:Ncol));

% bar plot EMGs per muscle
MultiBarPlot (GroupData,Channels,labels,YLabel,TextBar);

% bar plot EMGs per task
% MultiBarPlot (GroupData',labels,Channels,YLabel);

source = sprintf('%s\\BarPlots.mat',cd);
destination = sprintf('%s\\Plot_Max_EMG-Isometrics.mat',cd);
movefile(source, destination)

sprintf ('Max EMG data plots saved')