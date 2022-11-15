function [sessionName, modelNames, trialsFolders, acquisitionInfo, inputDir, coordinates] =...
    subjectSetup(fName, sessionFolder, subjectName, genericPathToModel, diffTrialsFlag, appendName) 
%Create files and directories necessary to process data through BOPS pipeline for the
%subject
% Based on subject information, extract list of model names to use, trial
% parameters, directory containing input data, and model coordinates to plot

% Input - 'fName' - Name of path to elaborated data folder     
%         'sessionFolder' - Name of session 
%         'subjectName' - Name of subject
%         'genericPathToModel' - Name of path to model within your session folder
%         'diffTrialsFlag' - Flag indicating whether you will use the same model for all
%         trials (1) or have different model names in your trials (0);
%         'appendName' - String appended to end of your model name) 

if contains(sessionFolder, 'oneSession')
    sessionName = fName;
    % Define input directory
    inputDir = [fName, filesep,...
        'dynamicElaborations'];
else
    sessionName = [fName, filesep, sessionFolder];
    inputDir = [fName, filesep, sessionFolder, filesep,...
        'dynamicElaborations'];
end

% Get acqusition information - uncomment below line to get acquisition.xml
% from inputData folder within the session
% acquisitionFolder = [regexprep(sessionName, 'ElaboratedData', 'InputData'), filesep];
acquisitionFolder = fName;
try
    acquisitionInfo=xml_read(fullfile(acquisitionFolder, 'acquisition.xml'));
    % Get subject information
    subjectInfo = fieldnames(acquisitionInfo.Subject);
    
    % If test leg has not yet been defined then we need to know
    tlIndex = contains(subjectInfo, {'Leg', 'leg', 'limb'});
    % If it has been defined then we can extract it from Subject information
    if any(tlIndex)
        testLeg = acquisitionInfo.Subject.(subjectInfo{tlIndex});
    else % Otherwise you can choose which leg
        testLeg = questdlg('Which leg was instrumented?','Instrumented leg','Both','Right','Left','Right');
        acquisitionInfo.Subject.instrumentedLeg = testLeg;
    end
catch
    fprintf('Could not locate acquisition.xml file for subject, please check directory:\n %s\n',...
        acquisitionFolder)
    testLeg = questdlg('Which leg was instrumented?','Instrumented leg','Both','Right','Left','Right');
    acquisitionInfo.Subject.limbOfInterest = testLeg;
    % Save acquisition xml to elaborated data folder
    xml_write(fullfile(fName, 'acquisition.xml'), acquisitionInfo);
end

% Create var for trials names based on trials analysed in ID
trialsDirs = dir([sessionName, filesep, 'dynamicElaborations' filesep]);
isub=[trialsDirs(:).isdir];
trialsFolders={trialsDirs(isub).name}';
trialsFolders(ismember(trialsFolders,{'.','..', 'Static1', 'maxEmg', 'EMGs'}))=[]; % dynamic trials folders

% Initialise var to store model to use and full path to
% models
% model_files = cell(size(trialsFolders, 1), 2);

% Specify expression you want to use to split the trial name
% into parts
expressionToSplitOrJoin = '_'; % Underscore

% Loop through trials and determine which model to use based
% on condition name
for tF = 1:length(trialsFolders)
    
    % If you want to process different trials with different models
    % (e.g., if you collected multiple conditions in the same session)
    if diffTrialsFlag ~= 1
        
        % Get trial info - e.g., walk speed, condition name, load carried
        trialParams = extractTrialParametersFromConditionName(trialsFolders{tF}, expressionToSplitOrJoin);
        
        % Specify name of model for processing - this will change depending on
        % the condition name
        model_files{tF,1} = char(join({regexprep(subjectName, ' ', ''), trialParams.param1, appendName}, expressionToSplitOrJoin));
        
        % Specify full path to model - need to modify if your path to model files is different
        model_files{tF, 2} = fullfile(sessionName, genericPathToModel, model_files{tF, 1});
        
    else
        % Otherwise set only one model and one model file name for all trials
        % This thinks your model name is subjectName_final.osim (e.g.,
        % Subject1_final.osim)
         model_files{1,1} = char(join({regexprep(subjectName, ' ', ''), appendName}, expressionToSplitOrJoin));
%          model_files{1,2} = fullfile(sessionName, genericPathToModel, model_files{tF, 1});
         model_files{1,2} = fullfile(genericPathToModel, subjectName, model_files{tF, 1});
         break
    end
end

% Create table for choosing correct model
modelNames = cell2table(model_files, 'VariableNames', {'model_name', 'model_full_path'});

% Setup coordinates to plot
% Change coordinate based on subjects test leg - if the variable exists
if strcmp(testLeg, 'R')
    coordinates = {'hip_flexion_r', 'knee_angle_r', 'ankle_angle_r'};
elseif strcmp(testLeg, 'L')
    coordinates = {'hip_flexion_l', 'knee_angle_l', 'ankle_angle_l'};
else % If both legs were instrumented then just pick right leg
    coordinates = {'hip_flexion_r', 'knee_angle_r', 'ankle_angle_r'};
end

