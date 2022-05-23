% generateExecutionXml_BG

function generateExecutionXml_BG (Dir,Temp, CEINMSSettings, SubjectInfo ,trialList)

fp = filesep;

if ~exist(CEINMSSettings.excitationGeneratorFilename)
    copyfile(Temp.CEINMSexcitationGenerator,CEINMSSettings.excitationGeneratorFilename)
end

[~,Adjusted,Synt] = createExcitationGenerator_FAIS(Dir,CEINMSSettings,SubjectInfo);
% generate the execution configuration xml
writeExecutionCFGxml_BG(CEINMSSettings.nmsModel_exe, Temp.CEINMScfgExe,CEINMSSettings.exeCfg, CEINMSSettings.dofList,Adjusted,Synt)

% generate the execution setup xml (one for each trial)
for ii = 1: length(trialList)

    trialName = strrep(split(trialList{ii},fp),'.xml','');
    trialName = trialName{end};
    setupxml = xml_read(Temp.CEINMSsetupExe);   %from loadSubjectInfo.m
    setupxml.subjectFile = relativepath(CEINMSSettings.outputSubjectFilename, Dir.CEINMSsetup);
    setupxml.inputDataFile = relativepath([Dir.CEINMStrials fp trialName '.xml'],Dir.CEINMSsetup);
    setupxml.outputDirectory = relativepath([Dir.CEINMSsimulations fp trialName], Dir.CEINMSsetup);
    setupxml.executionFile = relativepath(CEINMSSettings.exeCfg, Dir.CEINMSsetup);
    setupxml.excitationGeneratorFile =  relativepath(CEINMSSettings.excitationGeneratorFilename, Dir.CEINMSsetup);
        
    Pref.StructItem = false;
    cd(Dir.CEINMSsetup)
    xml_write([trialName '.xml'], setupxml, 'ceinms' ,Pref);
end

disp('CEINMS files created - time for CALIBRATIOOOOOOON')

