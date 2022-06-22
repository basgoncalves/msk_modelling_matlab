function [trialDirs] = getdirosimfiles_BOPS(trialName,RelPath)
%% create the file directories needed for a certain "TrialName"
% RelPath = Logic value
% If "RelPath" exist, make all the directories relative to "RelPath"
warning off
bops        = load_setup_bops;
subject     = load_subject_settings;
Dir         = subject.directories;
trialDirs   = struct;

if nargin < 1
    trialName = subject.trials.trialList{1};
end

trialDirs.c3d               = [Dir.Input fp  trialName '.c3d'];                                                     % elaborated data 
trialDirs.externalforces    = [Dir.dynamicElaborations fp trialName fp 'grf.mot'];
trialDirs.emg               = [Dir.dynamicElaborations fp trialName fp 'emg.mot'];
trialDirs.coordinates       = [Dir.dynamicElaborations fp trialName fp 'markers.trc'];

trialDirs.LinearScaledModel             = [Dir.OSIM_LinearScaled];                                                  % models
trialDirs.MassAdjustedModel             = [Dir.OSIM_RRA];
trialDirs.LucaOptimisedModel            = [Dir.OSIM_LO];
trialDirs.LucaOptimisedModelWithHans    = [Dir.OSIM_LO_HANS_originalMass];

currentAnalysis = bops.current.analysis;                                                                            % define model to use for each type of analysis
try
    modelToUse = bops.analyses_settings.(currentAnalysis).model;
    trialDirs.modelToUse = trialDirs.LinearScaledModel;
catch
    trialDirs.modelToUse = trialDirs.LinearScaledModel;
end

trialDirs.IK            = [Dir.IK fp trialName];                                                                    % inverse kinematics
trialDirs.IKmodel       = subject.directories.(bops.analyses_settings.ik.model);
trialDirs.IKcoordinates = [trialDirs.IK fp 'markers.trc'];
trialDirs.IKresults     = [trialDirs.IK fp 'IK.mot'];
trialDirs.IKsetup       = [trialDirs.IK fp 'setup_IK.xml'];

trialDirs.ID                = [Dir.ID fp trialName];                                                                % inverse dynamics
trialDirs.IDexternalforces  = [trialDirs.ID fp 'grf.mot'];
trialDirs.IDcoordinates     = [trialDirs.ID fp 'IK.mot'];
trialDirs.IDgrfxml          = [trialDirs.ID fp 'grf.xml'];
trialDirs.IDsetup           = [trialDirs.ID fp 'setup_ID.xml'];
trialDirs.IDresults         = [trialDirs.ID fp 'inverse_dynamics.sto'];
trialDirs.IDRRAresults      = [trialDirs.ID fp 'inverse_dynamics_RRA.sto'];

trialDirs.MA                = [Dir.MA fp trialName];                                                                % muscle analysis
trialDirs.MAmodel           = subject.directories.(bops.analyses_settings.ma.model);   % same for JRA and SO
trialDirs.MAsetup           = [trialDirs.MA fp 'setup_MA.xml'];
trialDirs.MAlog             = [trialDirs.MA fp 'out.log'];
trialDirs.MA_Length         = [trialDirs.MA fp '_MuscleAnalysis_Length.sto'];
trialDirs.MA_FiberLength    = [trialDirs.MA fp '_MuscleAnalysis_FiberLength.sto'];
trialDirs.MA_TendonLength   = [trialDirs.MA fp '_MuscleAnalysis_TendonLength.sto'];

trialDirs.RRA                           = [Dir.RRA fp trialName];                                                   % residual reduction analysis 
trialDirs.RRAdesired_kinematics_file    = trialDirs.IKresults;
trialDirs.RRAexternal_loads_file        = trialDirs.IDgrfxml;
trialDirs.RRAkinematics                 = [trialDirs.RRA fp 'Kinematics_q.sto'];
trialDirs.RRAsetup                      = [trialDirs.RRA fp 'setup_RRA.xml'];
trialDirs.RRAtasks                      = [trialDirs.RRA fp 'tasks_RRA.xml'];
trialDirs.RRAactuators                  = [trialDirs.RRA fp 'actuators_RAA.xml'];
[~,fname,ext]=fileparts(Dir.OSIM_RRA);
trialDirs.RRAmodel                      = [trialDirs.RRA fp fname ext];
trialDirs.RRAresiduals                  = [trialDirs.RRA fp trialName '_avgResiduals.txt'];
trialDirs.RRAlog                        = [trialDirs.RRA fp 'out.log'];
trialDirs.RRAcontrols                   = [trialDirs.RRA fp 'controls.sto'];
trialDirs.RRAactuation_force            = [trialDirs.RRA fp 'actuation_force.sto'];
trialDirs.RRAinverse_dynamics_setup     = [trialDirs.RRA fp 'setup_ID.xml'];
trialDirs.RRAinverse_dynamics           = [trialDirs.RRA fp 'inverse_dynamics.sto'];
trialDirs.RRAsetup_actuation_analyze    = [trialDirs.RRA fp 'setup_actuation_analyze.xml'];

trialDirs.JRA                       = [Dir.JRA fp trialName];                                                       % joint reaction analysis
trialDirs.JRAmodel                  = trialDirs.MAmodel;
trialDirs.JRAexternal_loads_file    = trialDirs.IDgrfxml;
trialDirs.JRAkinematics             = trialDirs.IKresults;
trialDirs.JRAforcefile              = [trialDirs.JRA fp 'forcefile.sto'];
trialDirs.JRAresults                = [trialDirs.JRA fp 'JCF_JointReaction_ReactionLoads.sto'];

trialDirs.SO                    = [Dir.SO fp trialName];                                                            % static optimization
trialDirs.SOmodel               = trialDirs.MAmodel;
trialDirs.SOsetup               = [trialDirs.SO fp 'setup.xml'];
trialDirs.SOactuators           = [trialDirs.SO fp 'actuators.xml'];
trialDirs.SOexternal_loads_file = trialDirs.IDgrfxml;
trialDirs.SOkinematics          = trialDirs.IKresults;
trialDirs.SOforceResults        = [trialDirs.SO fp '_StaticOptimization_force.sto'];
trialDirs.SOactivationResults   = [trialDirs.SO fp '_StaticOptimization_activation.sto'];

trialDirs.IAA                       = [Dir.IAA fp trialName];                                                       % induced acceleration analysis
trialDirs.IAAmodel                  = trialDirs.MAmodel;
trialDirs.IAAsetup                  = [trialDirs.IAA fp 'setup.xml'];
trialDirs.IAAactuators              = [trialDirs.IAA fp 'actuators.xml'];
trialDirs.IAAexternal_loads_file    = trialDirs.IDgrfxml;
trialDirs.IAAkinematics             = trialDirs.IKresults;
trialDirs.IAAkinetics_file          = trialDirs.externalforces;
trialDirs.IAAforcefile              = [trialDirs.IAA fp 'forcefile.sto'];
trialDirs.IAAresults                = [trialDirs.SO fp trialName fp 'IndAccPI_Results'];

trialDirs.CMC                       = [Dir.CMC fp trialName];                                                       % computed muscle control
trialDirs.CMCmodel                  = trialDirs.MAmodel;
trialDirs.CMCsetup                  = [trialDirs.CMC fp 'setup.xml'];
trialDirs.CMCactuators              = [trialDirs.CMC fp 'actuators.xml'];
trialDirs.CMCControlConstraints     = [trialDirs.CMC fp 'ControlConstraints.xml'];
trialDirs.CMCexternal_loads_file    = trialDirs.IDgrfxml;
trialDirs.CMCtasks                  = [trialDirs.CMC fp 'tasks.xml'];

if contains(bops.analyses_settings.cmc.desired_kinematics_file,'ik','IgnoreCase',1)
    trialDirs.CMCkinematics         = trialDirs.IKresults;
elseif contains(bops.analyses_settings.cmc.desired_kinematics_file,'rra','IgnoreCase',1)
    trialDirs.CMCkinematics         = trialDirs.RRAkinematics;
else
    warning on
    warning('CMC kinematics not well defined in "bopsSettings.xml". Please use only "ik" or "rra"')
end


trialDirs.CMCresults                = [trialDirs.CMC fp 'Results'];
trialDirs.CMCresults_name           = 'cmc';
trialDirs.CMC_force                 = [trialDirs.CMCresults fp trialDirs.CMCresults_name '_Actuation_force.sto'];
trialDirs.CMC_pErr                  = [trialDirs.CMCresults fp trialDirs.CMCresults_name '_pErr.sto'];
trialDirs.CMC_pErr                  = [trialDirs.CMCresults fp trialDirs.CMCresults_name '_Kinematics_q.sto'];


if nargin == 2                                                                                                      % if needed make paths relative
    f = fields(trialDirs);
    for i = 1:length(f)
        trialDirs.(f{i}) = relativepath(trialDirs.(f{i}),RelPath);
    end
    trialDirs.RelPath = RelPath;
    cd(RelPath)
end
