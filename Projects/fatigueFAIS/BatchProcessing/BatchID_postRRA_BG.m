% run ID after running RRA
% Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials
function BatchID_postRRA_BG (Subjects,Logic)

for ff = 1:length(Subjects)
   
    [Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    updateLogAnalysis(Dir,'Inverse dynamics with RRA model',SubjectInfo,'start')
    
    for trial = Trials.IK'
 
        [osimFiles] = getosimfilesFAI(Dir,trial{1});
        
        if Logic==2 && exist(osimFiles.IDRRAresults,'file'); continue; end
        
        InverseDynamics_PostRRA (osimFiles.IDsetup,Dir.OSIM_RRA) 
    end    
    updateLogAnalysis(Dir,'Inverse dynamics with RRA model',SubjectInfo,'end')
end
cmdmsg('Inverse dynamics with RRA model finished ')