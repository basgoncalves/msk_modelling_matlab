%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Main script for PhD paper 3 results 
%-------------------------------------------------------------------------

%% Results Induced acceleration analysis
% PHD_IAA_results

DirResults = ([DirResults filesep 'IAA_sprint']);
cd(DirResults)
Trials = {'Run_baselineA1' 'Run_baselineB1'};
 
Subjects = {'028','029','030','031','033','034','036','037','039',...
    '040','041','045','047','048','056'};

% select multiple FAI participants
[SubjectFoldersInputData,SubjectFoldersElaborated,sessionName] = smfai(DirMocap,sessionName,Subjects);

for k = 1:length(SubjectFoldersElaborated(1:13))
    
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{k},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    
    OrganiseFAI     % generates directories and other necessary files
    
    
    [LegCont,CLCont] = ResultsIAA(DirIAA);
    
    LegCont.hip_flexion.Run_baseline1
    

end


% Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
 
 
 
[motions,GroupData] = ResultsCEINMS (SubjectFoldersElaborated,sessionName,Trials,1);
load([DirResults fp 'ExternaBiomechanics.mat'])

Plot_ResultsJointWork_RS(DirResults,Trials);
CorrStrength_Speed(SubjectFoldersInputData, sessionName);