% rearrage CEINMS directories


for ff = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{ff},sessionName,suffix);
    Param = CEINMSsetup_FAI(Dir,Temp,SubjectInfo,Trials);
    oldCalibratedSubj = [Dir.CEINMScalibration fp 'calibrated' fp 'calibratedSubject.xml'];
    outFile = [Dir.CEINMScalibration fp 'calibrated' fp 'out.log'];
    errFile = [Dir.CEINMScalibration fp 'calibrated' fp 'err.log'];
    strCoef = [Dir.CEINMScalibration fp 'calibrated' fp 'StrengthCoeficients.jpeg'];
    setupfile = [Dir.CEINMScalibration fp 'setup' fp 'calibrationSetup.xml'];
    cfgfile = [Dir.CEINMScalibration fp 'cfg' fp 'calibrationCfg.xml'];
    cd (Dir.CEINMScalibration)
    cmdmsg(['reordering data for participant ' SubjectInfo.ID])
    if exist ([Dir.CEINMS fp 'excitationGeneration'])
        rmdir([Dir.CEINMS fp 'excitationGeneration'])
    end
    
    if exist (oldCalibratedSubj)
        movefile(oldCalibratedSubj,Param.outputSubjectFilename)
    end
    if exist (outFile)
        movefile(outFile,Dir.CEINMScalibration)
    end
    if exist (errFile)
        movefile(errFile,Dir.CEINMScalibration)
    end
    if exist (strCoef)
        movefile(strCoef,Dir.CEINMScalibration)
    end
    if exist (setupfile)
        movefile(setupfile,Dir.CEINMScalibration)
    end
    if exist (cfgfile)
        movefile(cfgfile,Dir.CEINMScalibration)
    end
    
    % delete
    if exist ([Dir.CEINMScalibration fp 'calibrated'])
        rmdir ([Dir.CEINMScalibration fp 'calibrated'])
    end
    if exist ([Dir.CEINMScalibration fp 'cfg'])
        rmdir ([Dir.CEINMScalibration fp 'cfg'])
    end
    if exist ([Dir.CEINMScalibration fp 'setup'])
        rmdir ([Dir.CEINMScalibration fp 'setup'])
    end
    if exist ([Dir.CEINMScalibration fp 'uncalibrated'])
        delete([Dir.CEINMScalibration fp 'uncalibrated' fp 'uncalibrated.xml'])
        rmdir ([Dir.CEINMScalibration fp 'uncalibrated'])
    end
end

