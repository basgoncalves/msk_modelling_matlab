
%% RenameFiles (folderPath,substring,newsubstring,Extension)
% replaces the name of the files containing the subtring with a new
% substring
% it allows to add a substring to the begining ('-*name*') or end
% ('*name*-') of all files in the folder
function RenameFiles(folderPath,substring,newsubstring,Extension)

fp = filesep;
original_path = cd;
cd(folderPath)

if ~exist('Extension','var')
    Extension = '*';
elseif ~contains(Extension,'*')
    Extension = ['*' Extension];
end

Files= dir(sprintf('%s\\%s',folderPath,Extension)); % get files from directory

for k = 1:length(Files)

    FileName = Files(k).name;
    if isequal(FileName,'.') || isequal(FileName,'..')
        continue
    elseif contains(FileName,substring)&& ~contains(FileName,newsubstring)
        NewFilename = strrep(FileName,substring,newsubstring);

    elseif contains(substring, '-*name')
        NewFilename = strrep(FileName,FileName,[newsubstring FileName]);        % add subtring in the beginning

    elseif contains(substring, 'name*-')
        NewFilename = strrep(FileName,FileName,[newsubstring FileName]);        % add subtring in the end

    else
        continue
    end

    movefile ([folderPath fp FileName], [folderPath fp NewFilename]);
end

cd(original_path)