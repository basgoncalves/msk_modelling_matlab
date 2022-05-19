
% check participants to see if they did the EMG check
function SubjectsToCheck = CheckEMGbadtrials(SubjectFoldersInputData,sessionName)

fp = filesep;

% generate the first subject
folderParts = split(SubjectFoldersInputData{1},fp);
Subject = folderParts{end};
DirC3D = [SubjectFoldersInputData{1} fp sessionName];

SubjectsToCheck =struct;
for ff = 1:length(SubjectFoldersInputData)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersInputData{ff},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    [DirMocap,~] = DirUp(DirC3D,3);
    SubjectsToCheck.(['s' Subject]) = struct;
    
    if exist([DirC3D fp 'BadTrials.mat'])
        SubjectsToCheck.(['s' Subject]) = 1;
        disp('')
        disp(['Data is fine for ' Subject])
        disp('')
    else
        SubjectsToCheck.(['s' Subject]) = 0;
        warning on
        disp('')
        warning(['Check subject ' Subject])
        disp('')
    end

end