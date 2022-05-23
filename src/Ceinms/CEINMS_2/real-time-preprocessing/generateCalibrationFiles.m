function [ calibrationSetupFilename ] = generateCalibrationFiles( baseOsimModelFilename, scaledOsimModelFilename, trialsDir, side, dofList)
%GENERATECALIBRATIONFILES Summary of this function goes here
%   Detailed explanation goes here
    
    addpath('shared')

    if nargin < 3
        trialsDir = '';
    end

    if nargin < 4
        choice = menu('Choose a side','left','right');
        side = 'right';
        if choice ==1
            side = 'left';
        end
    end
    if nargin < 5
        dofList = selectDofsFromOsimModel(scaledOsimModelFilename, 'Select dofs for subject Xml:');
    end
    
    % generate calibration trials
    % actualPath is the path we are going to use as start for relative path
    [outputTrialList, baseDir, ~] = generateTrialsXml(trialsDir);
    calibrationTrials = selectTrials(outputTrialList, 'Select Calibration Trials:');
    
    %generate calibration cfg
    calibrationCfg = generateCalibrationCfg(calibrationTrials, baseDir, side);
    
    osimModelFilename_unlocked = getUnlockedOsimModel(scaledOsimModelFilename);
    osimMorphoScaledFilename = getMorphoScaledModel(baseOsimModelFilename, scaledOsimModelFilename, baseDir);
   %osimMorphoScaledFilename = "C:\Data\ARCLP\AchillesTendon-GriffithAIS\Processing\ElaboratedData\A07-Tend107\20180316\scaling\3DGaitModel2392-AT07-scaled_optAT_unlocked_opt_N9.osim"
    %Create uncalibrated model
    uncalibratedSubject = generateSubjectXml(osimMorphoScaledFilename, dofList, baseDir);

    %get excitation generator
    excitationGeneratorFilename = getExcitationGenerator(baseDir, side);

    %generate contact model xml
    %intercondyleDistance = getIntercondyleDistance(osimModelFilename, side);
    %contactForcesXml = generateContactForcesXml(intercondyleDistance, side, baseDir);
    
    outputSubjectFilename = getOutputSubject(baseDir);
    
    %gemerate calibration setup
    calibrationSetupFilename = generateCalibrationSetup( ...
        uncalibratedSubject, ...
        excitationGeneratorFilename,...
        calibrationCfg, ...
        outputSubjectFilename, ...
        baseDir);
    
    %gemerate splines setup
    generateMcbsCfg(osimMorphoScaledFilename, uncalibratedSubject, 9, baseDir); 
    

end

