function BatchMuscleContributions(Subjects)

% memoryCheck('reset')
for isubj = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{isubj});
    
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
        
        dirIK = [Dir.IK fp trialName fp 'IK.mot' ];
        dirMC = [Dir.MC fp trialName fp];
        
        if ~exist(dirMC,'dir'); mkdir(dirMC); end
        
        dirExternalLoadsXML = [Dir.ID fp trialName fp 'grf.xml'];
        dirMA = [Dir.MA fp trialName fp];
        dirCEINMS = [Dir.CEINMSsimulations fp trialName];
        setupXML = [dirMC 'setup_JRA.xml'];
        
        cd(dirMC)
        copyfile(Temp.MCsetup,setupXML)
        
        CEINMSdir = OptimalGammaCEINMS_BG(Dir, dirCEINMS, SubjectInfo);                                            % get muscle force file from CEINMS
        muscle_force_file = CEINMSdir.MuscleForces;
        CEINMS_trialDir = CEINMSdir.Dir;
        
        all_forces_file = [dirMC 'all_muscles.sto'];
        [osimFiles] = getosimfilesFAI(Dir,trialName);
        
        JRAforcefile(CEINMS_trialDir,osimFiles,all_forces_file)                                                     % calculate the reserve actuators for each joint
        
        CreateMuscleActuatorFiles(dirMC, all_forces_file, all_muscles, muscles_of_interest)                         % create actuator files (i.e. force files with only one muscle force set to 1N)
        
%         intsegForce_JointReaction(dirIK,dirMC,dirExternalLoadsXML,dirModel,leg)                                   % calaulate intersegmental raction forces with no muscle forces
        disp('Calculate muscle contributions to JCF')
        for imusc = 1:length(muscles_of_interest)
            musc_name = muscles_of_interest{imusc};
            if ~exist([dirMC, char(musc_name),'_InOnParentFrame_ReactionLoads.sto'],'file')
            disp([musc_name])
            MuscleContribution2HCF(dirIK,dirMC,dirExternalLoadsXML,dirModel,musc_name,setupXML);           % calculate muscle contributions to joint forces
            %                 hip_x = ['hip_' leg '_on_pelvis_in_pelvis_fx'];
            %                 cont2HCF(:,imusc) = muscle_contributions.hip_l_on_pelvis_in_pelvis_fx;
            end
        end
    end
    
end

% memoryCheck('plot')
cmdmsg('Muscle Contributions finished ')

