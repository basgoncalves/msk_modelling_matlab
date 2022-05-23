

%% THIS FUNCTION IS MEANT TO RUN MULTIPLE TRIALS IN CEINMS TO ALLOW FOR A FASTER EXECUTION

function CEINMSSettings = CEINMSdoubleCalibration_BG(Dir,CEINMSSettings,SubjectInfo,trialList)

fp = filesep;

trials=dir(Dir.CEINMStrials); trials(1:2) =[];
CalCFG = xml_read(CEINMSSettings.calibrationCfg);
CalTrials = CalCFG.trialSet;

for k = 1:length(trialList)
    
    if ~contains(CalTrials,trialList{k}); continue;  end
    
    for A = CEINMSSettings.Alphas
        for B = CEINMSSettings.Betas
            for G = CEINMSSettings.Gammas
                CEINMSexe_BG (Dir,CEINMSSettings,trialList{k},A,B,G);
            end
        end
    end
    cd(Dir.CEINMSsimulations)
    SimulationDir = [Dir.CEINMSsimulations fp trialList{k}];
    OptimalSettings = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);
    CEINMSexe_BG (Dir,CEINMSSettings,trialList{k},OptimalSettings.Alpha,OptimalSettings.Beta,OptimalSettings.Gamma);
    
    % create NEW trial.xml, emg.mot, excitationgeneration file
    CEINMSSettings = CreateSecondCalibrationFiles(Dir,CEINMSSettings,SubjectInfo,SimulationDir);
end

UpdatdeSecondCalibrationCfgSetup(Dir,CEINMSSettings)

cmdmsg('Execution for second calibration finished. Running second calibration...  ')

updateLogAnalysis(Dir,'Second Calibration',SubjectInfo,'start')% print log
cd(Dir.CEINMScalibration)
command=[Dir.CEINMSexePath fp 'CEINMScalibrate -S ' CEINMSSettings.calibrationSetup];
[~,log] = dos(command);
% write log
logFileOut = [Dir.CEINMScalibration fp 'out.log'];
fid = fopen(logFileOut,'w');
fprintf(fid,'%s\n', log);
fclose(fid);
CheckCalibratedValues(CEINMSSettings.outputSubjectFilename,CEINMSSettings.subjectFilename,SubjectInfo.TestedLeg)

updateLogAnalysis(Dir,'Second Calibration',SubjectInfo,'end')% print log

    function UpdatdeSecondCalibrationCfgSetup(Dir,CEINMSSettings)
        
        fp = filesep;
        %% create a copy of the first calibrated subject files
        BackupDir = [Dir.CEINMScalibration fp 'firstCalibrationFiles'];
        if exist(BackupDir)
            n = num2str(sum(contains(cellstr(ls(Dir.CEINMScalibration)),BackupDir))+1);
            BackupDir = [BackupDir '_' n];
        end
        mkdir(BackupDir);
        FirstCalFiles = dir(Dir.CEINMScalibration);
        for f = 3:length(FirstCalFiles)
            if FirstCalFiles(f).isdir==0
                copyfile([FirstCalFiles(f).folder fp FirstCalFiles(f).name],BackupDir)
            end
        end
        %% new calibration cfg file
        prefDef.NMSmodelType='openLoop'; %'hybrid' - not sure if this is in Calibration
        prefDef.tendonType= 'equilibriumElastic'; %'stiff' 'integrationElastic'
        prefDef.activationType='exponential'; %'piecewise'
        prefDef.parameterShareType = 'single'; %'global'
        prefDef.objectiveFunction = 'torqueErrorNormalised'; %'torqueErrorAndSumKneeContactForces'
        prefDef.legSide = 'none'; %'r' 'l' %for
        
        %load
        prefXmlRead.Str2Num = 'never';
        prefXmlRead.NoCells=false;
        XML = xml_read(CEINMSSettings.calibrationCfg,prefXmlRead);
        
        % edit xml
        XML.calibrationSteps.step.parameterSet.parameter{6}.absolute.range = '0.8 2';% range for strengthCoefficient
        XML.calibrationSteps.step.dofs = CEINMSSettings.dofList;
        XML.NMSmodel.type.(prefDef.NMSmodelType)= struct;      % xml_write will delete if empty matrix, so must be structure if wanting to keep
        XML.NMSmodel.tendon.(prefDef.tendonType)= struct;
        XML.NMSmodel.activation.(prefDef.activationType)= struct;
        
        % do the same for all parameters except the strengthCoefficients
        for k = 1:length(XML.calibrationSteps.step.parameterSet.parameter)-1
            XML.calibrationSteps.step.parameterSet.parameter{1,k}.single = struct;
        end
        
        if ~contains({XML.trialSet},'_2ndcal.xml')
            XML.trialSet = strrep(XML.trialSet,'.xml','_2ndcal.xml') ;
        else
            warning on
            warning('current calibration cfg already contains "_2ndcal.xml", check your files you dumb c***!!')
        end
        
        prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
        prefXmlWrite.CellItem   = false;
        xml_write(CEINMSSettings.calibrationCfg, XML,'calibration',prefXmlWrite);
        
        %% new calibration setup file
        XML = xml_read([CEINMSSettings.calibrationSetup]);
        newExcGenFile = CEINMSSettings.excitationGeneratorFilename2ndCal;
        XML.excitationGeneratorFile = relativepath(newExcGenFile,DirUp(CEINMSSettings.calibrationSetup,1));
        xml_write(CEINMSSettings.calibrationSetup, XML,'ceinmsCalibration');
        
        %% copy execution files to a new folder
        FirstExeFiles = dir(Dir.CEINMSsimulations);
        BackupDir =[FirstExeFiles(1).folder fp 'FirstExecution'];
        if exist(BackupDir)
            n = num2str(sum(contains(cellstr(ls(Dir.CEINMSsimulations)),'FirstExecution'))+1);
            BackupDir = [BackupDir '_' n];
        end
        mkdir(BackupDir); cd(Dir.CEINMSexecution)
        for f = 3:length(FirstExeFiles)
            if ~contains([FirstExeFiles(f).folder fp FirstExeFiles(f).name],BackupDir)
                movefile([FirstExeFiles(f).folder fp FirstExeFiles(f).name],[BackupDir fp FirstExeFiles(f).name])
            end
        end
        
    end

    function CEINMSSettings = CreateSecondCalibrationFiles(Dir,CEINMSSettings,SubjectInfo,SimulationDir)
        fp = filesep;
        
        [~,trialName] = DirUp(SimulationDir,1);
        
        dofList = split(CEINMSSettings.dofList ,' ')';
        Settings = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);
        
        exctGern = xml_read([Dir.CEINMSexcitationGenerator fp 'excitationGenerator.xml']);
        inputEMG = struct;
        for m = 1:length(exctGern.mapping.excitation)
            muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
            if contains(muscle,Settings.AllMuscles) && ~isempty(exctGern.mapping.excitation(m).input)
                inputEMG.(muscle) = exctGern.mapping.excitation(m).input.CONTENT;
            end
        end
        Settings.RecordedMuscles = fields(inputEMG);
        
        Rates = load([Dir.sessionData fp 'Rates.mat']);
        Rates = Rates.Rates;
        % TimeWindow = TimeWindow_FatFAIS(Dir,trialName); cd(SimulationDir);
        if ~exist([SimulationDir fp ' OptimalSettings.mat'])
            OptimalSettings = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);
            
            CEINMSexe_BG (Dir,CEINMSSettings,trialName,OptimalSettings.Alpha,OptimalSettings.Beta,OptimalSettings.Gamma);
        else
           OptimalSettings = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);            
        end
        BestItrDir = OptimalSettings.Dir;
        
        
        %% create a new EMG mot file
        MeasuredEMG = load_sto_file([Dir.dynamicElaborations fp trialName fp 'emg.mot']);
        AdjustedEMG = load_sto_file([BestItrDir fp 'AdjustedEmgs.sto']);
        MuscleNames = Settings.AllMuscles;
        for k = 1:length(MuscleNames)
            
            if contains(MuscleNames{k},Settings.RecordedMuscles) || ...
                    ~contains(MuscleNames{k},fields(AdjustedEMG))
                continue
            else
                
                TimeCEINMS = AdjustedEMG.time; TimeAnalog=MeasuredEMG.time;
                MuscleEMG = AdjustedEMG.(MuscleNames{k});
                rows = [find(TimeAnalog==TimeCEINMS(1,1)):find(TimeAnalog==TimeCEINMS(end,1))];
                InterpEMG = interp1(TimeCEINMS,MuscleEMG,TimeCEINMS(1):1/Rates.AnalogFrameRate:TimeCEINMS(end));
                
                current_muscle = strrep(MuscleNames{k},['_' lower(SubjectInfo.TestedLeg)],'');
                MeasuredEMG.(current_muscle) = zeros(length(TimeAnalog),1);
                MeasuredEMG.(current_muscle)(rows,1) = InterpEMG;
                for input = 1:length({exctGern.mapping.excitation.ATTRIBUTE})
                    if contains(exctGern.mapping.excitation(input).ATTRIBUTE.id,MuscleNames{k})
                        exctGern.mapping.excitation(input).input.CONTENT = current_muscle;
                        exctGern.mapping.excitation(input).input.ATTRIBUTE = struct;
                        exctGern.mapping.excitation(input).input.ATTRIBUTE.weight = '1';
                    end
                end
            end
        end
        inputSignals=char;
        EMGsLabels = fields(MeasuredEMG)';
        time = MeasuredEMG.time;
        EMGsLabels(1)=[];
        for m = 1:length(EMGsLabels)
            inputSignals = [inputSignals EMGsLabels{m} ' '];
        end
        exctGern.inputSignals.CONTENT = inputSignals;
        
        for m = 1:length(EMGsLabels); EMGsData(:,m)= MeasuredEMG.(EMGsLabels{m}); end
        
        newEMGsto = [Dir.dynamicElaborations fp trialName fp 'emg_2ndcal.mot'];
        folder = [Dir.dynamicElaborations fp trialName ];
        printEMGmot(folder,time,EMGsData,EMGsLabels, '_2ndcal.mot')
        
        %% New excitation generations xml
        newExcGenFile = CEINMSSettings.excitationGeneratorFilename2ndCal;
        xml_write(newExcGenFile, exctGern, 'excitationGenerator');
        
        %% new trials xml
        XML = xml_read([Dir.CEINMStrials fp trialName '.xml']);
        XML.excitationsFile = relativepath(newEMGsto,DirUp(newExcGenFile,1));
        XML.startStopTime = num2str(XML.startStopTime);
        newXMLfile = [Dir.CEINMStrials fp trialName '_2ndcal.xml'];
        xml_write(newXMLfile, XML,'inputData');
        
    end
end