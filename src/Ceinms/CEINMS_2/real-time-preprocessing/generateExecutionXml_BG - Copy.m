
% generateExecutionXml_BG

function generateExecutionXml_BG (trialsDir,trialList, nmsModel_exe, cfgExeDir,...
setupExeDir, side, exeDir, pref, subjectFilename,excitationGeneratorFilename, dofList)

fp = filesep;
exeName = split(cfgExeDir,fp);
exeName = exeName{end};
fileOut_cfg = [exeDir fp 'Cfg' fp exeName];


% generate the execution configuration xml
writeExecutionCFGxml_BG(nmsModel_exe, cfgExeDir, side, fileOut_cfg, pref, dofList,trialList)

for ii = 1: length(trialList)

    trialName = split(trialList{ii},fp);
    trialName =  strrep(trialName{end},'.xml','');

    % generate the execution setup xml
    
    setupxml = xml_read(setupExeDir);   %from loadSubjectInfo.m
    setupxml.subjectFile = subjectFilename;
    setupxml.inputDataFile = [trialsDir fp trialName '.xml'];
    setupxml.outputDirectory =[exeDir fp 'simulations' fp trialName]; % remove '.xml'
    setupxml.executionFile = fileOut_cfg;
    setupxml.excitationGeneratorFile =  excitationGeneratorFilename;
    
    fileOut_setup = [exeDir fp 'Setup'];
    mkdir(fileOut_setup)
    root = 'ceinms';
    Pref.StructItem = false;
    cd(fileOut_setup)
    
    xml_write([trialName '.xml'], setupxml, root ,Pref);
end

msgbox(sprintf('you are %s','GAYYYYYYYYYYYYY'))
