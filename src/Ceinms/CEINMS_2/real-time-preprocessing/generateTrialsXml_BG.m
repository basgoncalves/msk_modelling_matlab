% RRAitr = iteration number of RRA
% PrintXML = 1(default,yes) or 0(no)
function outputTrialList = generateTrialsXml_BG(Dir,CEINMSSettings,trialList,PrintXML)
addpath('shared');
addpath('xml_io_tools');
fp = getFp();
%% select only the trials that have been completely processed
mkdir(Dir.CEINMStrials); %outputDir
outputTrialList ={};
disp('Generating Trial XML files ...')
for trialIdx=1:length(trialList)
    currentTrial = char(trialList(trialIdx));
    
    trialFilename = [Dir.CEINMStrials fp currentTrial '.xml'];
    lmtMaDir = [Dir.MA fp currentTrial];
    
    if exist([lmtMaDir fp '_MuscleAnalysis_FiberForce.sto'])
        outputTrialList{end+1} = trialFilename;
        disp (['Generating ' currentTrial])
        lmtFile = relativepath(getFile(lmtMaDir, '_Length'),Dir.CEINMStrials);
        maData = getMomentArmsFiles(lmtMaDir, '_MomentArm_' ,Dir.CEINMStrials);
        emgFile = relativepath(getFile([Dir.dynamicElaborations fp currentTrial], 'emg'),Dir.CEINMStrials);
        
        if contains(CEINMSSettings.osimModelFilename,'_rra_')  
            extTorqueFile = relativepath(getFile([Dir.ID fp currentTrial], 'inverse_dynamics_RRA'),Dir.CEINMStrials);
        else
            extTorqueFile = relativepath(getFile([Dir.ID fp currentTrial], 'inverse_dynamics'),Dir.CEINMStrials);
        end
        motionFile = relativepath(getFile([Dir.IK fp currentTrial], 'IK.mot'),Dir.CEINMStrials);
        externalLoadsFile = relativepath(getFile([Dir.ID fp currentTrial], 'grf.xml'),Dir.CEINMStrials);
        XML = xml_read(getFile([Dir.IK fp currentTrial], 'setup_IK'));
        TimeWindow = XML.InverseKinematicsTool.time_range;
        %         TimeWindow(2) = TimeWindow(2) + 0.02;
        
        if ~exist('PrintXML') || PrintXML==1
            writeTrial(trialFilename, lmtFile, emgFile, maData, extTorqueFile, motionFile,externalLoadsFile,TimeWindow);
        end       
    end
end

 disp('Trial XML files generated')


