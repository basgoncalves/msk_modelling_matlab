
function UpdatdeSecondCalibrationCfgSetup(Dir,CEINMSSettings)

fp = filesep;
%% create a copy of the first calibrated subject files
BackupDir = [Dir.CEINMScalibration fp 'firstCalibrationFiles'];
if exist(BackupDir)
    n = num2str(sum(contains(cellstr(ls(Dir.CEINMScalibration)),BackupDir))+1);
    BackupDir = [BackupDir '_' n];
end
mkdir(BackupDir);
FirstCalFiles = dir(Dir.CEINMScalibration);
for f = 3:length(FirstCalFiles)
    if FirstCalFiles(f).isdir==0
        copyfile([FirstCalFiles(f).folder fp FirstCalFiles(f).name],BackupDir)
    end
end

%% new calibration cfg file
prefDef.NMSmodelType='openLoop'; %'hybrid' - not sure if this is in Calibration
prefDef.tendonType= 'equilibriumElastic'; %'stiff' 'integrationElastic'
prefDef.activationType='exponential'; %'piecewise'
prefDef.parameterShareType = 'single'; %'global'
prefDef.objectiveFunction = 'torqueErrorNormalised'; %'torqueErrorAndSumKneeContactForces'
prefDef.legSide = 'none'; %'r' 'l' %for

%load
prefXmlRead.Str2Num = 'never';
prefXmlRead.NoCells=false;
XML = xml_read(CEINMSSettings.calibrationCfg,prefXmlRead);

% edit xml
XML.calibrationSteps.step.parameterSet.parameter{6}.absolute.range = '0.8 2';% range for strengthCoefficient
XML.calibrationSteps.step.dofs = CEINMSSettings.dofList;
XML.NMSmodel.type.(prefDef.NMSmodelType)= struct;      % xml_write will delete if empty matrix, so must be structure if wanting to keep
XML.NMSmodel.tendon.(prefDef.tendonType)= struct;
XML.NMSmodel.activation.(prefDef.activationType)= struct;

% do the same for all parameters except the strengthCoefficients
for k = 1:length(XML.calibrationSteps.step.parameterSet.parameter)-1
    XML.calibrationSteps.step.parameterSet.parameter{1,k}.single = struct;
end

if ~contains({XML.trialSet},'_2ndcal.xml')
    XML.trialSet = strrep(XML.trialSet,'.xml','_2ndcal.xml') ;
else
    warning on
    warning('current calibration cfg already contains "_2ndcal.xml", check your files you dumb c***!!')
end

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
xml_write(CEINMSSettings.calibrationCfg, XML,'calibration',prefXmlWrite);

%% new calibration setup file
XML = xml_read([CEINMSSettings.calibrationSetup]);
newExcGenFile = CEINMSSettings.excitationGeneratorFilename2ndCal;
XML.excitationGeneratorFile = relativepath(newExcGenFile,DirUp(CEINMSSettings.calibrationSetup,1));
xml_write(CEINMSSettings.calibrationSetup, XML,'ceinmsCalibration');

%% copy execution files to a new folder
FirstExeFiles = dir(Dir.CEINMSsimulations);
BackupDir =[FirstExeFiles(1).folder fp 'FirstExecution'];
if exist(BackupDir)
    n = num2str(sum(contains(cellstr(ls(Dir.CEINMSsimulations)),'FirstExecution'))+1);
    BackupDir = [BackupDir '_' n];
end
mkdir(BackupDir); cd(Dir.CEINMSexecution)
for f = 3:length(FirstExeFiles)
    if ~contains([FirstExeFiles(f).folder fp FirstExeFiles(f).name],BackupDir)
        movefile([FirstExeFiles(f).folder fp FirstExeFiles(f).name],[BackupDir fp FirstExeFiles(f).name])
    end
end

