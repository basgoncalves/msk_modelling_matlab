function CreateMuscleActuatorFiles(dirIK,dirMC,dirExternalLoadsXML,dirMA, leg, dirModel,muscles_of_interest,muscle_force_file)
import org.opensim.modeling.*

rerun = 0;

if ~exist(dirMC,'dir')                                                   % see whether directory exist, otherwise create it
    mkdir(dirMC)
end

if ~exist('muscles_of_interest','var')
    muscles_of_interest = 'all';
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run JRA for each muscle in CEINMS to get contribution to each joint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist([dirMC, lastMuscleInSet,'.sto'],'file') || rerun == 0
    disp('creating Muscle Actuator Files ...')
    model2 = Model(dirModel);
%     model2.initSystem();
    % get actuators
    Actuators = importdata([dirMC  '_StaticOptimization_force.sto']);
    ActuatorsTime = Actuators.data(:,1);
    ActuatorsLabels = {};
    ActuatorsData = ones(size(Actuators.data,1),N_coordinateActuators+1);
    
    MuscleForceCEINMS = load_sto_file(muscle_force_file);
    
    for iAct = 0:N_coordinateActuators-1   
        ActuatorName = char(model.getForceSet().get(iAct).getName());
        ii = find(contains(Actuators.textdata(contains(Actuators.textdata(:,1),'time'),:),ActuatorName));
        ActuatorsData(:,iAct+1) = Actuators.data(:,ii(1));
        ActuatorsLabels(iAct+1) = {ActuatorName};
    end
    ActuatorsLabels(end+1)={'muscle'};
    
    % add 1 muscle back to model
    for imusc = 1:model2.getMuscles().getSize()
        musc_name =  model2.getMuscles().get(imusc-1).getName();
        
        if ~isequal(muscles_of_interest,'all') && ~contains(char(musc_name),muscles_of_interest)
            continue
        end
       
        % change actuator file such that 1 muscle in model
%         if contains(char(musc_name),['_',leg]) && ~exist([dirMC, char(musc_name),'.sto'],'file')
            disp(char(musc_name))
            ActuatorsDataNew = ActuatorsData;
            joints_spanned = getJointsSpannedByMuscle(model2, musc_name);
            
            % make sure model is consistent > remove moment produced by muscle 
            % around its spanning joints (Muscle Force = 1 -> moment = ma)
            for ijoint= 1:length(joints_spanned)
                joint_name = joints_spanned{ijoint};
                ncoords = model2.getJointSet().get(joint_name).numCoordinates();
                for icoord = 1:ncoords
                    % coord = model2.getJointSet().get(joint_name).get_coordinates(icoord-1).getName(); % for OpenSim 4
                    coord = model2.getJointSet().get(joint_name).getCoordinateSet().get(icoord-1);
                    moment_arm = importdata([dirMA, '_MuscleAnalysis_MomentArm_' char(coord), '.sto']);
                    icol_muscle = contains(moment_arm.colheaders,char(musc_name));
                    % change label to only muscle in model
                    ilabel_coordActuator = contains(ActuatorsLabels, char(coord));
                    momentMuscle_Force1 = moment_arm.data(:,icol_muscle);
                    
                    % sometimes the muscle analysis stops one frame earlier earlier
                    if length(momentMuscle_Force1) < size(ActuatorsDataNew,1)
                        momentMuscle_Force1(end+1:size(ActuatorsDataNew,1)) = momentMuscle_Force1(end);
                    end
                    ActuatorsDataNew(:,ilabel_coordActuator) = ActuatorsDataNew(:,ilabel_coordActuator)- momentMuscle_Force1;
                end
            end
       
            ActuatorsLabels{end} = char(musc_name);
            ActuatorsDataNew(:,end) = ActuatorsDataNew(:,end).*MuscleForceCEINMS.(char(musc_name));
            printMuscleContributionSTOmusc1F(dirMC, char(musc_name),ActuatorsTime,ActuatorsDataNew,ActuatorsLabels, '.sto')
%         end
    end
end


