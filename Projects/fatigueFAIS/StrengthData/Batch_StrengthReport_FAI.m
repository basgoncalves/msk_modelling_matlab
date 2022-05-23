% batch_StrengthAndEMG_FAI 


function Batch_StrengthReport_FAI(Subjects)

fp = filesep;[SubjectFoldersInputData,~] = smfai(Subjects);

for ff = 1:length(SubjectFoldersInputData)

    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{ff});
    PlotStrengthReport
    
end