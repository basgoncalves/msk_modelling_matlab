% find trials 

function TrialList_out = findFolders(Path,TrialList,CannotContain)

fp = filesep;
files = dir ([Path]);
names = {files.name};
idx = find(contains(names,TrialList,'IgnoreCase',true)& ~contains (names,CannotContain));
TrialList_out =  names(idx);
