function checkThroughFolders
fp = filesep;
[Dir,Temp,SubjectInfo,Trials] = getdirFAI;
Studies = {'JointWork_RS' 'RS_FAI' 'JCFFAI' 'IAA' 'Walking'};
S={};
for s = 1:length(Studies)
    S{s}=splitGroupsFAI(Dir.Main,Studies{s});
end
Subjects = unique([S{1}; S{2}; S{3}; S{4}; S{5}]);

[Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{1});
Folders = dir(DirUp(Dir.Elaborated,2));
ContainsSquat={};MAincomplete={}; 
for ff = 3:length(Folders)
    currentFolder = [Folders(ff).folder fp Folders(ff).name];
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Folders(ff).name);

    defiles = dir(Dir.dynamicElaborations);
    if any(contains([defiles.name],'squat','IgnoreCase',1))
        ContainsSquat(end+1) = {SubjectInfo.ID};
    end
    if any(contains(Trials.MA,Trials.CEINMScalibration))==0
        MAincomplete(end+1) = {SubjectInfo.ID};
    end    
end
