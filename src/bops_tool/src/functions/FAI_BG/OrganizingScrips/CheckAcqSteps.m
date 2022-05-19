

function SubjectsToCheck = CheckAcqSteps(SubjectFoldersInputData,sessionName)

fp = filesep;

% generate the first subject
folderParts = split(SubjectFoldersInputData{1},fp);
Subject = folderParts{end};
DirC3D = [SubjectFoldersInputData{1} fp sessionName];

SubjectsToCheck =struct;
for ff = 1:length(SubjectFoldersInputData)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersInputData{ff},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    [DirMocap,~] = DirUp(DirC3D,3);
    SubjectsToCheck.(['s' Subject]) = struct;
  
    
    
    disp('')
    disp(['Checking forceplate events for ' Subject '...'])
    disp('')
       
    % Demogrphics
    getDemographicsFAI
    
    % Define trials to analyse
    [Isometrics_pre,Isometrics_post,StaticTrial,DynamicTrials] = getTrialsFAI(DirC3D);
    DirElaborated =  strrep (DirC3D,'InputData','ElaboratedData');
    
    % load acquisition.xml
    XML = xml_read([DirC3D fp 'acquisition.xml']);
    for k = 1:length(DynamicTrials)

        trialName = DynamicTrials{k};
        
        if ~exist([DirC3D fp trialName '.c3d'])
            continue
        end
        
        SubjectsToCheck.(['s' Subject]).(trialName) = 1;

        % find leg tested for this trial
        TestedLeg = findLeg(DirElaborated,trialName);
        
        % find step os FP based on manual events in the Session Data (after
        % "C3D2MAT")
        [events,FPstep] = findGaitCycle_FAIS(DirElaborated,trialName,TestedLeg);
        
        % find the index of the current trial in the Acq XML
        idx_type = find(strcmp({XML.Trials.Trial.Type},trialName(1:end-1)));
        idx_number = find([XML.Trials.Trial.RepetitionNumber]==str2num(trialName(end)));
        idx = intersect(idx_type,idx_number);
        
        % loop through all the forceplates found in the manual events
        for kk = FPstep
            
            leg = XML.Trials.Trial(idx).StancesOnForcePlatforms.StanceOnFP(kk).leg;
            
            if ~contains(leg,TestedLeg{1})
                SubjectsToCheck.(['s' Subject]).(trialName) = 0;
                break
            end
        end
        
        if SubjectsToCheck.(['s' Subject]).(trialName) == 1
            
            
            disp('')
            disp(['Forceplate events are fine for ' trialName])
            disp('')
        elseif SubjectsToCheck.(['s' Subject]).(trialName) == 0
            warning on
            disp('')
            warning(['Check Acq.xml forceplate events for ' trialName])
            disp('')
        end
    end
end