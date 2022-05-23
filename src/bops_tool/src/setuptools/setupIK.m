
function setupIK

bops    = load_setup_bops;
subject = load_subject_settings;

IK_setup_filepath    = bops.directories.templates.IKSetup;
elaboration_filepath = subject.directories.elaborationXML;

setupIKTool_BOPS(IK_setup_filepath,elaboration_filepath)