%BG - 2019
%Script to get mean strength plots fo
%
%CALLBACK FUNCTIONS
%   MaxStrength_FAI
%   getMaxTrials (GroupData,labels)
%   Plot_meanWindividual



%% MeanStrength_FAI
% mean Strength Pre - Select folders
function MeanStrength_FAI(DirMocap,sessionName,suffix)
fp = filesep;

[Groups,~,~] = splitGroupsFAI_Strength(DirMocap);
Subjects = sort([Groups.FAIS; Groups.CAM; Groups.Control]);
[SubjectFoldersInputData,SubjectFoldersElaborated,sessionName] = smfai(DirMocap,sessionName,Subjects);
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{1},sessionName,suffix);

%% Calculate torque and nromalise to BW
MeanStrength_Pre=[];
MeanStrength_Diff =[];
MeanStrength_Post =[];
Subjects = {};
load([Dir.Main fp 'demographics.mat'])

for ss = 1:length (SubjectFoldersElaborated)                                                       % run through all selected subject folders
 tic
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{ss},sessionName,suffix);

    cd(Dir.StrengthData)
    CurrentSubject = SubjectInfo.ID;
    cmdmsg(CurrentSubject)
    if isempty(SubjectInfo.GT2Knee)
        sprintf ('moment arms for subject %s do not exist',CurrentSubject);
%         continue
    end      
    
    load strenghtData.mat
    
    idx = [1:9];
    momArm_all = round([SubjectInfo.GT2Knee;1;1;1;SubjectInfo.GT2Knee;...
        SubjectInfo.GT2Ankle;SubjectInfo.GT2Ankle;SubjectInfo.Pat2Ankle;...
        SubjectInfo.Pat2Ankle],2);
    TorqueValues = (cell2mat(MaxStrengthPre(idx,2)).*momArm_all(idx)./SubjectInfo.Weight)';
    Headings_pre = MaxStrengthPre(idx,1)';        %add labels
    MeanStrength_Pre(end+1,1:length(TorqueValues))= TorqueValues;
   
    
    % strength post
    idx = [14 9 11 8 16 4 2 13 18];
    TorqueValues = (cell2mat(MaxStrength(idx,2)).*momArm_all./SubjectInfo.Weight)';
    Headings_post= MaxStrength(idx,1)';        %add labels
    MeanStrength_Post(end+1,1:length(TorqueValues))= TorqueValues;

    %mean strength diff
    Headings_Diff= StrengthDiff(:,1)';
    MeanStrength_Diff(end+1,1:9)= (cell2mat(StrengthDiff(:,2)))';
    
    Subjects{end+1,1}= CurrentSubject;

end

cd(Dir.Results_RSFAI)
save MeanStrengthData MeanStrength_Pre MeanStrength_Post MeanStrength_Diff Headings_pre Headings_post Headings_Diff Subjects Groups
