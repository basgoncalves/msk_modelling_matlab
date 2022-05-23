% batch_StrengthAndEMG_FAI 
function Batch_Isometric_FAI(Subjects)

for ff = 1:length(Subjects)
    
    [Dir,~,SubjectInfo,~] = getdirFAI(Subjects{ff});
    
    if isempty(fields(SubjectInfo));continue; end
  
    updateLogAnalysis(Dir,'Strength Data',SubjectInfo,'start')
        
    IsometricTorqueEMG(Dir,SubjectInfo)   
    
    updateLogAnalysis(Dir,'Strength Data',SubjectInfo,'end')
end

