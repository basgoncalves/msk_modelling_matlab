%% CEINMS_steps




%% Step One: Generate your trials xml files


% to use relative paths change in
% ".\shared\writeTrial.m"
trialList = generateTrialsXml_BG(Dir,Trials.Dynamic);
cmdmsg('Trial XML files generated')
trialList'
%% Step Two: Prepare the calibration Cfg.xml and Setup.xml files
[ outputXmlFilename ] = generateCalibrationSetup_BG(Dir,Param,trialList); % Update outputDir in accordance with your files
fprintf('Calibration setup xml generated \n')

% find the running trial with lowest speed and use for calibration
calibrationTrials = findRunningCalibrationTrials (Dir,Trials,SubjectInfo);

% calibrationTrials = DynamicTrials;
[ calibrationCfgFilename ] = generateCalibrationCfg(Dir,Param, SubjectInfo,trialList,calibrationTrials);
fprintf('Calibration configuration xml generated \n')
%% Step Three: Prepare execution CFG.xml and setup.xml (alpha,beta,gamma)
generateExecutionXml_BG (trialsDir,trialList, nmsModel_exe, cfgExeDir,setupExeDir,...
 side, exeDir, pref, outputSubjectFilename, excitationGeneratorFilename, dofList)
fprintf('Execution xml generated \n')


