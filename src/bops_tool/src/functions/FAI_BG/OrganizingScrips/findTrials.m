% find trials 

function outTrials = findTrials(DirC3D,DynamicTrials)

fp = filesep;
files = dir ([DirC3D fp '*.c3d']);
idx = contains({files.name}, DynamicTrials,'IgnoreCase',true);

% get only the relevant names 
names = {files(idx).name};
% idx = find(contains(names,'Run','IgnoreCase',true) & contains (names,'1')); % just run contains 1
idx = find(contains(names,DynamicTrials,'IgnoreCase',true)& ~contains (names,'0'));
outTrials =  names(idx);
outTrials = erase(outTrials,'.c3d');