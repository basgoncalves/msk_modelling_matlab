% Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials
function BatchMA_FAI_BG (Subjects,Logic)

fp = filesep;

for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    updateLogAnalysis(Dir,'MA',SubjectInfo,'start')
   
    for trial=Trials.ID'; MuscleAnalysis_FAI(Dir,Temp,trial{1},Logic); end
    
    updateLogAnalysis(Dir,'MA',SubjectInfo,'end')
    
    plotMA(Subjects)
        
end

