function [RRAoutputDir,RRAtrialsOutputDir,inputTrials] = ResidualReductionAnalysis(inputDir, model_file, RRAid, IKoutputDir, IDoutputDir, RRATemplateXml, setupDirs, trialsList)
% Set and run residual reduction analysis for multiple trials

%% Setting RRA

switch nargin
        
    case 7 %IK and ID before, but RRA on different trials (for which IK has been performed)
        
        trialsList = trialsListGeneration(IKoutputDir);
        inputTrials = RRAinput(trialsList);
        IKmotDir=IKoutputDir;
        
    case 8 %IK and ID before and RRA on the same trials
       
        IKmotDir=IKoutputDir;
        inputTrials=trialsList;    
end

%% Running RRA
[RRAoutputDir, RRAtrialsOutputDir]=runResidualReductionAnalysis(inputDir,inputTrials, model_file, IKmotDir, IDoutputDir, RRAid, RRATemplateXml, setupDirs);