function BatchMuscleContributions(Subjects)

plotData = 1;
% memoryCheck('reset')
for isubj = 1:length(Subjects)
    
    curr_subj = Subjects{isubj};
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(curr_subj);
    
    files = dir(Dir.CEINMSsimulations); files(1:2) = [];
    if isempty(files); continue; end
    
    updateLogAnalysis(Dir,'Muscle Contributions',SubjectInfo,'start')
    
    dirModel = Dir.OSIM_LO_HANS_originalMass;
    
    leg = lower(SubjectInfo.TestedLeg);                                                                             % find muscles used in CEINMS
    counter_leg = lower(SubjectInfo.ContralateralLeg);
    s = getOSIMVariablesFAI(upper(leg),dirModel);
    all_muscles = s.AllMuscles;
    all_muscles = [all_muscles strrep(all_muscles,['_' leg],['_' counter_leg])];
    muscles_of_interest = strcat(s.muscles_of_interest.All,['_' leg]);
    
    disp(SubjectInfo.ID)
    trialList = Trials.CEINMS;
    trialList = trialList(contains(trialList,'Run'));
    trialList = trialList(contains(trialList,Trials.RunStraight));
    for itrial = 1:length(trialList)
        trialName = trialList{itrial};
        disp(trialName)
        
        dirIK_mot = [Dir.IK fp trialName fp 'IK.mot' ];
        dirMC = [Dir.MC fp trialName fp];
        
        if ~exist(dirMC,'dir'); mkdir(dirMC); end
        
        dirExternalLoadsXML = [Dir.ID fp trialName fp 'grf.xml'];
        dirCEINMS = [Dir.CEINMSsimulations fp trialName];
        setupXML = [dirMC 'setup_JRA.xml'];
        
        cd(dirMC)
        copyfile(Temp.MCsetup,setupXML)
        
        CEINMSdir = OptimalGammaCEINMS_BG(Dir, dirCEINMS, SubjectInfo);                                            % get muscle force file from CEINMS
        CEINMS_trialDir = CEINMSdir.Dir;
        
        all_forces_file = [dirMC 'all_muscles.sto'];
        [osimFiles] = getosimfilesFAI(Dir,trialName);
        
        JRAforcefile(CEINMS_trialDir,osimFiles,all_forces_file)                                                     % calculate the reserve actuators for each joint
        
        GenericStaticOptimisation(dirIK_mot,dirMC,dirExternalLoadsXML, leg, dirModel)
        
        CreateMuscleActuatorFiles(dirMC, all_forces_file, all_muscles, muscles_of_interest)                         % create actuator files (i.e. force files with only one muscle force set to 1N)
        
%         intsegForce_JointReaction(dirIK_mot,dirMC,dirExternalLoadsXML,dirModel,leg)                                   % calaulate intersegmental raction forces with no muscle forces
        disp('Calculate muscle contributions to JCF')
        for imusc = 1:length(muscles_of_interest)
            musc_name = muscles_of_interest{imusc};
            muscle_JCF_file = [dirMC musc_name '_InOnParentFrame_ReactionLoads.sto'];
            if ~exist(muscle_JCF_file,'file')
            disp([musc_name])
            MuscleContribution2HCF(dirIK_mot,dirMC,dirExternalLoadsXML,dirModel,musc_name,setupXML);                    % calculate muscle contributions to joint forces
            
            if plotData == 1
               JCF_file = [Dir.JRA fp trialName fp 'JCF_JointReaction_ReactionLoads.sto'];
               saveDir = ([Dir.Results_JCFFAI fp 'PerTrial' fp curr_subj fp trialName]);
               contact_force_var = ['hip_' leg '_on_pelvis_in_pelvis'];
               Plot_MuscleContributions_Individual_trial(muscle_JCF_file,JCF_file,contact_force_var,saveDir)
            end
            
            end
        end
    end
    
end

% memoryCheck('plot')
cmdmsg('Muscle Contributions finished ')

