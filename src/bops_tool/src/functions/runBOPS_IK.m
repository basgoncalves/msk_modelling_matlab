% Setup Inverse kinematiks Basilio Goncalves 2019

function runBOPS_IK (elaboration_xml)

warning off
accuracy = 10*10.^-7;
bops    =  load_setup_bops;
subject = load_subject_settings;
if nargin < 1
    elaboration_xml = subject.directories.elaborationXML;
end

elab        = xml_read(elaboration_xml);                                                                            % load elaboration xml
acq         = xml_read(subject.directories.acquisitionXML);                                                         % load acq xml
trialList   = split(elab.Trials,' ')';                                                                              % get trials from xml
param       = parametersGeneration(elab);

rerun       = bops.current.rerun;
for i = 1:length(trialList)
    
    trialName = trialList{i};
    TimeWindow = param.WindowsSelection.Events{i} ./ acq.VideoFrameRate;
    
    trialAnalysisPath = [subject.directories.IK fp trialName]; 
    mkdir(trialAnalysisPath); 
    cd(trialAnalysisPath)
    
    [osimFiles] = getdirosimfiles_BOPS(Dir,trialName,[Dir.IK fp trialName]);                                        % get directories of opensim files for this trial
    
    if rerun==0 && exist(osimFiles.IKresults); return; end
    
    copyfile(osimFiles.coordinates,trialAnalysisPath)                                                               % copy files from the dynamic elaboration folder
    copyfile(osimFiles.externalforces,trialAnalysisPath)                                                            % usefull for checking data in the gui easier
    
    IK = xml_read(bops.directories.templates.IKSetup);                                                              % Edit xml file
    IK.InverseKinematicsTool.COMMENT = {};
    IK.InverseKinematicsTool.ATTRIBUTE.name = trialName;
    IK.InverseKinematicsTool.time_range = TimeWindow;
    IK.InverseKinematicsTool.marker_file = osimFiles.IKcoordinates;
    IK.InverseKinematicsTool.model_file = osimFiles.LinearScaledModel;
    IK.InverseKinematicsTool.output_motion_file = osimFiles.IKresults;
    IK.InverseKinematicsTool.results_directory = osimFiles.IK;
    IK.InverseKinematicsTool.accuracy = accuracy;
    
    usedMarkers = regexp(elab.Markers,' ','split')';                                                                % comapre markerset from elab xml with data from trial
    xmlMarkers = IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask;
    for m = 1: length (xmlMarkers)
        nameMarker = xmlMarkers(m).ATTRIBUTE.name;
        if  isempty(find(strcmp(nameMarker, usedMarkers), 1))                                                       % if marker does not exist in current trial
            xmlMarkers(m).apply = 'false';                                                                          % assign to false in the setup ik xml
        else
            xmlMarkers(m).apply = 'true';
        end
    end
    IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask= xmlMarkers;
    
    cd(trialAnalysisPath)                                                                                            % write xml and save gait cycle events

    root = 'OpenSimDocument';
    Pref.StructItem = false;
    xml_write(osimFiles.IKsetup, IK, root,Pref);
    
    import org.opensim.modeling.*
    dos(['ik -S ' osimFiles.IKsetup],'-echo')                                                                       % run analysis
    
end

cmdmsg('IK finished')