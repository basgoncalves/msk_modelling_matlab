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

if isfile(settingsfiledir)
    subjectSettings = xml_read(settingsfiledir);
else
    warning on
    warning ('subject settings does not exist. Creating file now...')
    subjectSettings = setupSubject(subject,session);
end

