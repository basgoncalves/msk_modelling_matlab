

%% THIS FUNCTION IS MEANT TO RUN MULTIPLE TRIALS IN CEINMS TO ALLOW FOR A FASTER EXECUTION

function CEINMSmultipleTrials_BG (Dir,CEINMSSettings,SubjectInfo,trialList,Logic)

fp = filesep;

updateLogAnalysis(Dir,'CEINMS exe',SubjectInfo,'start')% print log

trials=dir(Dir.CEINMStrials); trials(1:2) =[];
CalCFG = xml_read(CEINMSSettings.calibrationCfg);
CalTrials = CalCFG.trialSet;

if ~exist(Dir.CEINMSsimulations);mkdir(Dir.CEINMSsimulations);end

for trial=trialList'
    
    if sum(contains(strrep({trials.name},'.xml',''),trial{1}))<1; continue
    elseif contains(CalTrials,trial{1}); continue
    elseif Logic==2&&exist([Dir.CEINMSsimulations fp trial{1} fp 'OptimalSettings.mat']); continue; end
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
    
    for A = CEINMSSettings.Alphas
        for B = CEINMSSettings.Betas
            for G = CEINMSSettings.Gammas
                CEINMSexe_BG (Dir,CEINMSSettings,trial{1},A,B,G);      
            end
        end
    end
    cd(Dir.CEINMSsimulations)
    SimulationDir = [Dir.CEINMSsimulations fp trial{1}];
    OptimalSettings = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);  % set up to choose best values from the current iterations 
    %CEINMSexe_BG (Dir,CEINMSSettings,trial{1},OptimalSettings.Alpha,OptimalSettings.Beta,OptimalSettings.Gamma);
    %PlotCEINMSresults(Dir,CEINMSSettings,SubjectInfo,SimulationDir)
    Origin = [SimulationDir fp sprintf('AlphaA%.f BetaB%.f_OptimalGamma.jpeg',OptimalSettings.Alpha,OptimalSettings.Beta)];
    Destination = [Dir.Results_OptimalGamma fp SubjectInfo.ID '_' trial{1} '.jpeg'];
    copyfile(Origin,Destination)
    
end

updateLogAnalysis(Dir,'CEINMS exe',SubjectInfo,'end')% print log
cmdmsg('EXE finished ')

