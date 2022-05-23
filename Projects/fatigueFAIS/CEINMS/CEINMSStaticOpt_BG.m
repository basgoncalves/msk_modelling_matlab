

%% THIS FUNCTION IS MEANT TO RUN MULTIPLE TRIALS IN CEINMS TO ALLOW FOR A FASTER EXECUTION

function CEINMSStaticOpt_BG (Dir,CEINMSSettings,SubjectInfo,trialList)

fp = filesep;

trials=dir(Dir.CEINMStrials);
trials(1:2) =[];
CalCFG = xml_read(CEINMSSettings.calibrationCfg);
CalTrials = CalCFG.trialSet;

if ~exist(Dir.CEINMSsimulations)
    mkdir(Dir.CEINMSsimulations)
end

for k = 1:length(trialList)
    
    if sum(contains(strrep({trials.name},'.xml',''),trialList{k}))<1
        continue
    elseif contains(CalTrials,trialList{k})
        continue
    end
    %     edit strength coefficent values or max velocit of the model to troubleshoot
    %     ADD =5;HMS =5;GLU=5;HFL=5;VAS=5;ANK=5;OTHER=5;
    %     EditCalibratedSubject(CEINMSSettings.outputSubjectFilename,ADD,HMS,GLU,HFL,VAS,ANK,OTHER)
    %     ADD =10000;HMS =10000;GLU=10000;HFL=10000;VAS=10000;ANK=10000;OTHER=10000;
    %     EditMaxVelovityCalibratedSubject(CEINMSSettings.outputSubjectFilename,ADD,HMS,GLU,HFL,VAS,ANK,OTHER)
    
    if ~exist([Dir.CEINMScalibration fp 'StrengthCoeficients.jpeg'])
        CheckCalibratedValues(CEINMSSettings.outputSubjectFilename,...
            CEINMSSettings.subjectFilename,SubjectInfo.TestedLeg)
    end
    copyfile([Dir.CEINMScalibration fp 'StrengthCoeficients.jpeg'],Dir.CEINMSsimulations)
    
    createExcitationGeneratorStaticOpt_FAIS(CEINMSSettings)
    
    A= 1; B=2; G=0;
    CEINMSexe_BG (Dir,CEINMSSettings,trialList{k},A,B,G);
    
    SimulationDir = [Dir.CEINMSsimulations fp trialList{k}];
    OptimalGamma= struct;
    OptimalGamma.Alpha = A;
    OptimalGamma.Beta = B;
    OptimalGamma.Gamma_MinDiff = 0;
    OptimalGamma.DirDiff = [Dir.CEINMSsimulations fp trialList{k} fp 'A1_B2_G0'];
    OptimalGamma.Gamma_MinSum = 0;
    OptimalGamma.DirSum = [Dir.CEINMSsimulations fp trialList{k} fp 'A1_B2_G0'];
    cd(SimulationDir)
    save OptimalGamma OptimalGamma
    
    PlotCEINMSresults(Dir,CEINMSSettings,SubjectInfo,SimulationDir)
end

cmdmsg('EXE finished ')
