
function [modelNames_RRA,RRAoutputDir,RRAtrialsOutputDir,RRAOutputTrials_2,IKoutputDir_RRA] = ...
    ReRunRRA (inputDir, modelNames, RRAoutputDir, IDoutputDir, setupFileFullDir, setupDirs, RRAtrialsOutputDir)
                           
fp = filesep;
modelNames_RRA = modelNames;
modelNames_RRA.model_full_path{1} = strrep(modelNames_RRA.model_full_path{1},'FAI.osim', 'RRA_AvgMass.osim');
modelNames_RRA.model_name{1} = strrep(modelNames_RRA.model_name{1},'FAI.osim', 'RRA_AvgMass.osim');

IKoutputDir_RRA = fileparts(RRAoutputDir);
n = length(dir(fileparts(IKoutputDir_RRA)))-2;
currentAnalysisID = ['RRA_' num2str(n)];

% create a copy of the Kinematics_q.sto into Kinematics_q.mot for all files
for k = 1: length(RRAtrialsOutputDir)
    files = dir([RRAtrialsOutputDir{k} fp '*.sto']);
    IKfile = files(contains({files.name},'Kinematics_q.sto'));
    newName = strrep(IKfile.name,'.sto','.mot');
    copyfile([IKfile.folder fp IKfile.name],[IKfile.folder fp newName])
end

 [RRAoutputDir,RRAtrialsOutputDir,RRAOutputTrials] =...
   ResidualReductionAnalysis(inputDir, modelNames_RRA, currentAnalysisID, IKoutputDir_RRA, IDoutputDir, setupFileFullDir, setupDirs);
                                