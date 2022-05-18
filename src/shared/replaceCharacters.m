
function NewStruct = replaceCharacters (oldChar,newChar,FileStruct)

% replace underscore (_) for a dash (-) and sort alphabetically
FilesNames={};
for ii = 1: length (FileStruct)
    if contains(FileStruct(ii).name,oldChar)
    FilesNames{ii} =strrep(FileStruct(ii).name,oldChar,newChar);
    end
end
FilesNames =sort(FilesNames);
NewStruct = FileStruct;
% replace the new names in FilesIK
for ii = 1: length (FilesNames)
    if contains(FilesNames(ii),newChar)
    NewStruct(ii).name =strrep(FilesNames{ii},newChar,oldChar);
    end
end