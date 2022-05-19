

function SubjectsToCheck = CheckRRAgrf(SubjectFoldersInputData,sessionName)

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
    DirRRA =  [DirElaborated fp 'residualReductionAnalysis'];
    

    for k = 1:length(DynamicTrials)

        trialName = DynamicTrials{k};
        
        if ~exist([DirRRA fp trialName fp 'RRA' fp 'grf.xml'])
            continue
        end
        
        % load acquisition.xml
        XML = xml_read([DirRRA fp trialName fp 'RRA' fp 'grf.xml']);
        
        SubjectsToCheck.(['s' Subject]).(trialName) = 1;

        % find leg tested for this trial
        TestedLeg = findLeg(DirElaborated,trialName);
        
        % find step os FP based on manual events in the Session Data (after
        % "C3D2MAT")
        [events,FPstep] = findGaitCycle_FAIS(DirElaborated,trialName,TestedLeg);
        
        % find the number of forces in the GRF.xml
        Ngrf = length({XML.ExternalLoads.objects.ExternalForce.force_identifier});
               
        % loop through all the forceplates found in the XML file
        for kk = 1:Ngrf
            
            Fname = XML.ExternalLoads.objects.ExternalForce(kk).force_identifier;
            Fnumber = str2num(Fname(end-2)); % find the plate number 
            Fleg = XML.ExternalLoads.objects.ExternalForce(kk).applied_to_body(end);
            
            if ~contains(Fleg,lower(TestedLeg{1})) % if the force is not applied on the tested leg
                continue
            elseif ~find(FPstep==Fnumber) % if the FP number in XML does match that in the events file
                SubjectsToCheck.(['s' Subject]).(trialName) = 0;
                break
            end
        end
        
        
        % print out wether the trial needs checking or not
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