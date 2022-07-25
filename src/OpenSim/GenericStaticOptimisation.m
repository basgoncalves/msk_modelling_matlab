function GenericStaticOptimisation(dirIK,dirMC,dirExternalLoadsXML, leg, dirModel)
import org.opensim.modeling.*

if ~exist(dirMC,'dir')                                                   % see whether directory exist, otherwise create it
    mkdir(dirMC)
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
motstorage = Storage(dirIK);

model.updForceSet().clearAndDestroy() ;
coordinateSet = model.getCoordinateSet();
N_coordinateActuators = coordinateSet.getSize();

for icoord = 0:N_coordinateActuators-1
    coord_actuator = CoordinateActuator();
    coord_actuator.setCoordinate(coordinateSet.get(icoord));
    name_act = [char(coordinateSet.get(icoord).getName()) '_reserve'] ;
    
    coord_actuator.setName(name_act);
    coord_actuator.setOptimalForce(1000);
    coord_actuator.setMaxControl(100000);
    coord_actuator.setMinControl(-100000);
    model.addForce(coord_actuator);
end
model.initSystem();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run static optimisation to get actuators
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(dirMC)
SO_forcefile = [dirMC '_StaticOptimization_force.sto'] ;
if ~exist(SO_forcefile,'file')
    % setup
    SO = StaticOptimization();
    SO.setStartTime(motstorage.getFirstTime());
    SO.setEndTime(motstorage.getLastTime());
    SO.setUseModelForceSet(1);
    SO.setConvergenceCriterion(0.0001);
    SO.setMaxIterations(100);
    model.addAnalysis(SO);
    % run analysis tool
    tool = AnalyzeTool();
    tool.setModel(model);
    tool.setInitialTime(motstorage.getFirstTime());
    tool.setFinalTime(motstorage.getLastTime());
    tool.setCoordinatesFileName(dirIK);
    tool.setExternalLoadsFileName(dirExternalLoadsXML);
    tool.setLoadModelAndInput(1);
    tool.setLowpassCutoffFrequency(6);
    tool.setResultsDir(dirMC);
    tool.run()
        
    model.removeAnalysis(SO);
end