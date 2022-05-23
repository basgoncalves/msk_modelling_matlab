%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%make sure calibration subject directories are in relative path
%-------------------------------------------------------------------------
%% EditCalibratedSubject
function CalibratedSubjectRelativePaths(CEINMSmodel,OpenSimModel)

fp = filesep;
DirCalibration = fileparts(CEINMSmodel);
SubjectXML = xml_read (CEINMSmodel);
if ~contains(CEINMSmodel,'uncalibrated')
    % startSubjectFile
    OldString = SubjectXML.calibrationInfo.calibrated.startSubjectFile;
    if ~contains(OldString(1:2),'.\') && ~contains(OldString(1:3),'..\')
        NewStr = strrep(OldString,fileparts(OldString),DirCalibration);
        SubjectXML.calibrationInfo.calibrated.startSubjectFile = relativepath(NewStr,DirCalibration);
    end
    
    % calibrationSequence
    OldString = SubjectXML.calibrationInfo.calibrated.calibrationSequence;
    if ~contains(OldString(1:2),'.\') && ~contains(OldString(1:3),'..\')
        NewStr = strrep(OldString,fileparts(OldString),DirCalibration);
        SubjectXML.calibrationInfo.calibrated.calibrationSequence = relativepath(NewStr,DirCalibration);
    end
end
% contactModelFile
OldString = SubjectXML.contactModelFile;
if ~contains(OldString(1:2),'.\') && ~contains(OldString(1:3),'..\')
    NewStr = strrep(OldString,fileparts(OldString),DirCalibration);
    SubjectXML.contactModelFile = relativepath(NewStr,DirCalibration);
end

%opensimModelFile
OldString = SubjectXML.opensimModelFile;
if ~contains(OldString(1:2),'.\') && ~contains(OldString(1:3),'..\')
    SubjectXML.opensimModelFile = relativepath(OpenSimModel,DirCalibration);
end

%conver the curve data to strings
for k = 1:length({SubjectXML.mtuDefault.curve.xPoints})
    SubjectXML.mtuDefault.curve(k).xPoints = num2str(SubjectXML.mtuDefault.curve(k).xPoints);
    SubjectXML.mtuDefault.curve(k).yPoints = num2str(SubjectXML.mtuDefault.curve(k).yPoints);
end
for k = 1:length({SubjectXML.mtuSet.mtu.name})
    if isfield(SubjectXML.mtuSet.mtu(k),'curve') && ~isempty(SubjectXML.mtuSet.mtu(k).curve)
        SubjectXML.mtuSet.mtu(k).curve.xPoints = num2str(SubjectXML.mtuSet.mtu(k).curve.xPoints);
        SubjectXML.mtuSet.mtu(k).curve.yPoints = num2str(SubjectXML.mtuSet.mtu(k).curve.yPoints);
    end
end

prefXmlWrite.StructItem = false; prefXmlWrite.CellItem = false; % allow arrays of structs to use 'item' notation
xml_write(CEINMSmodel, SubjectXML, 'subject', prefXmlWrite);% save model

cmdmsg(['Subject calibration directories converted to relative path '])
disp(CEINMSmodel)
