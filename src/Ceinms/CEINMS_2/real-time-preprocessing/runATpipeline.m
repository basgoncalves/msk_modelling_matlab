%% Define subjects parameters that are not in Acquisition XML
subjects{1}.ID = 'A07-Tend107';
subjects{1}.height = 1.9;
subjects{1}.weigth = 100;
subjects{1}.achillesMomentArmAtZero = 51.7331/1000.;
subjects{1}.basedir = 'C:\Data\ARCLP\AchillesTendon-GriffithAIS\Processing\ElaboratedData\A07-Tend107\20180316\';
subjects{1}.scaledOsimModel = [subjects{1}.basedir  'scaling\A07scaled.osim'];
subjects{1}.templateOsimModel = "C:\Data\ARCLP\AchillesTendon-GriffithAIS\Processing\FilesforProcessing\OpensimModel\gait2392_simbody.osim";
subjects{1}.trialPath = [subjects{1}.basedir 'dynamicElaborations\03\'];

baseDir = 'C:\Data\ARCLP\AchillesTendon-GriffithAIS\Processing';
%select scaled osim model
addpath('shared')
fp = getFp();

%% Processing
for i = 1: length(subjects)
    subject = subjects{i};    
    tunedOsimModel = tuneAchillesTendonMomentArm(subject.scaledOsimModel, subject.achillesMomentArmAtZero, subject.basedir);
    %Hansdfiels scaling should go here
    
    % IK, ID, and MA using BOPS
    bopsPath = getBopsPath();
    cwd = pwd;
    cd(bopsPath);
    p = load([subjects{1}.trialPath '\parameters.mat']);
    [IKoutputDir,IKtrialsOutputDir,inputTrials] = InverseKinematics(subjects{1}.trialPath, tunedOsimModel);
    InverseDynamics(subjects{1}.trialPath, tunedOsimModel, IKoutputDir, inputTrials, p.parameters);
    MuscleAnalysis(subjects{1}.trialPath, tunedOsimModel, IKoutputDir, inputTrials);
    cd(cwd);

    % CEINMS setup
    %ind=strfind(IKoutputDir, [fp 'inverseKinematics']);
    %defaultDir = [IKoutputDir(1:ind) fp 'dynamicElaborations'];
    %generateCalibrationFiles(subject.templateOsimModel, tunedOsimModel, defaultDir, subject);
    

end
    

