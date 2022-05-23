% batch joint reaction analysis BG 2020
% Logic = 1 (default); 1 = re-run trials / 0 = do not re-run trials
function BatchHandsfieldMuscleVolume_FAI_BG (Subjects)

for ff = 1:length(Subjects)
    
    [Dir,~,SubjectInfo,~] = getdirFAI(Subjects{ff});
    
    updateLogAnalysis(Dir,'HandsfieldMuscleVolume',SubjectInfo,'start')
    
    DirOut=strrep(Dir.OSIM_LO,'.osim','_hans.osim');
    scaleStrengthHandsfiedReg(Dir.OSIM_LO,DirOut,SubjectInfo.Weight,SubjectInfo.Height/100)
    
    updateLogAnalysis(Dir,'HandsfieldMuscleVolume',SubjectInfo,'end')   
end

cmdmsg('Handsfield Muscle Volume finished ')

