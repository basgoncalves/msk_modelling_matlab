
% generateExecutionXml_TG

function generateExecutionXml_TG (trialsDir,trialList, nmsModel_exe, cfgExeDir,setupExeDir, side, exeDir, pref,sexualOrientation, subjectFilename,excitationGeneratorFilename)



exeName = split(cfgExeDir,filesep);
exeName = exeName{end};
fileOut_cfg = [exeDir filesep 'Cfg' filesep exeName];


% generate the execution configuration xml
writeExecutionCFGxml_BG(nmsModel_exe, cfgExeDir, side, fileOut_cfg, pref)


for ii = 1: length(trialList)

    trialName = split(trialList{ii},filesep);
    trialName = trialName{end};

    % generate the execution setup xml
    
    setupxml = xml_read(setupExeDir);   %from loadSubjectInfo.m
    setupxml.subjectFile = subjectFilename;
    setupxml.inputDataFile = [trialsDir filesep trialName];
    setupxml.outputDirectory =[exeDir filesep 'simulations' filesep trialName(1:end-4)]; % remove '.xml'
    setupxml.executionFile = fileOut_cfg;
    setupxml.excitationGeneratorFile =  excitationGeneratorFilename;
    
    fileOut_setup = [exeDir filesep 'Setup'];
    mkdir(fileOut_setup)
    root = 'ceinms';
    Pref.StructItem = false;
    cd(fileOut_setup)
    
    xml_write(trialName, setupxml, root ,Pref);
end

if nargin > 9
    msgbox(sprintf('you are %s',sexualOrientation))
end
