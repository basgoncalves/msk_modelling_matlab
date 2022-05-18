
if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
SubjectElaboratedFolders  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
sessionName = sessionPath{end};
end

%generate the first subject 
folderParts = split(SubjectElaboratedFolders{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectElaboratedFolders{1},'ElaboratedData','InputData') filesep sessionName];


for ff = 1:length(SubjectElaboratedFolders)
    OldSubject = Subject;
    folderParts = split(SubjectElaboratedFolders{ff},filesep);
    Subject = folderParts{end};
    DirID = [strrep(SubjectElaboratedFolders{ff},OldSubject,Subject) filesep sessionName filesep 'inverseKinematics' filesep 'Results'];
    if exist (DirID)
    cd(DirID)
    badFolder = [DirID filesep 'badtrials'];
    mkdir(badFolder);
    end
end


