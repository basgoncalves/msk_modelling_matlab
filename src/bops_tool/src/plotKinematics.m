function plotKinematics(sessionName, model_file, IKoutputDir, session_name, sD)
%Plot multiple moments from the .sto files generated from OpenSim's ID
%analysis
%   Input model file directory and session name directory to generate individual
%   joint moment figures of the DOFs of interest (e.g., hip flexion).
%   Multiple trials can be plotted on the same figure for each DOF


if nargin < 3
    % Folder where the IK Results files are stored
     IKoutputDir = uigetdir(sessionName, 'Select folder with INVERSE KINEMATICS results to use');
end


% Generate list of trials
trials=dir(IKoutputDir);
j=1;
for k = 3:length(trials)
     trialsList{j}=trials(k).name;
     j = j + 1;
end
trialsList(ismember(trialsList,{'Figures','IDMetrics.mat', 'out.log', 'error.log', 'AnalysedData'}))=[];

% % Be selective if you want to
% [trialsIndex,~] = listdlg('PromptString','Select trials to plot:',...
%      'SelectionMode','multiple',...
%      'ListString',trialsList);
% 
% inputTrials=trialsList(trialsIndex);

inputTrials=trialsList;

% Define subject weight for normalisation
% Folder containing acquisition xml
acquisitionFolder = [regexprep(sessionName, 'ElaboratedData', 'InputData'), filesep];
acquisitionInfo=xml_read(fullfile(acquisitionFolder, 'acquisition.xml'));
subject_weight = acquisitionInfo.Subject.Weight;
subject_name = acquisitionInfo.Subject.Code;

% Plot multiple trials
IKfilename='FBM_ik.mot';

% Automatic selection of DOFs 
dofsToPlot = {'hip_flexion_r'; 'hip_adduction_r'; 'hip_rotation_r'; 'knee_angle_r';...
     'ankle_angle_r'; 'hip_flexion_l'; 'hip_adduction_l'; 'hip_rotation_l'; 'knee_angle_l';...
     'ankle_angle_l'};

% UNCOMMENT THIS TO MANUALLY SELECT WHICH DOFS TO PLOT
% dofs=getDofsFromModel(model_file);
% [selectedDofsIndex,v] = listdlg('PromptString','Select dofs for plots:',...
%      'SelectionMode','multiple',...
%      'ListString',dofs);
% % Assign dofs to plot
% dofsToPlot=dofs(selectedDofsIndex)';

% Assign x-axis label
xaxislabel = '% Gait Cycle';

% Directory to eventually save all the data
elabDataFolder = sessionName(1:end-10);

% Plot multiple results on a figure per DOF
% The angles plotted from OpenSim are the inverse of what is typically
% seen, you can choose to invert the results if desired.
plotResultsMultipleTrials_apm(IKoutputDir, elabDataFolder, inputTrials, IKfilename, xaxislabel, dofsToPlot, subject_weight, subject_name, session_name, sD)


