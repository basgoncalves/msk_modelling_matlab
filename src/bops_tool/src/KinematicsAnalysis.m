function [KAoutputDir,KAtrialsOutputDir,inputTrials] = KinematicsAnalysis(inputDir, model_file, IKoutputDir, KAid, KATemplateXml, trialsList)
% Set and run kinematics analysis for multiple trials

%% Setting KA

switch nargin
        
    case 5 %IK before, but KA on different trials (for which it has been performed IK)
        
        trialsList = trialsListGeneration(IKoutputDir);
        inputTrials = KAinput(trialsList);
        IKmotDir=IKoutputDir;
        
    case 6 %IK before and ID on the same trials
        
        IKmotDir=IKoutputDir;
        inputTrials=trialsList;     
end


%% Running KA

[KAoutputDir, KAtrialsOutputDir]=runKinematicsAnalysis(inputDir,inputTrials, model_file, IKmotDir, KAid, KATemplateXml);