function HCFWalkingCalibration

fp = filesep; Dir= getdirFAI;
[Subjects,Groups]=splitGroupsFAI(Dir.Main,'Walking');Subjects = Subjects(1:end);

[~,SubjectFoldersElaborated] = smfai(Subjects);

for ff = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{ff});
    
    if ~exist([Dir.CEINMS '_running']); movefile(Dir.CEINMS,[Dir.CEINMS '_running']); end
    if ~exist([Dir.JRA '_running']); movefile(Dir.JRA,[Dir.JRA '_running']); end
    %     BatchCEINMS_FAI_BG (Subjects(ff),2,1)
    %    BatchJRA_FAI_BG(Subjects(ff),2)
    
    for trial = Trials.RunStraight'
        if exist([Dir.CEINMS '_running' fp 'execution\simulations' fp trial{1}])
            copyfile([Dir.CEINMS '_running' fp 'execution\simulations' fp trial{1}],[Dir.CEINMSsimulations fp trial{1}]); end
        
        if exist([Dir.JRA '_running' fp trial{1}])
            copyfile([Dir.JRA '_running' fp trial{1}],[Dir.JRA fp trial{1}]);end
    end
end
