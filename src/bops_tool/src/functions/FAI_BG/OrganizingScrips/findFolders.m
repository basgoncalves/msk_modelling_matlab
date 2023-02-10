% find trials 

function folders = findFolders(Path,TrialList,CannotContain)

files = dir ([Path]);
names = {files.name};
if ~isempty(CannotContain)
    idx = find(contains(names,TrialList,'IgnoreCase',true) & ~contains (names,CannotContain));
else
    idx = find(contains(names,TrialList,'IgnoreCase',true));
end

folders =  names(idx);
folders(strcmp(folders,'.')) = [];
folders(strcmp(folders,'..')) = [];