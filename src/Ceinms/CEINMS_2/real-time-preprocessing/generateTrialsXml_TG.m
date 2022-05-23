% RRAitr = iteration number of RRA

function [outputTrialList, defaultDir, outDir] = ...
    generateTrialsXml_TG(inputDir,maInputDir,idInputDir)
    addpath('shared');
    addpath('xml_io_tools');
    fp = getFp();
    
    %% input dir
    if nargin < 1
    inputDir = uigetdir('', 'Select your trials folder');
    end
    
    ind=strfind(inputDir, [fp 'dynamicElaborations']);
    defaultDir = inputDir(1:ind);
    elaborationInd = strfind( fliplr(inputDir), fp);
    elaborationId = inputDir(end-elaborationInd+2:end);
    
    %ikInputDir = uigetdir([defaultDir '\inverseKinematics'], 'Select your IK folder');
    if nargin < 2
    maInputDir = uigetdir(join([defaultDir fp 'muscleAnalysis' fp elaborationId], ''), 'Select your MA folder');
    end
    
    if nargin < 3
    idInputDir = uigetdir(join([defaultDir fp 'inverseDynamics' fp elaborationId],''), 'Select your ID folder');
    end
    
    
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
    NewList = {};
    for trialIdx=1:length(trialList)
        currentTrial = char(trialList(trialIdx));
        emgDir = [inputDir fp currentTrial];
        emgFile = getFile(emgDir, 'emg');
        lmtMaDir = [maInputDir fp currentTrial];
        
        if exist([lmtMaDir fp '_MuscleAnalysis_FiberForce.sto'])
            lmtFile = getFile(lmtMaDir, '_Length');
            maData = getMomentArmsFiles(lmtMaDir, '_MomentArm_');
            extTorqueDir = [idInputDir fp currentTrial];
        else
            continue
        end
        
    
        extTorqueFile = getFile(extTorqueDir, 'inverse_dynamics');
       
        trialFilename = [outDir fp currentTrial '.xml'];
        writeTrial(trialFilename, lmtFile, emgFile, maData, extTorqueFile );
        outputTrialList{trialIdx} = trialFilename;
        
    end
    
end

