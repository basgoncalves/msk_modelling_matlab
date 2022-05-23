% smfai_InputData
%select multiple FAI
if exist ('DirMocap')
cd([DirMocap filesep 'InputData'])
end

if ~exist ('SubjectFoldersInputData')|| isempty(SubjectFoldersInputData)
SubjectFoldersInputData  = uigetmultiple('','Select all the subject folders in the elaborated folder to run analysis');
end

if ~exist ([SubjectFoldersInputData{1} filesep SessionFolder])|| isempty(SessionFolder)
sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
SessionFolder = sessionPath{end};
end


DirC3D = [SubjectFoldersInputData{1} filesep SessionFolder];