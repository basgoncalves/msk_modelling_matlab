% Create inverse dynamics xml and run ID OS for each trial
%  after creating inverse kinematics
% Goncalves, BM (2021)

function ResidualReductionAnalysis_FAI(Dir, Temp, SubjectInfo, trialName,Logic)

% create directories
fp = filesep;
DirRRAtrial = [Dir.RRA fp trialName]; mkdir(DirRRAtrial);

[TimeWindow,~,FootContact] = TimeWindow_FatFAIS(Dir,trialName);
if contains(trialName,'run','IgnoreCase',1)
    initialTime=FootContact.time; finalTime=TimeWindow(2);
elseif contains(trialName,'walk','IgnoreCase',1)
    initialTime=TimeWindow(1); finalTime=FootContact.time;
end

[osimFiles] = getosimfilesFAI(Dir,trialName,DirRRAtrial); % also creates the directories

if Logic==1 || ~exist(osimFiles.RRAkinematics)
    
    cd(DirRRAtrial)
    copyfile(osimFiles.coordinates,osimFiles.RRA)
    copyfile(osimFiles.externalforces,osimFiles.RRA)
    copyfile(Temp.RRATaks,osimFiles.RRAtasks)
    copyfile(Temp.RRAActuators,osimFiles.RRAactuators)
    copyfile(Temp.RRASetup,osimFiles.RRAsetup)
    
    %% adjust xml for each tiral (modify if needed)
    % adjustTaskXML(TaskFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
    adjustTaskXML(osimFiles.RRAtasks,100,100,100,1,1,1,1,100)
    % adjustActuatorXML(ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
    adjustActuatorXML(osimFiles.RRAactuators,1000,1000,1000,1000,500,500,500,1)
    
    %% RRA setup xml
    RRAxml = xml_read(osimFiles.RRAsetup);
    RRAxml.RRATool.model_file = osimFiles.LinearScaledModel;
    RRAxml.RRATool.ATTRIBUTE.name = trialName;
    RRAxml.RRATool.replace_force_set = 'true';
    RRAxml.RRATool.results_directory = osimFiles.RRA;
    RRAxml.RRATool.output_precision = 16;
    RRAxml.RRATool.desired_kinematics_file = osimFiles.RRAdesired_kinematics_file;
    RRAxml.RRATool.external_loads_file = osimFiles.RRAexternal_loads_file;
    RRAxml.RRATool.force_set_files = osimFiles.RRAactuators;
    RRAxml.RRATool.lowpass_cutoff_frequency = 6;
    RRAxml.RRATool.task_set_file = osimFiles.RRAtasks;
    RRAxml.RRATool.output_model_file = osimFiles.RRAmodel;
    RRAxml.RRATool.adjust_com_to_reduce_residuals = 'true';
    RRAxml.RRATool.adjusted_com_body = 'torso';
    RRAxml.RRATool.initial_time =initialTime;
    RRAxml.RRATool.final_time = finalTime;
    RRAxml.RRATool.initial_time_for_com_adjustment = initialTime;
    RRAxml.RRATool.final_time_for_com_adjustment = finalTime;
    
    % tranform these from double to string
    RRAxml.RRATool.defaults.CMC_Joint.active = ['false ' 'false ' 'false'];
    RRAxml.RRATool.defaults.PointActuator.point = ['0 ' '0 ' '0'];
    RRAxml.RRATool.defaults.PointActuator.direction = ['-1 ' '0 ' '0'];
    RRAxml.RRATool.defaults.TorqueActuator.axis = ['-1 ' '-0 ' '-0'];
    
    root = 'OpenSimDocument';
    xml_write(osimFiles.RRAsetup, RRAxml,root);
    
    %% plot time window
    s = lower(SubjectInfo.TestedLeg);
    [IDData,Labels] = LoadResults_BG (osimFiles.IDresults,TimeWindow,{'time',['ankle_angle_' s '_moment']},1,1);              % load ID data
    figure; hold on
    plot(IDData(:,1),IDData(:,2)); 
    plotVert(initialTime); plotVert(finalTime); 
    title([SubjectInfo.ID '_' trialName],'interpreter','none');
    legend({'ankle moment' 'intiial time' 'final time'});mmfn_inspect
    warning off; mkdir([Dir.Results fp 'RRA' fp 'EventTimes']);
    saveas(gcf,[Dir.Results fp 'RRA' fp 'EventTimes' fp SubjectInfo.ID '_' trialName '.jpeg'])
    close all
    %% run RRA
    import org.opensim.modeling.*
    cd(osimFiles.RelPath); [~,log_mes]=dos(['rra -S  ', osimFiles.RRAsetup]);
    disp([trialName ' RRA Done.']);
    
end

% run ID post RRA
copyfile(osimFiles.IDsetup,osimFiles.RRAinverse_dynamics_setup)
% 
% IKrra = load_sto_file(osimFiles.RRAkinematics); % resample the time range of kinematics so the ID doesn't become too slow
% IKrra.time = round(IKrra.time,5);
% write_sto_file_SO(IKrra, osimFiles.RRAkinematics);

IDxml = xml_read([osimFiles.RRAinverse_dynamics_setup]);
IDxml.InverseDynamicsTool.model_file = osimFiles.RRAmodel;
IDxml.InverseDynamicsTool.coordinates_file = osimFiles.RRAkinematics;
IDxml.InverseDynamicsTool.external_loads_file = osimFiles.RRAexternal_loads_file;
IDxml.InverseDynamicsTool.time_range = [initialTime finalTime];

xml_write(osimFiles.RRAinverse_dynamics_setup,IDxml,'OpenSimDocument');

copyfile([osimFiles.RRA 'out.log'], [osimFiles.RRA 'out_rra.log'])          % create a copy of the RRA out file

[~,log_mes_id]=dos(['id -S  ', osimFiles.RRAinverse_dynamics_setup]);       % ID with RRA kinematics
copyfile([osimFiles.RRA 'out_rra.log'], [osimFiles.RRA 'out.log'])          % replace the out file created by ID for the RRA one
delete([osimFiles.RRA 'out_rra.log'])

disp([trialName ' ID with rra kinematics done']);

plotTrialRRA(Dir,SubjectInfo,trialName)
close all

copyfile(Temp.RRASetup_actuation_analyze,osimFiles.RRAsetup_actuation_analyze)
analyzeTool=AnalyzeTool(osimFiles.RRAsetup_actuation_analyze);



