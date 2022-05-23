

function getGRFvariables (SubjectFoldersElaborated, sessionName,Trials)

fp = filesep;


%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;


for k = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{k},filesep);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    
    OrganiseFAI
    
    % loop through the trials
    for kk = 1: length(Trials)
        TrialName = Trials{kk};
        % load the grf data file (FPdata)
        load([DirElaborated fp 'sessionData' fp  TrialName fp 'FPdata.mat']);
        fs = FPdata.Rate;
        
        
    end
end
