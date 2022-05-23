function [ calibrationCfgFilename ] = generateCalibrationCfg(Dir,CEINMSSettings, Temp,trialList,calibrationTrials)
%SELECTTRIALS Summary of this function goes here
%   Detailed explanation goes here
addpath('shared');
addpath('xml_io_tools');
fp = filesep;

% relative path calibration trials
SelectedTrials = trialList(find(contains(trialList,calibrationTrials,'IgnoreCase',true)));
trialsString = '';
for j = 1:length(SelectedTrials)
    SelectedTrials{j} =  relativepath(SelectedTrials{j},Dir.CEINMScalibration);
    trialsString = [trialsString ' ' SelectedTrials{j}];
end
%========default preferences==================================
prefDef.NMSmodelType='openLoop'; %'hybrid' - not sure if this is in Calibration
prefDef.tendonType= 'equilibriumElastic'; %'stiff' 'integrationElastic'
prefDef.activationType='exponential'; %'piecewise'
prefDef.parameterShareType = 'single'; %'global'
prefDef.objectiveFunction = 'torqueErrorNormalised'; %'torqueErrorAndSumKneeContactForces'
prefDef.legSide = 'none'; %'r' 'l' %for

% edit xml 
prefXmlRead.Str2Num = 'never';
prefXmlRead.NoCells=false;
tree = xml_read(Temp.CEINMScfgCalibration, prefXmlRead);
tree.calibrationSteps.step.parameterSet.parameter{6}.absolute.range = '0.8 2';% range for strengthCoefficient
tree.calibrationSteps.step.dofs = CEINMSSettings.dofList;
tree.NMSmodel.type.(prefDef.NMSmodelType)= struct;      % xml_write will delete if empty matrix, so must be structure if wanting to keep
tree.NMSmodel.tendon.(prefDef.tendonType)= struct;
tree.NMSmodel.activation.(prefDef.activationType)= struct;

% do the same for all parameters except the strengthCoefficients
for k = 1:length(tree.calibrationSteps.step.parameterSet.parameter)-1
    tree.calibrationSteps.step.parameterSet.parameter{1,k}.single = struct;
end

% add only the muscles relevant for the DOFs specified 
dofList = split(CEINMSSettings.dofList ,' ')';
import org.opensim.modeling.*
osimModel = Model(CEINMSSettings.osimModelFilename);
AllDOFMuscles = {};
for i=1:length(dofList)
    currentDofName = dofList{i};
    [currentDofMuscles,~] = getMusclesOnDof_BG(currentDofName, osimModel);
    if contains(currentDofMuscles,'quad_fem_r')    
        error('current muscle model contains "quad_fem_r", please remove')
    end
    AllDOFMuscles =  unique([AllDOFMuscles currentDofMuscles]);
end

MusclesToRemove = ~contains(tree.calibrationSteps.step.parameterSet.parameter{end}.muscleGroups.muscles,AllDOFMuscles);
tree.calibrationSteps.step.parameterSet.parameter{end}.muscleGroups.muscles(MusclesToRemove) = [];


% add degrees of freedom to optimise
tree.trialSet = trialsString;
prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
calibrationCfgFilename = CEINMSSettings.calibrationCfg;
xml_write(calibrationCfgFilename, tree, 'calibration', prefXmlWrite);


disp('Calibration configuration xml generated')