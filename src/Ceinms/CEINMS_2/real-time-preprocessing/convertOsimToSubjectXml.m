%__________________________________________________________________________
% Author: Claudio Pizzolato, August 2014
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
% modified to a function by Hoa X. Hoang
function convertOsimToSubjectXml(subjectID,osimModelFilename,dofList,outputUnCalXmlFilename, subjectXmlTemplateFilename, pref)
%========default preferences==================================
prefDef.contact='none'; %'knee' 'OpenSim' - should provide contactModelFile and osimModelFilename
%prefDef.contactModelFile='contactKneeModel.xml';
prefDef.emDelay = 0.015;
prefDef.strengthCoefficient = 1;
if (nargin>5)
    if (isfield(pref, 'contact')), prefDef.contact=pref.contact; end
    if (isfield(pref, 'contactModelFile')), prefDef.contactModelFile=pref.contactModelFile; end
    if (isfield(pref, 'opensimModelFile')), prefDef.opensimModelFile=pref.opensimModelFile; end
    if (isfield(pref, 'emDelay')), prefDef.emDelay=pref.emDelay; end
    if (isfield(pref, 'strengthCoefficient')), prefDef.strengthCoefficient=pref.strengthCoefficient; end
end

import org.opensim.modeling.*

if ~exist('subjectXmlTemplateFilename','var')
    subjectXmlTemplateFilename = './Templates/subjectTemplate.xml';
end

dofToMuscles = containers.Map();
osimModel = Model(osimModelFilename);
osimModel.initSystem();

for i=1:length(dofList)
    currentDofName = dofList{i};
    dofToMuscles(currentDofName) = getMusclesOnDof(currentDofName, osimModel);
end

allMuscles = dofToMuscles.values;
i = 1:length(allMuscles);
allMuscles = unique(sort([allMuscles{i}]));

prefXmlRead.Str2Num = 'never';
tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);
tree.mtuDefault.emDelay = num2str(prefDef.emDelay);
%tree.mtuDefault.percentageChange = '0.15';
%tree.mtuDefault.damping  = '0.1';
k = 0;
for iMuscle=1:length(allMuscles)
   
    currentMuscleName = allMuscles{iMuscle};
    k = find(contains({tree.mtuSet.mtu.name},currentMuscleName));
    if isempty(k); k = length({tree.mtuSet.mtu.name})+1; end
    osimMuscle = osimModel.getMuscles().get(currentMuscleName);
    tree.mtuSet.mtu(k).name = currentMuscleName;
    tree.mtuSet.mtu(k).c1 =  -0.5; %default values, will be optimised in CEINMS (-0.95, -0.05)
    tree.mtuSet.mtu(k).c2 =  -0.5; %default values, will be optimised in CEINMS (-0.95, -0.05)
    tree.mtuSet.mtu(k).shapeFactor = 0.1;  %default values, will be optimised in CEINMS (0, -3)
    tree.mtuSet.mtu(k).optimalFibreLength =  osimMuscle.getOptimalFiberLength(); %from .osim model, could be optimised first with Modenese et al. 2016
    tree.mtuSet.mtu(k).pennationAngle = osimMuscle.getPennationAngleAtOptimalFiberLength(); %from .osim model
    tree.mtuSet.mtu(k).tendonSlackLength = osimMuscle.getTendonSlackLength(); %from .osim model, could be optimised first with Modenese et al. 2016
    tree.mtuSet.mtu(k).maxIsometricForce = osimMuscle.getMaxIsometricForce(); %from .osim model
    tree.mtuSet.mtu(k).strengthCoefficient = prefDef.strengthCoefficient; %default value, 1.5 (0.5, 2.5)
end
for iDof=1:length(dofList)
    dof = dofList{iDof};
    tree.dofSet.dof(iDof).name = dof;
    muscles = dofToMuscles(dof);
    muscleList = [];
    for j = 1:length(muscles)  
            muscleList = [muscleList, ' ', muscles{j}];
    end
    muscleList =  strrep (muscleList, ' obt_internus_r1','');
    muscleList =  strrep (muscleList, ' quad_fem_r','');
    muscleList =  strrep (muscleList, ' obt_internus_l1','');
    muscleList =  strrep (muscleList, ' quad_fem_l','');
    tree.dofSet.dof(iDof).mtuNameSet = muscleList;
end
tree.calibrationInfo.uncalibrated.subjectID = subjectID;
tree.calibrationInfo.uncalibrated.additionalInfo = 'TendonSlackLength and OptimalFibreLength scaled with Winby-Modenese';

if strcmp(prefDef.contact,'knee') %should probably write anyways, info will be ignored if contact model not enabled
    tree.contactModelFile = prefDef.contactModelFile;
    tree.opensimModelFile = prefDef.opensimModelFile;
elseif strcmp(prefDef.contact,'OpenSim') %Need to use minJCF version or this will give error, for executing atm, this may give error - option to delete it after calibration
    tree.contactModelFile = prefDef.contactModelFile; %in-case changes in future
    tree.opensimModelFile = prefDef.opensimModelFile; %'..\..\..\..\..\..\..\004\2019-06-18\OpenSim_model\scaled_004.osim'; % osimModelFilename;%prefDef.opensimModelFile;
    %     disp('%%%!!!!### OpenSim model file = 004 - osim3.3 model')
end

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
% outputUnCalXmlFilename = [baseDir '\' subjectID '\ceinms\uncalibratedSubjects\uncalibrated.xml'];
xml_write(outputUnCalXmlFilename, tree, 'subject', prefXmlWrite);