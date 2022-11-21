function onPath = is_on_path(Folder)

pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
    onPath = any(strcmpi(Folder, pathCell));
else
    onPath = any(strcmp(Folder, pathCell));
end