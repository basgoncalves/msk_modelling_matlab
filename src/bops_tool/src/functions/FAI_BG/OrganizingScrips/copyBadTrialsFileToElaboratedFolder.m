
function copyBadTrialsFileToElaboratedFolder(Subjects)

fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    %copyfile([Dir.Input fp 'BadTrials.mat'],[Dir.Elaborated fp 'BadTrials.mat'])    
    copyfile([Dir.Elaborated fp 'BadTrials.mat'],['E:\3-PhD\Data\MocapData\ElaboratedData' fp SubjectInfo.ID fp 'pre' fp 'BadTrials.mat'])    
end