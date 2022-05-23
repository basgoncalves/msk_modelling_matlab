% batch Inverse dynamics
% Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials
function BatchID_FAI_BG(Subjects,Logic)


for ff = 1:length(Subjects)
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    updateLogAnalysis(Dir,'ID',SubjectInfo,'start')
    TrialList=Trials.IK';
    
    for trial=TrialList
        InverseDynamics_FAI (Dir, Temp,trial{1},Logic);
    end
    
    updateLogAnalysis(Dir,'ID',SubjectInfo,'end')
end
% PlotOSIMresults(Subjects,'ID')
cmdmsg('Inverse dynamics finished')

