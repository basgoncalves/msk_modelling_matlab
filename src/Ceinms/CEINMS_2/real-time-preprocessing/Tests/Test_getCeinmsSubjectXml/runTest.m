cwd = pwd;
osimModelFilename = [cwd '/Data/GU_lowlimb.osim'];
dofList = {'hip_flexion_l', 'knee_flexion_l', 'ankle_angle_l'};
outputDir = [cwd '/Output'];
cd('../../');
getCeinmsSubjectXml(osimModelFilename, dofList, outputDir)
cd(cwd)