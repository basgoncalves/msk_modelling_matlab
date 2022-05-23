% batch MOtoNMS


function CheckSubjects = BatchMOtoNMS_FAI_BG (Subjects)

fp = filesep;
CheckSubjects ={};
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials,Fcut] = getdirFAI(Subjects{ff});
    
    if isempty(fields(SubjectInfo));continue
    else; SJ = GaitEventsMultiple(Subjects(ff));
        if length(SJ) > 1 
            CheckSubjects{end+1} = SJ;
            Trials.Dynamic = Trials.Dynamic(~contains(Trials.Dynamic,SJ));
        end
    end
    updateLogAnalysis(Dir,'MOtoNMS',SubjectInfo,'start')
    
    AcquisitionInterface_BG(Dir,Temp,SubjectInfo,Trials);                               % create acquisition xml
    copyfile([Dir.Input fp 'acquisition.xml'],[Dir.Elaborated fp 'acquisition.xml'])  % create a copy in /ElaboratedData/Subject/
    elaborationFileCreation_BG(Dir,Temp,Fcut,Trials);                                    % run dynamic elaboration
%     runDataProcessing_BG_EMGOnly(Dir.dynamicElaborations,Fcut)
    runDataProcessing_BG(Dir.dynamicElaborations,Fcut)

    % Change VL and RF for participant 060 only
    if contains(SubjectInfo.ID,'060');  AdjustEMGNamesParticipant060;  end

    updateLogAnalysis(Dir,'MOtoNMS',SubjectInfo,'end')
end
cmdmsg(['MOtoNMS complete'])
