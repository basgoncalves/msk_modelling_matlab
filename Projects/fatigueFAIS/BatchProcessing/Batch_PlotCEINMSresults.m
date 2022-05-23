

function Batch_PlotCEINMSresults (Subjects)
fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    trialList = Trials.CEINMS;
    for k = 1:length(trialList)
        SimulationDir = [Dir.CEINMSsimulations fp trialList{k}];
        PlotCEINMSresults(Dir,CEINMSSettings,SubjectInfo,SimulationDir)
    end
end
