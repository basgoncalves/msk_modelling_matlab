% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% batch write calibration XML 
% run batchWriteCeinmsTrialAndContactModelXml and OSIMtoXML
%       calibration require trials XMLs and uncalibrated.xml
% CHECK calibration templates, modify to your naming convention as required
% Todo:

%% Load subject data

if exist('subjectInfo','var')
    doNotAutoLoadSubjectInfo='true';
else
    doNotAutoLoadSubjectInfo='false';
end
%%
prefCal.NMSmodelType   = 'openLoop'; %'hybrid'
prefCal.tendonType     = 'equilibriumElastic'; %'stiff' 'integrationElastic'
prefCal.activationType = 'exponential'; %'piecewise'
prefSetupCal.contact   = 'none'; %'knee'; %'OpenSim'

if strcmp(prefSetupCal.contact, 'knee')
    prefSetupCal.contactModelFile = 'contactKneeModel.xml';
    prefCal.objectiveFunction     = 'torqueErrorAndSumKneeContactForces';
elseif strcmp(prefSetupCal.contact, 'OpenSim')
    prefSetupCal.contactModelFile = 'contactOpenSimModel.xml';
end

createDir(dirCalSubj);
createDir(dirExcitationGen);

if exist([dirExcitationGen excitationFileName], 'file')~=2 %copy excitation generator if doesn't exist
    copyfile(['./Templates/' excitationFileName], dirExcitationGen);
end

generateTrialsXml_EM_os42(dirElabDynamic, dirMuscleAnalysis, dirID, idCEINMS, DeepHipMuscles, trialListEx);

for i = 1:length(trialListCal)
    trialSet = ['..\trials\' trialListCal{i} '.xml'];
end

jointsForCalibration=['hip_flexion_' LegMeasured ' hip_adduction_' LegMeasured ' knee_angle_' LegMeasured ' ankle_angle_' LegMeasured];
calFile = ['calibrationFile' upper(LegMeasured) '.xml'];
dirCalFileOut=[dirCalSubj calFile];

writeCalibrationFileXml(templateCalXML, trialSet, jointsForCalibration, dirCalFileOut, prefCal)

%Setup Calibration file, using relative paths; can use hard as well, but need to change the following in XML

exGenerator=['../excitationGenerators/' excitationFileName];
fileSetupCalOut = [dirCalSubj calSetupFile];

writeSetupCalibrationFileXml(templateSetupCalXML, unCalSubFile, exGenerator, calFile, outCalSubFile, fileSetupCalOut, prefSetupCal);

if strcmp(prefSetupCal.contact, 'knee')
    fileCalContactOut = [dirCalSubj prefSetupCal.contactModelFile];
    intercondyleDistance = getIntercondyleDistance(modelFileFullPath, OpenSimSide); %uses OpenSim API
    writeContactKneeModelXml(intercondyleDistance, OpenSimSide{s}, fileCalContactOut);
elseif strcmp(prefSetupCal.contact, 'OpenSim') %this is not implemented in Calibration ATM
    fileCalContactOut = [dirCalSubj prefSetupCal.contactModelFile];
    writeContactOpenSimModelXml(osimModelFilename, motion, externalLoads, joints, fileCalContactOut);
end
