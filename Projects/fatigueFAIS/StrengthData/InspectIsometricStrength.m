%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% 
% inspect the force and EMG from the isometric trials from the c3d files

function InspectIsometricStrength(Subjects)

fp = filesep;
Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post'};

[SubjectFoldersInputData,~] = smfai(Subjects);
[Dir,~,~,~] = getdirFAI(SubjectFoldersInputData{1});
saveDir = [Dir.Results fp 'HipIsometric' fp 'indivudalTrials']; mkdir(saveDir);

for ff = 1:length(SubjectFoldersInputData)
    
    [Dir,~,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{ff});
    if isempty(Trials.Isometrics_pre) || isempty(fields(SubjectInfo)); continue; end
    
    updateLogAnalysis(Dir,'Inspect Isometrics',SubjectInfo,'start')
    
    [ha, ~] = tight_subplotBG(5,4,0.02,0.01,0.05,[107 76 1728 895]);
    
    %pre force values 
    [~,~,groups] = getTrialType_multiple(Trials.Isometrics_pre);
    forceData = loadRigForceFromC3D(Dir.Input,Trials.Isometrics_pre);
    
    for i = 1:length(Isometrics_pre)
            idx = find(groups == i)';         
            plot(ha(i),forceData(:,idx))
            legend(ha(i),Trials.Isometrics_pre(idx))
    end
    
    % post force values 
    [~,~,groups] = getTrialType_multiple(Trials.Isometrics_post);
    forceData = loadRigForceFromC3D(Dir.Input,Trials.Isometrics_post);
     for i = 1:length(Isometrics_post)
            idx = find(groups == i)'; 
            nplot = i+length(Isometrics_pre);
            plot(ha(nplot),forceData(:,idx))
            legend(ha(nplot),Trials.Isometrics_post(idx))
            set(ha(nplot),'color',[0.9 0.9 0.9]);
     end
     
    set(gcf, 'InvertHardcopy', 'off');
    saveas(gcf,[saveDir fp SubjectInfo.ID '.jpeg'])
    close (gcf)
    updateLogAnalysis(Dir,'Inspect Isometrics',SubjectInfo,'end')
    
    clear idx forceData ha i nplot pos trialType SubjectInfo Trilas
end