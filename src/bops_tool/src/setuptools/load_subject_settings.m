% if empty just load subject settings based on the "current" field of bops settings
% if includes subject and session, updates bops settings
function [subjectSettings] = load_subject_settings(subject,session,analysis)

bops = load_setup_bops;
if ~exist('subject','var')
    subject = bops.current.subject;
end

if ~exist('session','var')
    session = bops.current.session;
end

if ~exist('analysis','var')
    analysis = bops.current.analysis;
end

if ~isequal(bops.current.subject,subject) || ~isequal(bops.current.subject,session)
    bops.current.subject    = subject;
    bops.current.session    = session;
    bops.current.analysis   = analysis;
    Pref.StructItem         = false;
    xml_write(bops.directories.setupbopsXML,bops,'bops',Pref);
end
settingsfiledir = [bops.directories.ElaboratedData fp subject fp session fp 'settings.xml'];

sessionInput = [bops.directories.InputData fp subject fp session];
sessionElaborated = [bops.directories.ElaboratedData fp subject fp session];

if ~exist(sessionInput,'dir') && ~exist(sessionElaborated,'dir')
    subjectSettings = [];
    return
end

settingsXML = dir(settingsfiledir);
subjectCSV = dir(bops.directories.subjectInfoCSV);
if isfile(settingsfiledir) && settingsXML.datenum > subjectCSV.datenum                                              % if subject xml file exists AND is more recent than subjects CSV
    subjectSettings = xml_read(settingsfiledir);                                                                    % load file 

    if ~isequal(subjectSettings.directories.Elaborated,bops.directories.ElaboratedData)
        subjectSettings = setupSubject(subject,session);
    end

    trialList                          = subjectSettings.trials.names;
    subjectSettings.trials.dynamic     = trialList(contains(trialList,split(bops.Trials.Dynamic)));
    subjectSettings.trials.static      = trialList(contains(trialList,split(bops.Trials.Static)));
    subjectSettings.trials.maxEMG      = trialList(contains(trialList,split(bops.Trials.MaxEMG)));
    
else
    warning on
    warning ('subject settings does not exist. Creating file now...')                       
    subjectSettings = setupSubject(subject,session);                                                                % create subject settings from scratch 
end

