% batch joint reaction analysis BG 2020
% Logic = 1 (default); 1 = re-run trials / 0 = do not re-run trials
function BatchJRA_FAI_BG (Subjects,Logic)
fp = filesep;

for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    files = dir(Dir.CEINMSsimulations); files(1:2) = [];
    if isempty(files); continue; end
    
    updateLogAnalysis(Dir,'JointReactionAnalysis',SubjectInfo,'start')
    disp(SubjectInfo.ID)
    trialList = Trials.CEINMS;   
    for ii = 1:length(trialList)
        
        trialName = trialList{ii};
        fprintf([trialName '...'])
        if sum(contains({files.name},trialName))==0 || length(dir([Dir.CEINMSsimulations fp trialName]))<3
            continue
        end
        
        osimFiles = getosimfilesFAI(Dir,trialName); % also creates the directories
        mkdir(osimFiles.JRA)
        
        if ~exist(osimFiles.SOforceResults); runSO_BG(Dir, Temp, trialName); end
        
        % find the CEINMS simulation with lowest EMG and Mom track errors
        OptimalSettings = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
        CEINMS_trialDir = OptimalSettings.Dir;
       
        JRAforcefile(CEINMS_trialDir,osimFiles,osimFiles.JRAforcefile)
        
        dofList = split(CEINMSSettings.dofList ,' ')';
        cd(osimFiles.JRA)
        % Run JRA
        if exist(osimFiles.JRAresults)
            movefile(osimFiles.JRAresults,strrep(osimFiles.JRAresults,'.sto','_child.sto'))
        end
        
        if Logic==1 || ~exist(osimFiles.JRAresults)
           
            outputDir = runJRA_BG(osimFiles.JRAmodel,osimFiles.JRAkinematics,...
                osimFiles.JRAexternal_loads_file,osimFiles.JRAforcefile,...
                dofList,osimFiles.JRA,Temp.JRAsetup);
            
            fprintf('done \n')
            plotJRA_BG(Dir,CEINMSSettings,SubjectInfo,outputDir)
%             disp(['| plots saved in ' outputDir ' \n' ])
            close all
            
        end
        
    end
    updateLogAnalysis(Dir,'JointReactionAnalysis',SubjectInfo,'end') 
     
end

cmdmsg('Joint reaction analysis finished ')

