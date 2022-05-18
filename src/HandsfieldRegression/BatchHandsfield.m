%% Batch perform Handsfield Adjustments for selected participants

function BatchHandsfield(SubjectFoldersElaborated, sessionName)
fp = filesep;


if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end

% Generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;

for ff = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D, OldSubject,Subject);
    
    OrganiseFAI
    
    osimModelPath = [DirElaborated fp 'FAI_generic' Subject '_Scaled.osim'];
    scaleStrengthHandsfiedReg (osimModelPath, MassKG, HeightMeters, Subject)
    
end