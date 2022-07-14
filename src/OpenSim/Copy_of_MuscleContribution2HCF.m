function muscle_contributions = MuscleContribution2HCF(dirIK,dirMC,dirExternalLoadsXML,dirModel,musc_name)
import org.opensim.modeling.*

if ~exist(dirMC,'dir')                                                                                              % see whether directory exist, otherwise create it
    mkdir(dirMC)
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
model.initSystem();
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
JR.setForcesFileName([dirMC '_StaticOptimization_force.sto']);
JR.setJointNames(joint_names_arr);
JR.setOnBody(apply_on_bodies_arr);
JR.setInFrame(express_in_frame_arr);
model.updAnalysisSet().adoptAndAppend(JR);
model.initSystem();

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
analysis.setResultsDir(dirMC);
analysis.setName('intsegForce');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run JRA for each muscle in model with F = 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model2 = Model(dirModel);

if model.updForceSet().getSize() > model.getCoordinateSet().getSize()                                               % remove previous added muscle
    model.updForceSet().remove(model.getCoordinateSet().getSize());
end
disp(musc_name)
model.updForceSet().cloneAndAppend(model2.getMuscles().get(musc_name));                                             % there is an issue with 'updForceSet().Append()' https://github.com/opensim-org/opensim-core/issues/432

model.initSystem();
JR.setForcesFileName([dirMC, char(musc_name), '.sto']);

model.addAnalysis(JR)
model.updAnalysisSet().adoptAndAppend(JR);
model.initSystem();

analysis.setName(char(musc_name));
analysis.setModel(model);
analysis.run();

cd(dirMC)

setupFile = 'setup.xml'; 
logFileOut=[dirMC 'out.log'];% Save the log file in a Log folder for each trial
analysis.print(setupFile)

dos(['analyze -S ' setupFile ' > ' logFileOut]);

muscle_contributions = load_sto_file([dirMC char(musc_name) '_InOnParentFrame_ReactionLoads.sto']);
JCF = load_sto_file(['C:\Users\Bas\Documents\3-PhD\MocapData\ElaboratedData\009\pre\JointReactionAnalysis\Run_baseline1\JCF_JointReaction_ReactionLoads.sto']);

figure; hold on
plot(muscle_contributions.hip_r_on_pelvis_in_pelvis_fx)
plot(JCF.hip_r_on_pelvis_in_pelvis_fx)
title(musc_name)
legend('muscle contribution', 'total HCF')
