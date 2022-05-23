function [ outputXmlFilename ] = generateCalibrationSetup_BG(Dir,CEINMSSettings)

addpath('shared');
addpath('xml_io_tools');
fp = filesep;
if exist(Dir.CEINMScalibration, 'dir') ~= 7
    mkdir(Dir.CEINMScalibration)
end

outputFolder = Dir.CEINMScalibration ;
ceinmsCalibration.subjectFile = relativepath(CEINMSSettings.subjectFilename,outputFolder);
ceinmsCalibration.excitationGeneratorFile = relativepath(CEINMSSettings.excitationGeneratorFilename,outputFolder);
ceinmsCalibration.calibrationFile = relativepath(CEINMSSettings.calibrationCfg,outputFolder);
ceinmsCalibration.outputSubjectFile = relativepath(CEINMSSettings.outputSubjectFilename,outputFolder);

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;

xml_write(CEINMSSettings.calibrationSetup, ceinmsCalibration, 'ceinmsCalibration', prefXmlWrite);

disp('Calibration setup xml generated')