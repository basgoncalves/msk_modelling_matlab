function BatchMuscleContributions(Subjects)


for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
%     CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    files = dir(Dir.CEINMSsimulations); files(1:2) = [];
    if isempty(files); continue; end
    
    updateLogAnalysis(Dir,'Muscle Contributions',SubjectInfo,'start')
    
    modelname = Dir.OSIM_LO_HANS_originalMass;
    
    % find muscles used in CEINMS
    leg = lower(SubjectInfo.TestedLeg);
    s = getOSIMVariablesFAI(upper(leg),modelname);
    muscles_of_interest = strcat(s.muscles_of_interest.All,['_' leg]);
    
    disp(SubjectInfo.ID)
    trialList = Trials.CEINMS;   
    for ii = 1:length(trialList)
        trialName = trialList{ii};
        disp(trialName)
        MuscleContribution2HCF(Dir, trialName, leg, modelname,muscles_of_interest)
    end
end

cmdmsg('Muscle Contributions finished ')

