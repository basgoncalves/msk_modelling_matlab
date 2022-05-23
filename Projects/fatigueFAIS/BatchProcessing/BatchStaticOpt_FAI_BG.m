
function BatchStaticOpt_FAI_BG(Subjects)
fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    updateLogAnalysis(Dir,'StaticOpt',SubjectInfo,'start')
   
    trialList = [Trials.RunStraight(contains(Trials.RunStraight,'baseline','IgnoreCase',1)); Trials.Walking];
    for trial=Trials.CEINMS
        
        trialName = trial{1};
        runSO_BG(Dir, Temp, trialName)
        
        dofList = split(CEINMSSettings.dofList ,' ')';
        plotStaticOptResults_BG(Dir,CEINMSSettings,SubjectInfo,trialName,dofList)
    end
   updateLogAnalysis(Dir,'StaticOpt',SubjectInfo,'end')
end

cmdmsg('Static Opt analysis finished ')
