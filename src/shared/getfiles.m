function filedirs = getfiles(directory)

filedirs = dir(directory);

% delete "../" and "./"
if isequal(filedirs(1).name,'.')
    filedirs(1:2) =[];                                          
end

% combine folder name and files names to be come a cell list of dirs
filedirs = fullfile(filedirs(1).folder,{filedirs.name});
