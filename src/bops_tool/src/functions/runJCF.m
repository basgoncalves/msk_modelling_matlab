% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% Function to run joint contact analysis for a single trial
function []=runJCF(osimModel, coordinates_file, externalLoads_file, muscleForcesRelFileName, results_directory, lowpassfcut, JCFTemplateXml, EMG_OpenSim_side, varargin)
% tested with Opensim v3.2 32bit 64bit
matlabdir=pwd;
prefXmlRead.Str2Num = 'never';
prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem   = false;

[~, jointList] = getOsimBodyJointList(osimModel, {'R'});
joint_names = strjoin(jointList);

import org.opensim.modeling.*

analyzeTool = AnalyzeTool(JCFTemplateXml);
analyzeTool.setModel(osimModel);
modelFilenameFullPath=char(osimModel.getDocumentFileName);
indexFN=regexp(modelFilenameFullPath,'\');
modelFilenameRelPath=['..\..\..' modelFilenameFullPath(indexFN(end-2):end)];
% Save the settings in the Setup folder
% setupFileDir=[results_directory '\Setup'];
setupFileDir=results_directory;

if exist(setupFileDir,'dir') ~= 7
    mkdir (setupFileDir);
end
cd(setupFileDir)

%Set Input
analyzeTool.setCoordinatesFileName(coordinates_file);
analyzeTool.setLowpassCutoffFrequency(lowpassfcut);
% Get mot data to determine time range
motData = Storage(coordinates_file);

% Get initial and intial time
initial_time = motData.getFirstTime();
final_time = motData.getLastTime();
analyzeTool.setInitialTime(initial_time);
analyzeTool.setFinalTime(final_time);   
analyzeTool.setStartTime(initial_time);

analyzeTool.setExternalLoadsFileName(externalLoads_file);
%Set folders
analyzeTool.setResultsDir('.\');

%Print JCF setup file
setupFile = 'setup_JCF.xml';
setupFileFullName=[setupFileDir '\' setupFile];
analyzeTool.print(setupFileFullName);
%xml write to change muscleforces
JointReactionTree = xml_read(setupFileFullName,prefXmlRead);
JointReactionTree.AnalyzeTool.ATTRIBUTE.name='JCF';
JointReactionTree.AnalyzeTool.model_file=modelFilenameRelPath;
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(initial_time);
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(final_time);
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.step_interval = 1;
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.in_degrees = 'true';
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.forces_file = muscleForcesRelFileName;
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.joint_names = joint_names;
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.apply_on_bodies = 'child';
JointReactionTree.AnalyzeTool.AnalysisSet.objects.JointReaction.express_in_frame = 'child';
xml_write(setupFileFullName, JointReactionTree, 'OpenSimDocument',prefXmlWrite);

logFileOut=[setupFileDir '\out.log'];% Save the log file in a Log folder for each trial

%Run JCF
dos(['analyze -S ' setupFile ' > ' logFileOut]);
% analyzeTool = AnalyzeTool(setupFileFullName);
% tic;analyzeTool.run();toc %slightly faster (0.2 secs, prob due to writing log file in dos)

cd(matlabdir);

