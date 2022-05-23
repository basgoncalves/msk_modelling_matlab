function [ outputXmlFilename ] = generateCalibrationSetup( ...
    subjectFilename, ...
    excitationGeneratorFilename, ...
    calibrationFilename, ...
    outputSubjectFilename, ...
    baseDir)
%GENERATECALIBRATIONSETUP Summary of this function goes here
%   Detailed explanation goes here

    addpath('shared');
    addpath('xml_io_tools');

    useRelativePath = true;
    
    
    fp = getFp();
    if nargin < 5
        baseDir = '.';
    end
    
    if baseDir(end) ~= fp
        baseDir = [baseDir fp];
    end
    
    outputDir = [baseDir 'ceinms' fp 'calibration' fp 'setup'];
    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir)
    end
    
    

    if useRelativePath
       actualPath =  outputDir;
       
       [p,n,e] = fileparts(subjectFilename);
       subjectFilename = [relativepath(p, actualPath) fp n e];
       
       [p,n,e] = fileparts(excitationGeneratorFilename);
       excitationGeneratorFilename = [relativepath(p, actualPath) fp n e];
       
       [p,n,e] = fileparts(calibrationFilename);
       calibrationFilename = [relativepath(p, actualPath) fp n e];
       
       [p,n,e] = fileparts(outputSubjectFilename);
       outputSubjectFilename = [relativepath(p, actualPath) fp n e];
           
    end
    
    ceinmsCalibration.subjectFile = convertPathToLinux(subjectFilename);
    ceinmsCalibration.excitationGeneratorFile = convertPathToLinux(excitationGeneratorFilename);
    ceinmsCalibration.calibrationFile = convertPathToLinux(calibrationFilename);
    ceinmsCalibration.outputSubjectFile = convertPathToLinux(outputSubjectFilename);
    
    refXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
    prefXmlWrite.CellItem   = false;
    
    outputXmlFilename = [outputDir fp 'calibrationSetup.xml'];
    xml_write(outputXmlFilename, ceinmsCalibration, '', prefXmlWrite);

end

