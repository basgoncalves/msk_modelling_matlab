% smfai
%select multiple participants FAI

function [SubjectFoldersInputData,SubjectFoldersElaborated] = smfai(Subjects)

fp = filesep; Dir=getdirFAI;

for k = 1:length(Subjects)
    SubjectFoldersInputData{k,1} = [Dir.Main fp 'InputData' fp Subjects{k}];
end

SubjectFoldersElaborated = strrep (SubjectFoldersInputData,'InputData','ElaboratedData');
