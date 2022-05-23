function BatchLucaOptimiser_FAI_BG (Subjects,Logic)

for ff = 1:length(Subjects)
    [Dir,~,SubjectInfo,~] = getdirFAI(Subjects{ff});
    if ~exist(Dir.OSIM_LO,'file') || Logic == 1
        updateLogAnalysis(Dir,'Luca Optimizer',SubjectInfo,'start')
        LucaOptimizer_BG(Dir.OSIM_LinearScaled,Dir.OSIM_RRA)
        updateLogAnalysis(Dir,'Luca Optimizer',SubjectInfo,'end')
    end
end