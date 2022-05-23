%% Main script to batch process OpenSim processing tools, including:

% 1. Inverse Kinematics (IK)
% 2. Inverse Dynamics (ID)
% 3. Residual Reduction Analysis (RRA)
% 4. Muscle Analysis (MA)
% 5. Kinematics Analysis (KA)
% 6. Static Optimization (SO) - this can be made obsolete by running CEINMS in SO mode
% 7. CEINMS - Need to add processing scripts

% IK, ID, muscle analysis, and SO taken from Batch OpenSim Processing Scripts (BOPS)
% Copyright (C) 2015 Alice Mantoan, Monica Reggiani
% <https://simtk.org/home/bops>
% Please acknowledge the authors of BOPS when using this script.

% Residual reduction analysis and kinematics analysis added by Gavin Lenton, 2018.
% g.lenton@griffith.edu.au

clc;

tmp = matlab.desktop.editor.getActive;
pwd = fileparts(tmp.Filename); cd(pwd);
addpath(pwd, genpath([pwd filesep 'src']), genpath([pwd(1:end-8) 'ceinms_processing']));

%% Define BasePath with dynamicElaboration outputs and BOPS folder

% Select ElaboratedData folder
BasePath=uigetdir([pwd, filesep, '..'], 'Select Elaborated Data Folder');

% Select BOPS-master folder
% folderBOPS = uigetdir('.\', 'Select the BOPS processing folder');
folderBOPS = pwd;

% Define subject names
subsdir=dir(BasePath);
subjectNames = {subsdir([subsdir(:).isdir]).name}';
subjectNames(ismember(subjectNames,{'.','..', 'models'})) = [];

% Can define here if there are any subjects you would like to skip in analysis
badSubjects = {''};

% Select the type of analyses to run for all subjects
analysisList = {'Inverse Kinematics', 'Inverse Dynamics', 'Residual Reduction Analysis', 'Kinematics Analysis', 'Muscle Analysis', 'Static Optimisation', 'CEINMS', 'Joint Reaction Analysis'};
analysisIDs = {'IK', 'ID', 'RRA', 'KA', 'MA', 'SO', 'CEINMS', 'JRA'};
analysesIndex = listdlg('PromptString', 'Please select the type of analyses you would like to perform',...
    'SelectionMode','multiple','ListString',analysisList, 'ListSize', [300, 100]);

% From selection choose analyses to run
analysisToRun = analysisList(analysesIndex);
analysisIDList = analysisIDs(analysesIndex);

% Define some default plot options
Xaxislabel = '% Gait Cycle';

% Unique identifier that is present in all of your project setup files
setupFileIdentifier = inputdlg('What is the name you appended to all of your BOPS setup files?');

% Location of template setup folder
TemplatePath=[pwd, filesep, 'Templates', filesep];

% Directory to the model files within the session folder - edit this for your purposes
genericPathToModel = fullfile(BasePath, 'models');
appendName = 'Rajagopal2015_FAI.osim'; % Name appended on all osim models (e.g., Subject1_LSv2.osim)

% Set this flag = 0 if you want to process different trials with different models
% (e.g., if you collected multiple conditions in the same session) or to 1 if you want to process 
% all trials with the same scaled model. 
diffTrialsFlag = 1;

% Set this flag to zero if there is only one session, and 1 if there is more than one
% session
diffSessionFlag = 1;

%% Loop through subjects
for nS = 1:length(subjectNames)
    
    % Check if subject should not be processed
    badSubjectCheck = strcmp(badSubjects, subjectNames{nS});
    
    if ~any(badSubjectCheck) % if no values in variable badSubjectCheck then we can continue with analysis
        
        % Subject folder here
        fName = [BasePath, filesep, subjectNames{nS}];
        
        if diffSessionFlag > 0
        % Then create var for session names
        SessionDirs = dir(fName);
        sessionFolders={SessionDirs([SessionDirs(:).isdir]).name}';
        % add folders you want to exclude
        sessionFolders(ismember(sessionFolders,{'.','..', 'Figures', 'ROM',...
            'AnalysedData', 'Results', 'trials', 'executionSetupfiles', 'MeanEMGs'}))=[]; 
        
        else
            sessionFolders = {'oneSession'};
        end
       
        clearvars subsdir isub
        
        %% Loop through sessions for subject - if only one session then it doesn't matter
        for sD = 1:length(sessionFolders)
            
            % Based on subject information, extract list of model names to use, trial
            % parameters, directory containing input data, and model coordinates to plot
            [sessionName, modelNames, trialsFolders, acquisitionInfo, inputDir, coordinates] =...
                subjectSetup(fName, sessionFolders{sD}, subjectNames{nS}, genericPathToModel, diffTrialsFlag, appendName);
            
            %% Loop through selected analyses and process
            for cA = 1:length(analysisToRun)
                
                % Determine analysis and Identifying names
                currentAnalysis = analysisToRun{cA};
                currentAnalysisID = analysisIDList{cA};
                
                % Switch between analyses and process
                switch currentAnalysis
                    
                    % Inverse kinematics
                    case 'Inverse Kinematics'
                        
                        % Define output directory to check if IK has been run before
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep, currentAnalysisID];
                        
                        % Define template file name
                        setupFilesDir = dir([TemplatePath, 'IKProcessing', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier)).name;
                        setupFileFullDir = fullfile(TemplatePath, 'IKProcessing', setupFileName);
                        
                        % If directory doesn't exist we run IK
                        if ~exist(IKoutputDir, 'dir')
                            
                            % Run IK
                            [IKoutputDir, IKtrialsOutputDir, IKprocessedTrials]=InverseKinematics(inputDir, modelNames, trialsFolders, currentAnalysisID, setupFileFullDir);
                            
                            % Plot IK results and inspect for errors
                            IKmotFilename='FBM_ik.mot'; %our default name
                            plotResults(currentAnalysisID, IKoutputDir, IKtrialsOutputDir, modelNames.model_full_path{1}, IKprocessedTrials, IKmotFilename, coordinates, Xaxislabel);
                            
                            % Write down trials with erroneous data - script won't resume
                            % until current figure has been closed
                            uiwait
                            
                            % Analyse kinematics data
                            plotKinematics(sessionName, modelNames.model_full_path{1}, IKoutputDir, sessionFolders{sD}, sD);
                        else
                            
                            % Quest dialog for you to choose to re-run analysis (because directory exists so it has been run
                            % before)
                            reRunAnalysis = questdlg(sprintf('%s has already been run, do you want to run it again?',currentAnalysisID),...
                                'Re-run analysis?','Yes','No','Yes');
                            
                            % If choice is yes then we re-run
                            if strncmp(reRunAnalysis, 'Yes', 3)
                                
                                % Run IK
                                [IKoutputDir, IKtrialsOutputDir, IKprocessedTrials]=InverseKinematics(inputDir, modelNames, trialsFolders, currentAnalysisID, setupFileFullDir);
                                
                                % Plot IK results and inspect for errors
                                IKmotFilename='ik.mot'; %our default name
                                plotResults(currentAnalysisID, IKoutputDir, IKtrialsOutputDir, modelNames.model_full_path{1}, IKprocessedTrials, IKmotFilename, coordinates, Xaxislabel);
                                
                                % Write down trials with erroneous data - script won't resume
                                % until current figure has been closed
                                uiwait
                                
                                % Analyse kinematics data
                                plotKinematics(sessionName, modelNames.model_full_path{1}, IKoutputDir, sessionFolders{sD}, sD);
                                
                            else
                                disp('Inverse Kinematics has already been performed')
                            end
                        end
                        
                    case 'Inverse Dynamics'
                        
                        % Define output directory to check if ID has been run before
                        IDoutputDir = [sessionName, filesep, 'inverseDynamics', filesep, currentAnalysisID];
                        
                        % Define template file name
                        setupFilesDir = dir([TemplatePath, 'IDProcessing', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier)).name;
                        setupFileFullDir = fullfile(TemplatePath, 'IDProcessing', setupFileName);
                        
                        % If you want to run ID without having run IK before then we need
                        % to specify the IK output directory
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep, analysisIDs{1}]; % Define it from list of all possible analyses
                        
                        % If ID hasn't been run before (e.g., if ID folder directory
                        % hasn't been created) then we run it now
                        if ~exist(IDoutputDir, 'dir') && exist(IKoutputDir, 'dir')
                            
                            % Run ID
                            [IDoutputDir, IDtrialsOutputDir, IDprocessedTrials]=InverseDynamics(inputDir, modelNames, IKoutputDir, currentAnalysisID, setupFileFullDir);
                            
                            % Plot ID results
                            IDmotFilename='inverse_dynamics.sto'; %our default name
                            plotResults(currentAnalysisID, IDoutputDir, IDtrialsOutputDir, modelNames.model_full_path{1}, IDprocessedTrials, IDmotFilename, coordinates, Xaxislabel);
                            
                            % Pause UI and delete the bad trials
                            uiwait
                            
                            % Analyse moments data and store in cell array
                            plotMoments(sessionName, modelNames.model_full_path{1}, IDoutputDir, sessionFolders{sD}, sD);
                            
                        else
                            
                            % Quest dialog for you to choose to re-run analysis (because directory exists so it has been run
                            % before)
                            reRunAnalysis = questdlg(sprintf('%s has already been run, do you want to run it again?',currentAnalysisID),...
                                'Re-run analysis?','Yes','No','Yes');
                            
                            if strncmp(reRunAnalysis, 'Yes', 3) && exist(IKoutputDir, 'dir') % If choice is yes then we re-run
                                
                                % Run ID
                                [IDoutputDir, IDtrialsOutputDir, IDprocessedTrials]=InverseDynamics(inputDir, modelNames, IKoutputDir, currentAnalysisID, setupFileFullDir);
                                
                                % Plot ID results
                                IDmotFilename='inverse_dynamics.sto'; %our default name
                                plotResults(currentAnalysisID, IDoutputDir, IDtrialsOutputDir, modelNames.model_full_path{1}, IDprocessedTrials, IDmotFilename, coordinates, Xaxislabel);
                                
                                % Pause UI and delete the bad trials
                                uiwait
                                
                                % Analyse moments data and store in cell array
                                plotMoments(sessionName, modelNames.model_full_path{1}, IDoutputDir, sessionFolders{sD}, sD);
                            end
                        end
                        
                    case 'Residual Reduction Analysis'
                        
                        % Define output dir
                        RRAoutputDir = [sessionName, filesep, 'residualReductionAnalysis', filesep, currentAnalysisID];
                        
                        % Define setup dirs - there are four files for RRA
                        setupFilesDir = dir([TemplatePath, 'RRA', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier{1}) &...
                            contains({setupFilesDir(:).name}, 'Setup_')).name;
                        setupFileFullDir = fullfile(TemplatePath, 'RRA', setupFileName);
                        rraActuators = regexprep(setupFileFullDir, 'Setup', 'Actuators');
                        rraTasks = regexprep(setupFileFullDir, 'Setup', 'Tasks');
                        rraControlConstraints = regexprep(setupFileFullDir, 'Setup', 'ControlConstraints');
                        
                        % Set as variables to pass out of function
                        setupDirs{1} = rraActuators; setupDirs{2} = rraTasks; setupDirs{3} = rraControlConstraints;
                        
                        % If you want to run RRA without having run IK before then we need
                        % to specify the IK output directory
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep]; % This may be different depending if you have analysis tag folder(e.g., IK)
                        IDoutputDir = [sessionName, filesep, 'inverseDynamics', filesep]; % This may be different depending if you have analysis tag folder(e.g., ID)
                        
                        % If directory doesn't exist then we run RRA
                        if ~exist(RRAoutputDir, 'dir') && exist(IKoutputDir, 'dir') && exist(IDoutputDir, 'dir')
                            [RRAoutputDir,RRAtrialsOutputDir,RRAOutputTrials] =...
                                ResidualReductionAnalysis(inputDir, modelNames, currentAnalysisID, IKoutputDir, IDoutputDir, setupFileFullDir, setupDirs);
                            
                        else
                            % Quest dialog for you to choose to re-run analysis (because directory exists so it has been run
                            % before)
                            reRunAnalysis = questdlg(sprintf('%s has already been run, do you want to run it again?',currentAnalysisID),...
                                'Re-run analysis?','Yes','No','Yes');
                            
                            if strncmp(reRunAnalysis, 'Yes', 3) && exist(IKoutputDir, 'dir') && exist(IDoutputDir, 'dir')% If choice is yes then we re-run
                                % Run RRA
                                [RRAoutputDir,RRAtrialsOutputDir,RRAOutputTrials] =...
                                    ResidualReductionAnalysis(inputDir, modelNames, currentAnalysisID, IKoutputDir, IDoutputDir, setupFileFullDir, setupDirs);
                                
                            end
                        end
                        
                    case 'Kinematics Analysis'
                        
                        % If you want to run KA without having run IK before then we need
                        % to specify the IK output directory
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep, analysisIDs{1}]; % Define it from list of all possible analyses
                        
                        setupFilesDir = dir([TemplatePath, 'KinematicsAnalysis', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier)).name;
                        setupFileFullDir = fullfile(TemplatePath, 'KinematicsAnalysis', setupFileName);
                        
                        % Run point kinematics or body kinematics to get position of
                        % some body
                        if ~exist([sessionName, filesep, 'kinematicsAnalysis', filesep, currentAnalysisID], 'dir') && exist(IKoutputDir, 'dir')
                            [KAoutputDir,KAtrialsOutputDir,KAProcessedTrials] = KinematicsAnalysis(inputDir, modelNames, IKoutputDir, currentAnalysisID, setupFileFullDir);
                        else
                            disp('Already processed KA for this condition')
                        end
                        
                    case 'Muscle Analysis'
                        
                        % If you want to run MA without having run IK before then we need
                        % to specify the IK output directory
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep, analysisIDs{1}]; % Define it from list of all possible analyses
                        
                        % Define setup dir
                        setupFilesDir = dir([TemplatePath, 'MuscleAnalysis', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier)).name;
                        setupFileFullDir = fullfile(TemplatePath, 'MuscleAnalysis', setupFileName);
                        
                        % If MA folder doesn't exist then we can run it
                        if ~exist([sessionName, filesep, 'muscleAnalysis', filesep, currentAnalysisID], 'dir') && exist(IKoutputDir, 'dir')
                            [MAoutputDir, MAtrialsOutputDir, MAprocessedTrials]=MuscleAnalysis(inputDir, modelNames, IKoutputDir, currentAnalysisID, setupFileFullDir);
                            %plotStorage(Xaxislabel) % Uncomment to plot
                        else
                            disp('Already processed MA for this condition')
                        end
                        
                    case 'Static Optimisation' % Don't need this because we can use CEINMS in static op mode
                        
                        % When run IK and ID before & want to process the same trials (of ID)
                        % [SOoutputDir,SOtrialsOutputDir, SOprocessedTrials]=StaticOptimization(inputDir, modelNames, IKoutputDir, IDoutputDir, IDprocessedTrials);
                        % plotStorage(Xaxislabel) % Uncomment to plot
                        
                    case 'CEINMS'
                        
                        % Run CEINMS calibration and execution, and save results to
                        % structure
                        subjectName = subjectNames{nS};
                        
                        % Need to make this so only on the final loop
                        % through session folders we actually run ceinms
                        % calibration and execution, otherwise we just
                        % generate trials xml
                        
                        batch_CEINMS(subjectName, sessionName, sessionFolders, sD,...
                            modelNames.model_full_path{1}, acquisitionInfo);
                        
                    case 'Joint Reaction Analysis'
                        % We need to have:
                        % 1) Muscle forces file (from CEINMS or Static Optimisation)
                        % 2) External loads file from Inverse Dynamics (This is file
                        % containing link to grf.mot file and how GRFs are mapped)
                        % 3) Subject model file
                        % 4)Inverse kinematics results file
                        
                        % Define output dir
                        JRAoutputDir = [sessionName, filesep, 'jointReactionAnalysis', filesep, currentAnalysisID];
                        
                        % Define setup dirs - there are four files for RRA
                        setupFilesDir = dir([TemplatePath, 'JCFProcessing', filesep '*.xml']);
                        setupFileName = setupFilesDir(contains({setupFilesDir(:).name}, setupFileIdentifier{1}) &...
                            contains({setupFilesDir(:).name}, 'Setup_')).name;
                        setupFileFullDir = fullfile(TemplatePath, 'JCFProcessing', setupFileName);
                        jraActuators = regexprep(setupFileFullDir, 'Setup', 'Actuators');
                        
                        % If you want to run JRA without having run IK before then we need
                        % to specify the IK and ID output directories
                        IKoutputDir = [sessionName, filesep, 'inverseKinematics', filesep]; % This may be different depending if you have analysis tag folder(e.g., IK)
                        IDoutputDir = [sessionName, filesep, 'inverseDynamics', filesep]; % This may be different depending if you have analysis tag folder(e.g., ID)
                        CEINMSoutputDir = [sessionName, filesep, 'ceinms', filesep 'executionLowerLimb', filesep, 'Results']; % CEINMS results path from second execution
                        
                        % If directory doesn't exist then we run JRA
                        if ~exist(JRAoutputDir, 'dir') && exist(IKoutputDir, 'dir') && exist(IDoutputDir, 'dir')
                            [JRAoutputDir,JRAtrialsOutputDir,JRAOutputTrials] =...
                                JointContactAnalysis(inputDir, modelNames, currentAnalysisID, IKoutputDir, IDoutputDir, setupFileFullDir, jraActuators);
                            
                        else
                            % Quest dialog for you to choose to re-run analysis (because directory exists so it has been run
                            % before)
                            reRunAnalysis = questdlg(sprintf('%s has already been run, do you want to run it again?',currentAnalysisID),...
                                'Re-run analysis?','Yes','No','Yes');
                            
                            if strncmp(reRunAnalysis, 'Yes', 3) && exist(IKoutputDir, 'dir') && exist(IDoutputDir, 'dir')% If choice is yes then we re-run
                                % Run JRA
                                [JRAoutputDir,JRAtrialsOutputDir,JRAOutputTrials] =...
                                    JointContactAnalysis(inputDir, modelNames, currentAnalysisID, IKoutputDir, IDoutputDir, CEINMSoutputDir, setupFileFullDir, jraActuators);
                                
                            end
                        end
                        
                    otherwise
                        fprintf('There is no pre-defined analysis method for: %s', currentAnalysis)
                end
            end
        end
    else % Skip participant
        disp(['Subject ', nS, 'has bad data so skipping']);
    end
end