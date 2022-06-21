function intsegForce_JointReaction(dirFolders, trialname, leg, modelname)

import org.opensim.modeling.*

dirModel = [modelname];
dirIK = [dirFolders.IK fp trialname fp 'IK.mot' ];
dirSO =  [dirFolders.SO fp trialname fp];
dirExternalLoadsXML = [dirFolders.ID fp trialname fp 'grf.xml'];
dirMA = [dirFolders.MA fp trialname,'\'];

if ~exist(dirSO,'dir')                                                   % see whether directory exist, otherwise create it
    mkdir(dirSO)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load model and remove all muscles + add large actuators
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load model and IK
model = Model(dirModel);
lastMuscleInSet = char(model.getMuscles().get(model.getMuscles().getSize()-1).getName());
leg = lower(leg);
if leg == 'r'
    lastMuscleInSet(end) = leg;
end

JRA_intseg_forcefile = [dirSO 'intsegForce_InOnParentFrame_ReactionLoads.sto'] ;
if exist(JRA_intseg_forcefile,'file')
   return
end    

motstorage = Storage(dirIK);

model.updForceSet().clearAndDestroy() ;
coordinateSet = model.getCoordinateSet();
for icoord = 1:coordinateSet.getSize()
    coord_actuator = CoordinateActuator();
    coord_actuator.setCoordinate(coordinateSet.get(icoord-1));
    name_act = [char(coordinateSet.get(icoord-1).getName()) '_reserve'] ;
    
    coord_actuator.setName(name_act);
    coord_actuator.setOptimalForce(1000);
    coord_actuator.setMaxControl(100000);
    coord_actuator.setMinControl(-100000);
    model.addForce(coord_actuator);
end
% model.initSystem();

% setup JRA
JR = JointReaction();
JR.setName('InOnParentFrame');
JR.setStartTime(motstorage.getFirstTime());
JR.setEndTime(motstorage.getLastTime());
JR.setForcesFileName([dirSO '_StaticOptimization_force.sto']);

joint_names_arr = ArrayStr();
apply_on_bodies_arr = ArrayStr();
express_in_frame_arr = ArrayStr();

jointset =  model.getJointSet();
for ijoint = 1:jointset.getSize()
    joint_ = jointset.get(ijoint-1).getName();
    joint_names_arr.append(joint_);
    apply_on_bodies_arr.append('parent');
    express_in_frame_arr.append('parent');
end

JR.setJointNames(joint_names_arr);
JR.setOnBody(apply_on_bodies_arr);
JR.setInFrame(express_in_frame_arr);
model.updAnalysisSet().adoptAndAppend(JR);
% model.initSystem();

%run JRA
analysis = AnalyzeTool(model);
analysis.setModel(model);
analysis.setModelFilename(dirModel);
analysis.setInitialTime(motstorage.getFirstTime());
analysis.setFinalTime(motstorage.getLastTime());
analysis.setLowpassCutoffFrequency(6);
analysis.setCoordinatesFileName(dirIK);
analysis.setExternalLoadsFileName(dirExternalLoadsXML);
analysis.setLoadModelAndInput(1);
analysis.setResultsDir(JRA_intseg_forcefile);
analysis.setName('intsegForce');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run JRA to get intersegmental forces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysis.run();
