[Subjects] = uigetmultiple(cd,'select all the subjects to average strength from');
Nsubjects = length (Subjects);
%%
for ss = 1: Nsubjects
%% Organizeing folders
Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post','KE_post','KF_post','PF_post'};
DynamicTrials = {'SJ','SLSback','SLSfront','RestrictSquat','SquatNorm'};


C3DDir = sprintf('%s\\Pre',Subjects{ss});
cd(C3DDir);
folderC3D = sprintf('%s\\%s',C3DDir,'*.c3d');
Files = dir(folderC3D);

mydir  = pwd;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);
idcs   = strfind(SubjFolder,'\');
Subject = SubjFolder(idcs(end)+1:end);
idcs   = strfind(SubjFolder,'\');
MainDir = SubjFolder(1:idcs(end)-1);

cd(SubjFolder);
%% Max strength 

MaxStrengthPerSubject_FAI
close all
end

%% move data
for ss = 1: Nsubjects

    
C3DDir = sprintf('%s\\Pre',Subjects{ss});

idcs   = strfind(C3DDir,'\');
SubjFolder = C3DDir(1:idcs(end)-1);
cd(SubjFolder);

source = sprintf('%s\\BarPlots.mat',cd);
destination = sprintf('%s\\MaxForce_Plots.mat',cd);
movefile(source, destination)

end

