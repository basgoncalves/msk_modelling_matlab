
function BatchRRA_FAI_BG (Subjects,Logic)

fp = filesep;
cmdmsg('for RRA to work GRF should be measured at all times')
% MoveRRA(SubjectFoldersElaborated, sessionName,suffix)
for ff = 1:length(Subjects)
     
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    updateLogAnalysis(Dir,'RRA',SubjectInfo,'start')
    disp(SubjectInfo.ID)
    trialList = Trials.ID';
    idx = find(contains(trialList,'walking') | contains(trialList,'baseline')&contains(trialList,'1'));
    trialList=trialList([idx]);

    for trial=trialList
        ResidualReductionAnalysis_FAI(Dir,Temp,SubjectInfo,trial{1},Logic);        
    end
   
%    [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass,Adj]=adjustmodelmass_Mean(Dir,trialList);
%     cd(Dir.RRA);save Results segment_mass trials bodyNames MeanSegment_mass original_mass Adj
%     
    updateLogAnalysis(Dir,'RRA',SubjectInfo,'end')
end
cmdmsg('RRA analysis finished ')
