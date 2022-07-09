function BatchMuscleContributions(Subjects)

memoryCheck('reset')
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    %     CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    files = dir(Dir.CEINMSsimulations); files(1:2) = [];
    if isempty(files); continue; end
    
    updateLogAnalysis(Dir,'Muscle Contributions',SubjectInfo,'start')
    
    modelname = Dir.OSIM_LO_HANS_originalMass;
    
    leg = lower(SubjectInfo.TestedLeg);                                                                             % find muscles used in CEINMS
    s = getOSIMVariablesFAI(upper(leg),modelname);
    muscles_of_interest = strcat(s.muscles_of_interest.All,['_' leg]);
    
    disp(SubjectInfo.ID)
    trialList = Trials.CEINMS;
    trialList = trialList(contains(trialList,'Run'));
    for ii = 1:length(trialList)
        trialName = trialList{ii};
        disp(trialName)
        
        CreateMuscleActuatorFiles(Dir, trialName, leg, modelname,muscles_of_interest)
        intsegForce_JointReaction(Dir, trialName, leg, modelname)
        
        for m = 1:length(muscles_of_interest)
            musc_name = muscles_of_interest{m};
            dirSO = [Dir.SO fp trialName fp];
            if ~exist([dirSO, char(musc_name),'_InOnParentFrame_ReactionLoads.sto'],'file')
                
                dirIK = [Dir.IK fp trialName fp 'IK.mot' ];
                dirSO =  [Dir.SO fp trialName fp];
                dirExternalLoadsXML = [Dir.ID fp trialName fp 'grf.xml'];
                
                MuscleContribution2HCF(dirIK,dirSO,dirExternalLoadsXML, trialName, modelname,musc_name)
            end
        end
    end
    
end

memoryCheck('plot')
cmdmsg('Muscle Contributions finished ')

