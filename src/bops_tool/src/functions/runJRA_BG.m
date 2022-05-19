% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% Function to run joint contact analysis for a single trial
function [outputDir]=runJRA_BG(osimModel, coordinates_file, externalLoads_file, muscleForcesRelFileName, joint_names, results_directory, JCFTemplateXml)

fp = filesep;
% Save the settings in the Setup folder
% setupFileDir=[results_directory '\Setup'];
if exist(results_directory,'dir')~=7; mkdir (results_directory); end
cd(results_directory)
[~,trialName] = fileparts(results_directory);
motData = importdata(coordinates_file);% Get mot data to determine time range
initial_time = motData.data(1,1); final_time = motData.data(end,1); % Get initial and final time


setupFile=[results_directory fp 'setup_JCF.xml']; copyfile(JCFTemplateXml,setupFile) %Print JCF setup file

XML = xml_read(setupFile);
XML.AnalyzeTool.COMMENT = {};
XML.AnalyzeTool.ATTRIBUTE.name='JCF'; % make this so names of the results are consistent across trilas (they are already in different folders)
XML.AnalyzeTool.model_file = relativepath(osimModel,results_directory);
XML.AnalyzeTool.initial_time = num2str(initial_time);
XML.AnalyzeTool.final_time = num2str(final_time);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(initial_time);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(final_time);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.step_interval = 1;
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.in_degrees = 'true';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.forces_file = relativepath(muscleForcesRelFileName,results_directory);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.joint_names = joint_names;
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.apply_on_bodies = 'parent';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.express_in_frame = 'parent';
XML.AnalyzeTool.results_directory = relativepath(results_directory,results_directory);
XML.AnalyzeTool.external_loads_file = relativepath(externalLoads_file,results_directory);
XML.AnalyzeTool.coordinates_file = relativepath(coordinates_file,results_directory);

prefXmlWrite.Str2Num = 'never'; prefXmlWrite.StructItem = false; prefXmlWrite.CellItem = false;
xml_write(setupFile, XML, 'OpenSimDocument',prefXmlWrite);

logFileOut=[results_directory '\out.log'];% Save the log file in a Log folder for each trial

%Run JCF
cd(results_directory)
outputDir = [results_directory fp 'JCF_JointReaction_ReactionLoads.sto'];
dos(['analyze -S ' setupFile ' > ' logFileOut]);

