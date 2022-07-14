

% create the file directories needed for a certain "TrialName"
% If "RelPath" exist, make all the directories relative to "RelPath"

function [trialDirs] = getosimfilesFAI(Dir,trialName,RelPath)

warning off
fp = filesep;
trialDirs = struct;

if nargin ==3
    trialDirs.RelPath = RelPath;
end

trialDirs.c3d = [Dir.Input fp  trialName '.c3d'];

trialDirs.externalforces = [Dir.dynamicElaborations fp trialName fp  trialName '.mot'];
trialDirs.emg = [Dir.dynamicElaborations fp trialName fp 'emg.mot'];
trialDirs.coordinates = [Dir.dynamicElaborations fp trialName fp trialName '.trc'];

trialDirs.LinearScaledModel = [Dir.OSIM_LinearScaled];
trialDirs.MassAdjustedModel = [Dir.OSIM_RRA];
trialDirs.LucaOptimisedModel = [Dir.OSIM_LO];
trialDirs.LucaOptimisedModelWithHans= [Dir.OSIM_LO_HANS_originalMass];


trialDirs.IK = [Dir.IK fp trialName];
trialDirs.IKcoordinates = [trialDirs.IK fp trialName '.trc'];
trialDirs.IKresults = [trialDirs.IK fp 'IK.mot'];
trialDirs.IKsetup = [trialDirs.IK fp 'setup_IK.xml'];

trialDirs.ID = [Dir.ID fp trialName];
trialDirs.IDexternalforces = [trialDirs.ID fp trialName '.mot'];
trialDirs.IDcoordinates = [trialDirs.ID fp 'IK.mot'];
trialDirs.IDgrfxml = [trialDirs.ID fp 'grf.xml'];
trialDirs.IDsetup = [trialDirs.ID fp 'setup_ID.xml'];
trialDirs.IDresults = [trialDirs.ID fp 'inverse_dynamics.sto'];
trialDirs.IDRRAresults = [trialDirs.ID fp 'inverse_dynamics_RRA.sto'];

trialDirs.MA = [Dir.MA fp trialName];
trialDirs.MAmodel = trialDirs.LucaOptimisedModelWithHans;   % same for JRA and SO
trialDirs.MAsetup = [trialDirs.MA fp 'Setup' fp 'setup_MA.xml'];
trialDirs.MAlog = [trialDirs.MA fp 'out.log'];

trialDirs.RRA = [Dir.RRA fp trialName];
trialDirs.RRAdesired_kinematics_file = trialDirs.IKresults;
trialDirs.RRAexternal_loads_file = trialDirs.IDgrfxml;
trialDirs.RRAkinematics = [trialDirs.RRA fp trialName '_Kinematics_q.sto'];
trialDirs.RRAsetup = [trialDirs.RRA fp 'setup_RRA.xml'];
trialDirs.RRAtasks = [trialDirs.RRA fp 'tasks_RRA.xml'];
trialDirs.RRAactuators = [trialDirs.RRA fp 'actuators_RAA.xml'];
[~,fname,ext]=fileparts(Dir.OSIM_RRA);
trialDirs.RRAmodel = [trialDirs.RRA fp fname ext];
trialDirs.RRAresiduals = [trialDirs.RRA fp trialName '_avgResiduals.txt'];
trialDirs.RRAlog = [trialDirs.RRA fp 'out.log'];
trialDirs.RRAcontrols = [trialDirs.RRA fp trialName '_controls.sto'];
trialDirs.RRAactuation_force = [trialDirs.RRA fp trialName '_Actuation_force.sto'];
trialDirs.RRAinverse_dynamics_setup = [trialDirs.RRA fp 'setup_ID.xml'];
trialDirs.RRAinverse_dynamics = [trialDirs.RRA fp 'inverse_dynamics.sto'];
trialDirs.RRAsetup_actuation_analyze = [trialDirs.RRA fp 'setup_actuation_analyze.xml'];

trialDirs.JRA =[Dir.JRA fp trialName];
trialDirs.JRAmodel = trialDirs.MAmodel;
trialDirs.JRAexternal_loads_file = trialDirs.IDgrfxml;
trialDirs.JRAkinematics = trialDirs.IKresults;
trialDirs.JRAforcefile = [trialDirs.JRA fp 'forcefile.sto'];
trialDirs.JRAresults = [trialDirs.JRA fp 'JCF_JointReaction_ReactionLoads.sto'];

trialDirs.SO =[Dir.SO fp trialName];
trialDirs.SOmodel = trialDirs.MAmodel;
trialDirs.SOsetup = [trialDirs.SO fp 'setup.xml'];
trialDirs.SOactuators = [trialDirs.SO fp 'actuators.xml'];
trialDirs.SOexternal_loads_file = trialDirs.IDgrfxml;
trialDirs.SOkinematics = trialDirs.IKresults;
trialDirs.SOforceResults = [trialDirs.SO fp trialName '_StaticOptimization_force.sto'];
trialDirs.SOactivationResults = [trialDirs.SO fp trialName '_StaticOptimization_activation.sto'];

trialDirs.MC =[Dir.MC fp trialName];

trialDirs.IAA =[Dir.IAA fp trialName];
trialDirs.IAAmodel = trialDirs.MAmodel;
trialDirs.IAAsetup = [trialDirs.IAA fp 'setup.xml'];
trialDirs.IAAactuators = [trialDirs.IAA fp 'actuators.xml'];
trialDirs.IAAexternal_loads_file = trialDirs.IDgrfxml;
trialDirs.IAAkinematics = trialDirs.IKresults;
trialDirs.IAAkinetics_file = trialDirs.externalforces;
trialDirs.IAAforcefile = [trialDirs.IAA fp 'forcefile.sto'];
trialDirs.IAAresults = [trialDirs.SO fp trialName fp 'IndAccPI_Results'];


if nargin ==3
    f = fields(trialDirs);
    for i = 1:length(f)
        trialDirs.(f{i}) = relativepath(trialDirs.(f{i}),RelPath);
    end
    trialDirs.RelPath = RelPath;
    cd(RelPath)
end