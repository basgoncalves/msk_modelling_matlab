% Setup Inverse Dynamics Basilio Goncalves 2022

function runBOPS_ID (elaboration_xml)

bops    =  load_setup_bops;
subject = load_subject_settings;
if nargin < 1
    elaboration_xml = subject.directories.elaborationXML;
end

elab        = xml_read(elaboration_xml);                                                                            % load elaboration xml
acq         = xml_read(subject.directories.acquisitionXML);                                                         % load acq xml
trialList   = split(elab.Trials,' ')';                                                                              % get trials from xml
param       = parametersGeneration(elab);                                                                           % get parameters from elaboration XML
tempSetup   = bops.directories.templates.IDSetup;

rerun       = bops.current.rerun;
for i = 1:length(trialList)
    
    trialName = trialList{i};
    TimeWindow = param.WindowsSelection.Events{i} ./ acq.VideoFrameRate;
    
    trialAnalysisPath = [subject.directories.ID fp trialName];                                                      % DEFINE ANALYSIS PATH
    mkdir(trialAnalysisPath);
    cd(trialAnalysisPath)
    
    [osimFiles] = getdirosimfiles_BOPS(trialName,trialAnalysisPath);                                                % get directories of opensim files for this trial
    
    if rerun==0 && exist(osimFiles.IKresults); return; end
    
    copyfile(osimFiles.coordinates,trialAnalysisPath)                                                               % copy files from the dynamic elaboration folder
    copyfile(osimFiles.externalforces,trialAnalysisPath)                                                            % usefull for checking data in the gui easier
    copyfile(osimFiles.IKresults,trialAnalysisPath)
    
    %% set GRF xml
    GRFxml              = xml_read(bops.directories.templates.GRF);
    nForcePlates        = length(GRFxml.ExternalLoads.objects.ExternalForce);
    deleteForcePlates   =[];
    
    fld = find(strcmp({acq.Trials.Trial.Type},trialName));
    StanceOnFP = acq.Trials.Trial(fld).StancesOnForcePlatforms.StanceOnFP;
    
    for FP = 1:nForcePlates
        if length(StanceOnFP)< FP  || contains(StanceOnFP(FP).leg,'-')
            deleteForcePlates (end+1) = FP;
            continue
        end
        GRFxml.ExternalLoads.objects.ExternalForce(FP).ATTRIBUTE.name = StanceOnFP(FP).leg;
        GRFxml.ExternalLoads.objects.ExternalForce(FP).applied_to_body =  ['calcn_' lower(StanceOnFP(FP).leg(1))];
    end
    GRFxml.ExternalLoads.objects.ExternalForce(deleteForcePlates)= [];
    GRFxml.ExternalLoads.datafile = osimFiles.IDexternalforces;
    GRFxml.ExternalLoads.external_loads_model_kinematics_file = osimFiles.IDcoordinates;
    
    root = 'OpenSimDocument';
    Pref.StructItem = false;
    xml_write(osimFiles.IDgrfxml, GRFxml, root,Pref);
    
    %% edit setup xml 
    XML                                             = xml_read(tempSetup);                                         
    XML.InverseDynamicsTool.COMMENT                 = {};
    XML.InverseDynamicsTool.ATTRIBUTE.name          = trialName;
    XML.InverseDynamicsTool.results_directory       = osimFiles.ID;
    XML.InverseDynamicsTool.time_range              = TimeWindow;
    XML.InverseDynamicsTool.coordinates_file        = osimFiles.IDcoordinates;
    XML.InverseDynamicsTool.output_gen_force_file   = osimFiles.IDresults;
    XML.InverseDynamicsTool.model_file              = osimFiles.LinearScaledModel;
    XML.InverseDynamicsTool.external_loads_file     = osimFiles.IDgrfxml;
    
    xml_write(osimFiles.IDsetup, XML, root,Pref);
    
    import org.opensim.modeling.*
    [~,log_mes] = dos(['id -S ' osimFiles.IDsetup],'-echo');                                                        % run analysis
    disp([trialName ' ID Done.']);
    
end

cmdmsg(['ID finished: ' bops.current.subject ' - ' bops.current.session])