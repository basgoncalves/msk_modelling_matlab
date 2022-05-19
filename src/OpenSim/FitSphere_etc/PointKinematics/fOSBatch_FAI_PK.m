% run PointKinematics
clear;
addpath(genpath('C:\Users\s5165186\Documents\repos\opensim_pipeline\DataProcessing-scripts'))
% addpath(genpath('C:\PhD\repos\OpenSim_pipeline\DataProcessing-scripts\MOtoNMS'))

addpath 'D:\PhD\repos\vectorlocation\stlTools\stlTools\'
idOPENSIM = 'P1_DeepHip2';                               % IK/ID/MA OpenSim folder
k = 1;
% scFac = [0.96142 0.96142 0.96142];%pelvis
subjects = [43, 37, 40, 47, 50, 48, 4, 30, 33, 41, 28, 14];
fp = '\';
for s = 1:length(subjects)
    subj = subjects(s);
    Subj_Code   = num2str(subj,'%.3d');              
    model=['scaled_',Subj_Code,'_DH_strengthAdjusted_opt.osim'];
%     trialListEx = getWalkingTrials(subj);
    if subj == 40
        trialListEx = {'SquatNorm2','SquatNorm4','SquatNorm5'};
    else 
        trialListEx = {'SquatNorm2','SquatNorm3','SquatNorm4','SquatNorm5'};
    end
    dirFolders = directories([]);
    [Dates, LegMeasured, demographs] = getDate(Subj_Code, dirFolders);
    dirSubject = [Subj_Code, fp, Dates, fp];
    dirFolders = directories(dirSubject,idOPENSIM);
    % get acetabulum coordinates for static trial
%     PK_folder = createPKsetup_acetabulumCS(dirFolders, Subj_Code, model);
    % get coordinates mid point acetabulum surface for all trials
    for it = 1:length(trialListEx)
        trial = trialListEx{it};
        folderPK = createPKsetup_trials(dirFolders, Subj_Code, model, trial,LegMeasured);
        runPK(folderPK)
    end
    
end