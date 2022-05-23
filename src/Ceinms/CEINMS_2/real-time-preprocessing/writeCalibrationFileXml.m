% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% write calibration file xml
% Todo: 
function writeCalibrationFileXml(templateCalXML, trialSet, jointsForCalibration, fileOut, pref)
    %========default preferences==================================
    prefDef.NMSmodelType='openLoop'; %'hybrid' - not sure if this is in Calibration
    prefDef.tendonType= 'equilibriumElastic'; %'stiff' 'integrationElastic'
    prefDef.activationType='exponential'; %'piecewise'
    prefDef.parameterShareType = 'single'; %'global' 
    prefDef.objectiveFunction = 'torqueErrorNormalised'; %'torqueErrorAndSumKneeContactForces'
	prefDef.legSide = 'none'; %'r' 'l' %for use with torqueErrorAndSumKneeContactForces

    % read user preferences (if exists)
    if (nargin>4)
        if (isfield(pref, 'NMSmodelType')), prefDef.NMSmodelType=pref.NMSmodelType; end
        if (isfield(pref, 'tendonType')), prefDef.tendonType=pref.tendonType; end
        if (isfield(pref, 'activationType')), prefDef.activationType=pref.activationType; end
        if (isfield(pref, 'parameterShareType')), prefDef.parameterShareType=pref.parameterShareType; end
        if (isfield(pref, 'objectiveFunction')), prefDef.objectiveFunction=pref.objectiveFunction; end
		if (isfield(pref, 'legSide')), prefDef.legSide=pref.legSide; end
    end

    %Calibration File
    prefXmlRead.Str2Num = 'never';
    tree=xml_read(templateCalXML, prefXmlRead);
    tree.trialSet = trialSet;
    tree.calibrationSteps.step.dofs = jointsForCalibration;
    
    tree.NMSmodel.type.(prefDef.NMSmodelType)= struct; %xml_write will delete if empty matrix, so must be structure if wanting to keep
    tree.NMSmodel.tendon.(prefDef.tendonType)= struct;
    tree.NMSmodel.activation.(prefDef.activationType)= struct;
	if strcmp(prefDef.objectiveFunction, 'minimizeTorqueError')
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).targets = struct;
        tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction)= struct;
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction)= struct;
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction)= struct;

	elseif strcmp(prefDef.objectiveFunction, 'torqueErrorAndSumKneeContactForces') %must use modified knee osim model, hardcoded
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).ATTRIBUTE.exponent='2';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).ATTRIBUTE.exponent='0.000000001';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(1,1).ATTRIBUTE.exponent='2';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(1,1).ATTRIBUTE.exponent='1';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(1,1).targetName=['medial_condyle_' prefDef.legSide];
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(1,1).range='0 10000';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(2,1).ATTRIBUTE.exponent='2';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(2,1).ATTRIBUTE.exponent='1';
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(2,1).targetName=['lateral_condyle_' prefDef.legSide];
		tree.calibrationSteps.step.objectiveFunction.(prefDef.objectiveFunction).barrier(2,1).range='0 10000';
	end
    
    %the orders of the field is important, will give error if out of order
    order = {'name', 'muscleGroups', 'single', 'absolute', 'relativeToSubjectValue'};
    tree.calibrationSteps.step.parameterSet.parameter = orderfields(tree.calibrationSteps.step.parameterSet.parameter, order);

    %hardcoded, not needed ATM but in case wanting to change values in the
    %future, rewrite to include in user preference 
    
    %tree.calibrationSteps.step.parameterSet.parameter(1,1).name = 'c1';
    tree.calibrationSteps.step.parameterSet.parameter(1,1).(prefDef.parameterShareType)= struct;
    %tree.calibrationSteps.step.parameterSet.parameter(1,1).absolute.range ='-0.95 -0.05'; %keep as strings to avoid brackets
    
    %tree.calibrationSteps.step.parameterSet.parameter(2,1).name = 'c1';
    tree.calibrationSteps.step.parameterSet.parameter(2,1).(prefDef.parameterShareType)= struct;
    %tree.calibrationSteps.step.parameterSet.parameter(2,1).absolute.range ='-0.95 -0.05';
    
    %tree.calibrationSteps.step.parameterSet.parameter(3,1).name = 'shapeFactor';
    tree.calibrationSteps.step.parameterSet.parameter(3,1).(prefDef.parameterShareType)= struct;
    %tree.calibrationSteps.step.parameterSet.parameter(3,1).absolute.range ='-2.999 -0.001';
    
    %tree.calibrationSteps.step.parameterSet.parameter(4,1).name = 'tendonSlackLength';
    tree.calibrationSteps.step.parameterSet.parameter(4,1).(prefDef.parameterShareType)= struct;
    %tree.calibrationSteps.step.parameterSet.parameter(4,1).absolute.range = '0.85 1.15';
    
    %tree.calibrationSteps.step.parameterSet.parameter(5,1).name = 'optimalFibreLength';
    tree.calibrationSteps.step.parameterSet.parameter(5,1).(prefDef.parameterShareType)= struct;
    %tree.calibrationSteps.step.parameterSet.parameter(5,1).absolute.range = '0.85 1.15';
    
    %tree.calibrationSteps.step.parameterSet.parameter(6,1).name = 'strengthCoefficient';
    %tree.calibrationSteps.step.parameterSet.parameter(6,1).absolute.range = '0.5 2.5';
    
    %if wanting to change muscle groups, or side of muscles
    %for m=1:length(tree.calibrationSteps.step.parameterSet.parameter(6,1).muscleGroups.muscles) %
    %    tree.calibrationSteps.step.parameterSet.parameter(6,1).muscleGroups.muscles{1,m} = muscles;
    %end
    
    prefXmlWrite.StructItem = false;
    prefXmlWrite.CellItem   = false;
    
    xml_write(fileOut,tree,'calibration',prefXmlWrite);
end