% find trials 

function TrialList_out = findFolders(Path,TrialList)

fp = filesep;
files = dir ([Path]);
names = {files.name};
idx = find(contains(names,TrialList,'IgnoreCase',true)& ~contains (names,'0'));
TrialList_out =  names(idx);
