cwd = pwd;
osimModelFilename = [cwd '/Data/GU_lowlimb.osim'];
dofList = {'hip_flexion_l', 'knee_flexion_l', 'ankle_angle_l'};
outputDir = [cwd '/Output'];
cd('../../');
ceinmsSubject = getCeinmsSubjectXml(osimModelFilename, dofList, outputDir);
[ nDofs, nMuscles, dofAnglesFilename, musclesFilename ] = generateMcbsCfg( osimModelFilename, ceinmsSubject, 8, outputDir );
cd(cwd)