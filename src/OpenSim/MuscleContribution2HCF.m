function MuscleContribution2HCF(dirIK,dirSO,dirExternalLoadsXML, trialName, modelname,musc_name)
import org.opensim.modeling.*

dirModel = [modelname];


if ~exist(dirSO,'dir')                                                                                              % see whether directory exist, otherwise create it
    mkdir(dirSO)
end

model = Model(dirModel);                                                                                            % load model and IK
motstorage = Storage(dirIK);

model.updForceSet().clearAndDestroy() ;                                                                             % add reserve actuators to model
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

% setup JRA
JR = JointReaction();
JR.setName('InOnParentFrame');
JR.setStartTime(motstorage.getFirstTime());
JR.setEndTime(motstorage.getLastTime());
JR.setForcesFileName([dirSO '_StaticOptimization_force.sto']);
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
analysis.setResultsDir(dirSO);
analysis.setName('intsegForce');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run JRA for each muscle in model with F = 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model2 = Model(dirModel);


if model.updForceSet().getSize() > model.getCoordinateSet().getSize()                                               % remove previous added muscle
    model.updForceSet().remove(model.getCoordinateSet().getSize());
end
disp(musc_name)
model.updForceSet().cloneAndAppend(model2.getMuscles().get(musc_name));                             % https://github.com/opensim-org/opensim-core/issues/432

%     model.initSystem();
JR.setForcesFileName([dirSO, char(musc_name), '.sto']);

model.addAnalysis(JR)
model.updAnalysisSet().adoptAndAppend(JR);
model.initSystem();

analysis.setName(char(musc_name));
analysis.setModel(model);
analysis.run();



