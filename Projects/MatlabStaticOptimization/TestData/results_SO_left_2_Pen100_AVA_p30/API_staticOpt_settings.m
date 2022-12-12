% Custom static optimization code. Author: Scott Uhlrich, Stanford
% University, 2020. Please cite:
% Uhlrich, S.D., Jackson, R.W., Seth, A., Kolesar, J.A., Delp S.L.
% Muscle coordination retraining  inspired by musculoskeletal simulations
% reduces knee contact force. Sci Rep 12, 9842 (2022).
% https://doi.org/10.1038/s41598-022-13386-9

function [] = MAIN_StaticOptimization_CMBBE_withTestData()
% This main loop allows you to run StaticOptimizationAPI.m

clear all;  format compact; clc; fclose all;
%close all;

% % Path to the data and utility functions. No need to change this, unless
% you rearrange the folder structure, differently from github.
maindir = fileparts([mfilename('fullpath') '.m']);
baseDir = [maindir '\TestData\'] ; % Base Directory to base results directory.
addpath(genpath('Utilities'))

% % % Fill Path names
INPUTS.trialname = 'walking_baseline1' ;
INPUTS.forceFilePath = [baseDir '\walking_baseline1_forces.mot'] ;  % Full path of forces file
INPUTS.ikFilePath = [baseDir '\results_ik.sto'] ; % Full path of IK file
INPUTS.idFilePath = [baseDir '\results_id.sto'] ; % Full path of ID file
INPUTS.emgFilePath = [baseDir '\EMG_allMuscles.sto'] ; % location of *.mot file with normalized EMG (if using EMG)
INPUTS.outputFilePath = [baseDir '\results_SO_Pen1000_AVA_p30\'] ; % full path for SO & JRA outputs
INPUTS.modelDir = [baseDir] ; % full path to folder where model is
INPUTS.modelName = 'Rajagopal_scaled_Sub1_TorsFem_l_Prox30Dist0Deg.osim' ; % model file name
geometryPath = [baseDir 'Geometry'] ; % full path to geometry folder for Model. If pointing to Geometry folder in OpenSim install, leave this field blank: []

INPUTS.leg = 'l' ; % If deleteContralateralMuscles flag is true, actuates this leg
% with muscles and contralateral leg with coordinate actuators
% only. If deleteContralateralMuscles flag is false,
% this input doesn't matter.

% Flags

% % Load up the INPUTS structure for static optimization parameters that are constant across all
% trials and subjects
INPUTS.filtFreq = 6 ; % Lowpass filter frequency for IK coordinates. -1 if no filtering

% Flags
INPUTS.appendActuators = true ; % Append reserve actuators at all coordinates?
INPUTS.appendForces = true ; % True if you want to append grfs?
INPUTS.deleteContralateralMuscles = false ; % replace muscles on contralateral leg with powerful reserve actuators (makes SO faster)
INPUTS.useEmgRatios = false ; % true if you want to track EMG ratios defined in INPUTS.emgRatioPairs
INPUTS.useEqualMuscles = false ; % true if you want to constrain INPUTS.equalMuscles muscle pairs to be equivalent
INPUTS.useEmgConstraints = false ; % true if you want to constrain muscle activations to follow EMG input INPUTS.emgConstrainedMuscles
INPUTS.changePassiveForce = false ; % true if want to turn passive forces off
INPUTS.ignoreTendonCompliance = false ; % true if making all tendons rigid


% Degrees of Freedom to ignore (patellar coupler constraints, etc.) during moment matching constraint
INPUTS.fixedDOFs = {'knee_angle_r_beta','knee_angle_l_beta'} ;

% EMG file
INPUTS.emgRatioPairs = {} ; % nPairs x 2 cell for muscle names whos ratios you want to constrain with EMG. Can leave off '_[leg]' if you want it to apply to both
INPUTS.equalMuscles = {} ; % nPairs x 2 cell of muscles for whom you want equal activations
INPUTS.emgConstrainedMuscles = {} ; % nMuscles x 1 cell of muscles for which you want activation to track EMG.  Can leave off '_[leg]' if you want it to apply to both

INPUTS.emgSumThreshold = 0 ; % If sum of emg pairs is less than this it won't show up in the constraint or cost (wherever you put it)

% Weights for reserves, muscles. The weight is in
% the cost function as sum(w*(whatever^2)), so the weight is not squared.
INPUTS.reserveActuatorWeights = 1 ;
INPUTS.muscleWeights = 1 ;
INPUTS.ipsilateralActuatorStrength = 1 ;
INPUTS.contralateralActuatorStrength = 100 ;
INPUTS.weightsToOverride = {'recfem'} ; % Overrides the general actuator weight for muscles or reserves.
% Can be a partial name. Eg. 'hip_rotation' will change hip_rotation_r and hip_rotation_l
% or 'gastroc' to override the weight for the right and left gastroc muscles
INPUTS.overrideWeights = [1000]; % A column vector the same size as weights
INPUTS.prescribedActuationCoords = {} ; % A column cell with coordinates (exact name) that will be prescribed from ID moments eg. 'knee_adduction_r'
% The muscles will not aim to balance the moment at this DOF,
% but their contribution to the moment will be computed at the
% end of the optimization step, and the remaining moment generated by
% the reserve actuator


% External Forces Definitions
INPUTS.externalForceName = {'GRF_r','GRF_l'} ; % nForces x 1 cell
INPUTS.applied_to_body = {'calcn_r','calcn_l'} ;
INPUTS.force_expressed_in_body =  {'ground','ground'} ;
INPUTS.force_identifier = {'ground_force_v','1_ground_force_v'} ;
INPUTS.point_expressed_in_body = {'ground','ground'} ;
INPUTS.point_identifier = {'ground_force_p','1_ground_force_p'} ;

% Joint Reaction Fields
INPUTS.jRxn.inFrame = 'parent' ;
INPUTS.jRxn.onBody = 'parent' ;
INPUTS.jRxn.jointNames = ['all'] ;

INPUTS.passiveForceStrains = [0, 0.7] ; % Default = [0,.7] this is strain at zero force and strain at 1 norm force in Millard model
% This only matters if ignorePassiveForces = true

% % % % % END OF USER INPUTS % % % % %% % % % %% % % % %% % % % %% % % % %
import org.opensim.modeling.*

if ~isempty(INPUTS.overrideWeights)
    disp('YOU ARE OVERRIDING SOME ACTUATOR WEIGHTS');
end

if ~isempty(geometryPath)
    org.opensim.modeling.ModelVisualizer.addDirToGeometrySearchPaths(geometryPath)
end

disp('FINDING TIMES FOR ALL THE GAIT CYCLES')
[contacts_leftLeg,contacts_rightLeg] = find_gait_cycles(INPUTS.ikFilePath,INPUTS.forceFilePath);

Penalties = [0,10,100,500,1000];

for iPen = Penalties

    INPUTS.overrideWeights = [iPen]; % A column vector the same size as weights

    % Run it for Right leg
    for i = 1:6%length(contacts_rightLeg)-1
        INPUTS.startTime = contacts_rightLeg(i); % % % Set time for simulation % % %
        INPUTS.endTime = contacts_rightLeg(i+1);
        INPUTS.leg = 'r';
        INPUTS.outputFilePath = [baseDir '\results_SO_right_' num2str(i) '_Pen' num2str(iPen) '_AVA_p30\'];

        StaticOptimizationAPIVectorized(INPUTS) ; % Run StaticOptimizationAPI

        % Save this script in the folder to reference settings
        FileNameAndLocation=[mfilename('fullpath')];
        newbackup=[INPUTS.outputFilePath 'API_staticOpt_settings.m'];
        currentfile=strcat(FileNameAndLocation, '.m');
        copyfile(currentfile,newbackup);
    end

    % Run it for Left leg
    for i = 1:6%length(contacts_leftLeg)-1

        INPUTS.startTime = contacts_leftLeg(i); % % % Set time for simulation % % %
        INPUTS.endTime = contacts_leftLeg(i+1);
        INPUTS.leg = 'l';
        INPUTS.outputFilePath = [baseDir '\results_SO_left_' num2str(i) '_Pen' num2str(iPen) '_AVA_p30\'];

        StaticOptimizationAPIVectorized(INPUTS) ; % Run StaticOptimizationAPI


        % Save this script in the folder to reference settings
        FileNameAndLocation=[mfilename('fullpath')];
        newbackup=[INPUTS.outputFilePath 'API_staticOpt_settings.m'];
        currentfile=strcat(FileNameAndLocation, '.m');
        copyfile(currentfile,newbackup);
    end


end

savedir = [baseDir fp 'resilts_figures_parent'];
plotReuslts_CMBBE_withTestData(savedir)

end % Main

