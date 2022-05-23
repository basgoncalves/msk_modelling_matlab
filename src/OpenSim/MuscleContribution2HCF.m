function MuscleContribution2HCF(dirFolders, trialname, leg, modelname,muscles_of_interest)
import org.opensim.modeling.*

dirModel = [modelname];
dirIK = [dirFolders.IK fp trialname fp 'ik.mot' ];
dirSO =  [dirFolders.SO fp trialname fp];
dirExternalLoadsXML = [dirFolders.ID fp trialname fp 'grf.xml'];
dirMA = [dirFolders.MA fp trialname,'\'];

if ~exist(dirSO,'dir')                                                   % see whether directory exist, otherwise create it
    mkdir(dirSO)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run static optimisation to get actuators
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SO_forcefile = [dirSO '_StaticOptimization_force.sto'] ;
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
    tool.setResultsDir(dirSO);
    tool.run()
    
    model.removeAnalysis(SO);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run JRA for each muscle in CEINMS to get contribution to each joint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ActStruct = struct;
if ~exist([dirSO, lastMuscleInSet,'.sto'],'file')
    disp('')
    model2 = Model(dirModel);
%     model2.initSystem();
    
    % get actuators
    Actuators = importdata([dirSO  '_StaticOptimization_force.sto']);
    ActuatorsTime = Actuators.data(:,1);
    ActuatorsLabels = {};
    ActuatorsData = ones(size(Actuators.data,1),model.getForceSet().getSize());
    for iAct = 1:model.getForceSet().getSize()-1
        ActuatorName = char(model.getForceSet().get(iAct-1).getName());
        ii = contains(Actuators.textdata(contains(Actuators.textdata(:,1),'time'),:),ActuatorName);
        ActuatorsData(:,iAct) = Actuators.data(:,ii);
        ActuatorsLabels(iAct) ={ActuatorName};
    end
    ActuatorsLabels(end+1)={'muscle'};
    
    % add 1 muscle back to model
    for imusc = 1:model2.getMuscles().getSize()
        musc_name =  model2.getMuscles().get(imusc-1).getName();
        disp(char(musc_name))
        
        if ~isequal(muscles_of_interest,'all') && ~contains(char(musc_name),muscles_of_interest)
            continue
        end
        
        % change actuator file such that 1 muscle in model
        if contains(char(musc_name),['_',leg]) && ~exist([dirSO, char(musc_name),'.sto'],'file')
            ActuatorsDataNew = ActuatorsData;
            joints_spanned = getJointsSpannedByMuscle(model2, musc_name);
            
            % make sure model is consistent > remove moment produced by muscle around its spanning joints (Muscle Force = 1 -> moment = ma)
            for ijoint= 1:length(joints_spanned)
                joint_name = joints_spanned{ijoint};
                ncoords = model2.getJointSet().get(joint_name).numCoordinates();
                for icoord = 1:ncoords
                    
                    % coord = model2.getJointSet().get(joint_name).get_coordinates(icoord-1).getName(); % for OpenSim 4
                    coord = model2.getJointSet().get(joint_name).getCoordinateSet().get(icoord-1);
                    moment_arm = importdata([dirMA, '_MuscleAnalysis_MomentArm_' char(coord), '.sto']);
                    icol_muscle = contains(moment_arm.textdata(contains(moment_arm.textdata(:,1),'time'),:),char(musc_name));
                    
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
            
            ActStruct.(char(musc_name)) = ActuatorsDataNew;
            
            ActuatorsLabels{end} = char(musc_name);
            printMuscleContributionSTOmusc1F(dirSO, char(musc_name),ActuatorsTime,ActuatorsDataNew,ActuatorsLabels, '.sto')
        elseif contains(char(musc_name),['_',leg]) && exist([dirSO, char(musc_name),'.sto'],'file')
%             ActuatorsDataNew = struct2array(load_sto_file([dirSO char(musc_name) '.sto']));
%             ActStruct.(char(musc_name)) = ActuatorsDataNew;
        end
    end
end

if exist('model2', 'var')
    clear model2
end

% setup JRA
JR = JointReaction();
JR.setName('InOnParentFrame');
JR.setStartTime(motstorage.getFirstTime());
JR.setEndTime(motstorage.getLastTime());
JR.setForcesFileName([dirSO '_StaticOptimization_force.sto']);
joint_names_arr         = ArrayStr();
apply_on_bodies_arr     = ArrayStr();
express_in_frame_arr    = ArrayStr();

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
analysis.setResultsDir(dirSO);
analysis.setName('intsegForce');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run JRA to get intersegmental forces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
JRA_intseg_forcefile = [dirSO 'intsegForce_JointReaction_ReactionLoads.sto'] ;
if ~exist(JRA_intseg_forcefile,'file')
    analysis.run();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run JRA for each muscle in model with F = 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model2 = Model(dirModel);
for imusc = 1: model2.getMuscles().getSize()
    if ~isequal(muscles_of_interest,'all') && ~contains(char(musc_name),muscles_of_interest)
        continue
    end
    
    runJRA_F1(analysis,model,dirModel,imusc,JR,leg,dirSO)
end
clear model model2


function printMuscleContributionSTOmusc1F(dirSO, musc_name,ActuatorsTime,ActuatorsDataNew,ActuatorsLabels, ext)

labels = ['time', ActuatorsLabels];
values_array = [ActuatorsTime, ActuatorsDataNew];
values_cell = {};
for i = 1:size(values_array,2)
    values_cell{i} = values_array(:,i);
end
data = cell2struct(values_cell,labels,2);
write_sto_file(data, [dirSO fp musc_name ext])


function runJRA_F1(analysis,model,dirModel,imusc,JR,leg,dirSO)
import org.opensim.modeling.*
model2 = Model(dirModel);
musc_name =  model2.getMuscles().get(imusc-1).getName();
if contains(char(musc_name),['_',leg]) && ~exist([dirSO, char(musc_name),'_InOnParentFrame_ReactionLoads.sto'],'file')
    %remove previous added muscle
    if model.updForceSet().getSize() > model.getCoordinateSet().getSize()
        model.updForceSet().remove(model.getCoordinateSet().getSize());
    end
    disp(char(musc_name))
    model.updForceSet().append(model2.getMuscles().get(musc_name));
    model.initSystem();
    
    JR.setForcesFileName([dirSO, char(musc_name), '.sto']);
    
    %model.addAnalysis(JR)
    model.updAnalysisSet().adoptAndAppend(JR);
    model.initSystem();
    
    analysis.setName(char(musc_name));
    analysis.setModel(model);
    analysis.run();
end

