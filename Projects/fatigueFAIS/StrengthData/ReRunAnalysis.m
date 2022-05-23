
[Subjects] = uigetmultiple(cd,'select all the subjects to average strength from');
Nsubjects = length (Subjects);
%%
for ss = 1: Nsubjects
%% Organizeing folders
Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post','KE_post','KF_post','PF_post'};
DynamicTrials = {'SJ','SLSback','SLSfront','RestrictSquat','SquatNorm'};


MainDir = sprintf('%s\\Pre',Subjects{ss});
cd(MainDir);
folderC3D = sprintf('%s\\%s',MainDir,'*.c3d');
Files = dir(folderC3D);

mydir  = pwd;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);

cd(SubjFolder);

load('maxEMG.mat');
PreTrials = (size (MaxEMGTrials,1)-1)/2;                                    % number of pre trials = (all trials - first row)/2
MaxEMGPre = MaxEMGTrials (1,:); 
MaxEMGPre (2:PreTrials+1,:) = MaxEMGTrials (2:2:end,:);

TrialMaxEMG = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF'};
MaxEMGTrials (1,2:end)=TrialMaxEMG;

% max for each channel
[Nrow,Ncol] = size (MaxEMGTrials);
MaxData_EMG = cell2mat(MaxEMGTrials(2:Nrow,2:Ncol));
% max for only the pre trials
[Nrow,Ncol] = size (MaxEMGPre);
MaxEMG_permuscle = cell2mat(MaxEMGPre(2:Nrow,2:Ncol));
[MaxEMG_permuscle, idx] = max(MaxEMG_permuscle,[],1);
labels = MaxEMGTrials(2:end,1);
TrialMaxEMG = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF'};
for i = 1:length(idx)
    TrialMaxEMG{2,i} = labels(idx(i));
end

% FAI_Organizer.maxEMG_running = MaxEMGTrials;

cd(SubjFolder)
save maxEMG EMGdataAll MaxEMGTrials MaxEMGPre TrialMaxEMG TrialMaxEMG labels MaxEMG_permuscle IdxMaxEMG

sprintf ('Max EMG data saved')

end
