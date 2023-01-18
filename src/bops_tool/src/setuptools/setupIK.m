
function setupIK

bops    = load_setup_bops;

% if current subject or session do not exist, use the first in the list 
if ~exist([bops.directories.InputData fp bops.current.subject fp bops.current.session])
    bops.current.subject = bops.subjects{1};
    bops.current.session = bops.sessions{1};  
end

subject = load_subject_settings(bops.current.subject,bops.current.session,'SetupIK');

IK_setup_filepath    = bops.directories.templates.IKSetup;
elaboration_filepath = subject.directories.elaborationXML;

setupIKTool_BOPS(IK_setup_filepath,elaboration_filepath)