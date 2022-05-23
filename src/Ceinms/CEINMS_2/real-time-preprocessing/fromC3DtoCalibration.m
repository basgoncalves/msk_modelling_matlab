function output = fromC3DtoCalibration(subject)

if length(subject.c3dDir) < 1
    subject.c3dDir = uigetdir('', 'Select your C3D folder');    
end
         
addpath('shared')
fp = getFp();
%C3D2Mat
baseDir = runC3DtoMat(subject.c3dDir);

%acquisition xml
generateRapidAcquisitionFile(c3dDir);

%elaboration xml
trialsPath = generateRapidElaborationFile(c3dDir);

%select scaled osim model
[osimModelName, osimModelPath] = uigetfile([baseDir fp '*.osim'], 'Select the scaled OpenSim Model');
osimModel = [osimModelPath fp osimModelName];
%IK and ID from BOPS
bopsPath = getBopsPath();
cwd = pwd;
cd(bopsPath);
[IKoutputDir,IKtrialsOutputDir,inputTrials] = InverseKinematics(char(trialsPath), osimModel);
InverseDynamics(char(trialsPath), osimModel, IKoutputDir, inputTrials)
MuscleAnalysis(char(trialsPath), osimModel, IKoutputDir, inputTrials)
cd(cwd);

ind=strfind(IKoutputDir, [fp 'inverseKinematics']);
defaultDir = [IKoutputDir(1:ind) fp 'dynamicElaborations'];
generateCalibrationFiles( osimModel, defaultDir);

end