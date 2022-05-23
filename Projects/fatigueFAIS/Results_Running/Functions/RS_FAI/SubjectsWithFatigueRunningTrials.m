

function Subjects = SubjectsWithFatigueRunningTrials (SubjectFoldersElaborated, sessionName)
tic

fp = filesep;
if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end
if ~exist('Logic')
    Logic = 1;
end

%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;


Subjects ={};
for ff = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    DirMA = [SubjectFoldersElaborated{ff} fp sessionName fp 'muscleAnalysis'];
            
    files = dir(DirMA);
    
    idx = find(contains({files.name},'run_baseline','IgnoreCase',true));    
    idx = find(contains({files(idx).name},'1','IgnoreCase',true));
    
    idx2 =  find(contains({files.name},'runL','IgnoreCase',true));    
    idx2 = find(contains({files(idx2).name},'1','IgnoreCase',true));
        
    if length(idx) >0 && length(idx2) >0 
       Subjects{end+1} = SubjectFoldersElaborated{ff}; 
    end
    
end  

