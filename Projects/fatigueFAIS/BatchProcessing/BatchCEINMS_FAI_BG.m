% Logic =2 if do not want to re-run trials that already have exceution
function BatchCEINMS_FAI_BG(Subjects,Logic,WalkingCalibration)
fp = filesep;
if nargin<3; WalkingCalibration=0; end

check ={};
for ff = 1:length(Subjects)
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff},[],[],[],WalkingCalibration);
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    % added after deciding to re-run analysis without RRA
    % if "ceinms_rra" folder does not exist, move the current ceinms data
    % there and recreate the ceinms folders and template xmls
    if ~exist(CEINMSSettings.osimModelFilename);   continue;  end
    if contains(CEINMSSettings.osimModelFilename,'Rajagopal2015_FAI_originalMass_opt_N10_hans') && ~exist([Dir.CEINMS '_rra'])
        movefile(Dir.CEINMS,[Dir.CEINMS '_rra'])
        [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff},[],[],[],WalkingCalibration);
    end
    
    trialListXML = generateTrialsXml_BG(Dir,CEINMSSettings,Trials.Dynamic,1);                  % create xml files | last argument 1 = write the xml 0 = do not write xml
    generateExecutionXml_BG (Dir,Temp, CEINMSSettings, SubjectInfo ,trialListXML)
    
    if ~exist(CEINMSSettings.outputSubjectFilename,'file')
        if ~exist(CEINMSSettings.subjectFilename)
            copyfile(Temp.CEINMSuncalibratedmodel,CEINMSSettings.subjectFilename)
        end
        
        if ~contains(Trials.CEINMScalibration,Trials.MA) || ~contains(Trials.CEINMScalibration,Trials.IK)
            cmdmsg('CEINMS calibration trial does have muscle analysis / inverse dynamics, skiping this participant')
        end
        
        dofListCell = split(CEINMSSettings.dofList ,' ')';
        convertOsimToSubjectXml(SubjectInfo.ID,CEINMSSettings.osimModelFilename,dofListCell,CEINMSSettings.subjectFilename, Temp.CEINMSuncalibratedmodel)
        AddDannyTendon(CEINMSSettings.subjectFilename)
        AddContactModel(Dir,Temp,CEINMSSettings)
        generateCalibrationSetup_BG(Dir,CEINMSSettings);
        generateCalibrationCfg(Dir,CEINMSSettings, Temp,trialListXML,Trials.CEINMScalibration);
        %% Calibration
        updateLogAnalysis(Dir,'CEINMS Calibration',SubjectInfo,'start')
        disp(['CEINMS calibration running for ' SubjectInfo.ID ' ...'])
        
        % run CEINMS calibration
        cd(Dir.CEINMScalibration);
        [~,log] = dos([Dir.CEINMSexePath fp 'CEINMScalibrate -S ' CEINMSSettings.calibrationSetup]);
        cmdmsg(['CEINMS calibration complete for ' SubjectInfo.ID])
        
        CheckCalibratedValues(CEINMSSettings.outputSubjectFilename,CEINMSSettings.subjectFilename,SubjectInfo.TestedLeg)
        updateLogAnalysis(Dir,'CEINMS Calibration',SubjectInfo,'end')
    end
    %% CEINMS execution (EMG assisted)
    if WalkingCalibration==1; trialList = [Trials.Walking];
    else; trialList = [Trials.MA]; end
    
    CalibratedSubjectRelativePaths(CEINMSSettings.subjectFilename,Dir.OSIM_LO)
    CalibratedSubjectRelativePaths(CEINMSSettings.outputSubjectFilename,Dir.OSIM_LO)
    %     CEINMSStaticOpt_BG (Dir,CEINMSSettings,SubjectInfo,trialList) % for static Opt
    
    if Logic==1 || ~exist(CEINMSSettings.excitationGeneratorFilename2ndCal)
        RedoSecondCalibration(Dir); % reset the folders as if to match end of first calibration (comment if not needed)
        CEINMSSettings=CEINMSdoubleCalibration_BG(Dir,CEINMSSettings,SubjectInfo,Trials.CEINMScalibration);  % second calibration
    end
    idx = find(contains(trialList,'walking')| contains(trialList,'baseline')&contains(trialList,'1'));
    
    if contains(SubjectInfo.TestedLeg,'R')
        idx = find(contains(trialList,'baseline')&contains(trialList,'2'));
    else
        idx = find(contains(trialList,'baseline')&contains(trialList,'3'));
    end
    
    trialList=trialList([idx]);
    %     RedoExecutions(Dir)     % reset the simulations folder (comment if not needed)
    CEINMSmultipleTrials_BG(Dir,CEINMSSettings,SubjectInfo,trialList(1:end),Logic)
    
    
end

cmdmsg('CEINMS analysis finished ')