function [outputTrialList, defaultDir, outDir] = generateTrialsXml(trialsDir)
    addpath('shared');
    addpath('xml_io_tools');
    fp = getFp();
    
    if nargin < 1
        trialsDir = '';
    end
    %% input dir
    inputDir = uigetdir(trialsDir, 'Select your trials folder');
    
    ind=strfind(inputDir, [fp 'dynamicElaborations']);
    defaultDir = inputDir(1:ind-1);
    elaborationInd = strfind( fliplr(inputDir), fp);
    elaborationId = inputDir(end-elaborationInd+2:end);
    
    %ikInputDir = uigetdir([defaultDir '\inverseKinematics'], 'Select your IK folder');
    maInputDir = uigetdir(join([defaultDir fp 'muscleAnalysis' fp elaborationId], ''), 'Select your MA folder');
    idInputDir = uigetdir(join([defaultDir fp 'inverseDynamics' fp elaborationId],''), 'Select your ID folder');

    %%outputDir
    outDir = [defaultDir 'ceinms' fp 'trials'];
    if (exist(outDir,'dir') ~= 7)
        mkdir(outDir);
    end

    %% select only the trials that have been completely processed
    trialList = getDirNames(char(inputDir));
    %trialList = intersect(trialList,getDirNames(ikInputDir));
    trialList = intersect(trialList,getDirNames(maInputDir));
    trialList = intersect(trialList,getDirNames(idInputDir));

    for trialIdx=1:length(trialList)
       currentTrial = char(trialList(trialIdx));
       emgDir = [inputDir fp currentTrial];
       emgFile = getFile(emgDir, 'emg');
       lmtMaDir = [maInputDir fp currentTrial];
       lmtFile = getFile(lmtMaDir, '_Length');
       extTorqueDir = [idInputDir fp currentTrial];
       extTorqueFile = getFile(extTorqueDir, 'inverse_dynamics');  
       maData = getMomentArmsFiles(lmtMaDir, '_MomentArm_');
       trialFilename = [outDir fp currentTrial '.xml'];
       writeTrial(trialFilename, lmtFile, emgFile, maData, extTorqueFile );
       outputTrialList{trialIdx} = trialFilename;
    end
    
end

