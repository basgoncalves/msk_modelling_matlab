function Best = CheckBestItrCEINMS(SubjectFoldersElaborated, sessionName,suffix)


fp = filesep;
warning off
Best = {'Subj' 'trialName' 'OptimalGamma'};
%% loop through all participants
for Subj = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{Subj},sessionName,suffix);
    cmdmsg(['Checking data participant ' SubjectInfo.ID])
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
   
    dofList = split(CEINMSSettings.dofList ,' ')';
    S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);
    
    %% loop through all trials in the list and store data in struct
    for tt = 1:length(Trials.CEINMS)%[length(Files)-1,length(Files)-2]
        
        trialName = Trials.CEINMS{tt};
        SimulationDir = [Dir.CEINMSsimulations fp trialName];
        
        if length(dir(SimulationDir))<3
            continue
        end
        warning off
        osimFiles = getosimfilesFAI(Dir,trialName); % also creates the directories
        BestItr = load([SimulationDir fp 'OptimalGamma.mat']);
        BestItrDir = BestItr.OptimalGamma.DirDiff;
        [RMSE,R2] = CEINMS_errors(osimFiles.emg,osimFiles.IDRRAresults,BestItrDir,...
            CEINMSSettings.excitationGeneratorFilename,CEINMSSettings.exeCfg,S.DOFmuscles);
        
       
        Best{end+1,1}= (['s' SubjectInfo.ID]); 
        Best{end,2}= trialName; 
        Best{end,3} = BestItr.OptimalGamma.Gamma_MinDiff;
        cols = [4 10 16];
        %hip
        for e = 1: length(dofList)
            Best{1,cols(e)} = 'RMSE Mom';
            Best{end,cols(e)} = RMSE.mom.(dofList{e});
            
            Best{1,cols(e)+1} = 'RMSE exc';
            Best{end,cols(e)+1} = mean(RMSE.exc.(dofList{e}));
            
            Best{1,cols(e)+2} = 'RMSE Mom per range';
            Best{end,cols(e)+2} = RMSE.momPerRange.(dofList{e});
            
            Best{1,cols(e)+3}= 'RMSE exc per range';
            Best{end,cols(e)+3}= mean(RMSE.excPerRange.(dofList{e}));
            
            Best{1,cols(e)+4} = 'R2 Mom';
            Best{end,cols(e)+4} = R2.mom.(dofList{e});
            
            Best{1,cols(e)+5} = 'R2 exc';
            Best{end,cols(e)+5} = mean(R2.exc.(dofList{e}));
        end
 
    end  

end
