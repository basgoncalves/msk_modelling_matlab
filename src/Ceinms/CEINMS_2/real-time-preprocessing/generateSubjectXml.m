%__________________________________________________________________________
% Author: Claudio Pizzolato, August 2014
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
function outputXmlFilename = generateSubjectXml(osimModelFilename, dofList, baseDir,subjects,sessions)
    
    
% % Load info
% baseDir = 'C:\Users\s5012409\Documents\CEINMS';
% subjects = 'FAS-321';
% session = 'Session_1';
% osimModelPath = 'staticElaborations\StaticCalibration\Static';
% osimModelName = 'FAS-321_FAI_linearScaled.osim';
% osimModelFilename = [baseDir '\' subjects '\' session '\' osimModelPath '\' osimModelName ];
% 
% dofList = {'hip_flexion_r', 'knee_flexion_r', 'ankle_angle_r'};


    import org.opensim.modeling.*
    
    addpath('shared');
    addpath('xml_io_tools');
    
    fp = getFp();
    templateDir = ['template' fp 'subjects'];
    subjectXmlTemplateFilename = [templateDir fp 'subjectTemplate.xml'];

    outputDir = [baseDir fp 'ceinms' fp 'uncalibrated'];
    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir)
    end
    
    dofToMuscles = containers.Map();
    osimModel = Model(osimModelFilename);

    for i=1:length(dofList)
        currentDofName = dofList{i}; 
        dofToMuscles(currentDofName) = getMusclesOnDof(currentDofName, osimModel); 
    end

    allMuscles = dofToMuscles.values;
    i = 1:length(allMuscles);
    allMuscles = unique(sort([allMuscles{i}]));

    prefXmlRead.Str2Num = 'never';
    tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);
    for iMuscle=1:length(allMuscles)
       currentMuscleName = allMuscles{iMuscle};
       osimMuscle = osimModel.getMuscles().get(currentMuscleName);
       tree.mtuSet.mtu(iMuscle).name = currentMuscleName;
       tree.mtuSet.mtu(iMuscle).c1 =  -0.5;
       tree.mtuSet.mtu(iMuscle).c2 =  -0.5;
       tree.mtuSet.mtu(iMuscle).shapeFactor = 0.1;
       tree.mtuSet.mtu(iMuscle).optimalFibreLength =  osimMuscle.getOptimalFiberLength();
       tree.mtuSet.mtu(iMuscle).pennationAngle = osimMuscle.getPennationAngleAtOptimalFiberLength();
       tree.mtuSet.mtu(iMuscle).tendonSlackLength = osimMuscle.getTendonSlackLength();
       tree.mtuSet.mtu(iMuscle).maxIsometricForce = osimMuscle.getMaxIsometricForce();
       tree.mtuSet.mtu(iMuscle).strengthCoefficient = 1.5; 
    end

    for iDof=1:length(dofList)
        dof = dofList{iDof};
        tree.dofSet.dof(iDof).name = dof;
        muscles = dofToMuscles(dof);
        muscleList = muscles{1};
        for j = 2:length(muscles)
            muscleList = [muscleList, ' ', muscles{j}];
        end
        tree.dofSet.dof(iDof).mtuNameSet = muscleList;
    end
    tree.calibrationInfo.uncalibrated.subjectID = osimModel.getName();
    tree.calibrationInfo.uncalibrated.additionalInfo = 'TendonSlackLength and OptimalFibreLength scaled with Winby-Modenese';
    prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
    prefXmlWrite.CellItem   = false;
    outputXmlFilename = [outputDir fp 'uncalibrated.xml'];
    xml_write(outputXmlFilename, tree, 'subject', prefXmlWrite);
end