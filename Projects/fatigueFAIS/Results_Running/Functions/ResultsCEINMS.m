%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Results for PhD paper 2 - Joint work before and after repeated sprints
% written to be used within "OpenSimPipeline_FatFAI.m"
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   OrganiseFAI
%   FindGaitCycle_Running
%   btk_loadc3d
%   TimeNorm
%INPUT
%   SubjectFoldersElaborated = cell vector containing the directories of
%                               the ElaboratedData for all participants
%   sessionName = string with the name of the session
%   Trials = (optional) cell vector
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------

%% Function/Script name
function Results = ResultsCEINMS (CEINMSdir,Trials)
fp = filesep;

if ~exist ('Logic')|| isempty(Logic)
    Logic = 1;
end

%generate subject directories
DirC3D = strrep(DirUp(CEINMSdir,1),'ElaboratedData','InputData');
OrganiseFAI;

Strials = getstrials(DynamicTrials); %
Tnames = DynamicTrials(contains(Strials,Trials));

Results = struct;
Results.CEINMS_mom = struct;
Results.OS_mom = struct;
Results.rmse_mom = struct;
Results.rsq_mom = struct;

Results.CEINMS_exc = struct;
Results.OS_exc = struct;
Results.rmse_exc = struct;
Results.rsq_exc = struct;

Results.CEINMS_mf = struct;

for k = 1:length(Tnames)
    
    
    trialName = Tnames{k};
    % replace static opt forces with CEINMS
    results_directory = [CEINMSdir fp 'execution' fp 'simulations'];
    [BestItr,row,sumErr] = findBestItr(results_directory,trialName);
    CEINMS_trialDir = [BestItr{row,1} fp BestItr{row,2}];
    
    if length(CEINMS_trialDir)<2
       continue 
    end
    %%
    
    [TestedLeg,CL] = findLeg(DirElaborated,trialName);
    [TimeWindow, ~,FootContact] = TimeWindow_FatFAIS(DirC3D,trialName,TestedLeg);
    PercentageFC = (FootContact.time - TimeWindow(1)) /(TimeWindow(2)-TimeWindow(1));
    s = lower(TestedLeg{1});
    coordinates = {['hip_flexion_' s];['hip_adduction_' s];['hip_rotation_' s];['knee_angle_' s];...
        ['ankle_angle_' s]};
    moments = {['hip_flexion_' s '_moment'];['hip_adduction_' s '_moment'];...
        ['hip_rotation_' s '_moment'];['knee_angle_' s '_moment'];['ankle_angle_' s '_moment']};
    CEINMS_moments = {['hip_flexion_' s];['hip_adduction_' s];['hip_rotation_' s];['knee_angle_' s];...
        ['ankle_angle_' s]};
    EMGmuscles = {'        VM','        VL','        RF','       GRA',...
        '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
        '        GL','       TFL','   GLUTMAX'}; % the spaces are part of the names
    CEINMS_muscles = {['vasmed_' s];['vaslat_' s];['recfem_' s];['grac_' s];['tibant_' s];...
        ['addlong_' s];['semiten_' s];['bflh_' s];['gasmed_' s];['gaslat_' s];['tfl_' s];['glmax1_' s]};
    
    results_coordinates = {['hip_flexion'];['hip_adduction'];['hip_rotation'];['knee'];...
        ['ankle']};
    
    
    MatchWord = 1; % 1= yes; 0 = no;
    [ID_os,LabelsID] = LoadResults_BG ([DirID fp trialName fp 'inverse_dynamics.sto'],...
        TimeWindow,moments,MatchWord);
    
    [IK_os,Labels_IK] = LoadResults_BG ([DirIK fp trialName fp 'IK.mot'],...
        TimeWindow,coordinates,MatchWord);
    
    [EMG_os,Labels] = LoadResults_BG ([ElaborationFilePath fp trialName fp 'emg.mot'],...
        TimeWindow,EMGmuscles,MatchWord);
    
    [ID_CEINMS,~] = LoadResults_BG ([CEINMS_trialDir fp 'Torques.sto'],...
        TimeWindow,CEINMS_moments,MatchWord);
    
    [EMG_CEINMS,~] = LoadResults_BG ([CEINMS_trialDir fp 'AdjustedEmgs.sto'],...
        TimeWindow,CEINMS_muscles,0);
    
    [MForce,LabelsMuscles] = LoadResults_BG ([CEINMS_trialDir fp 'MuscleForces.sto'],...
        TimeWindow,CEINMS_muscles,0);
    
    
    [MLength,~] = LoadResults_BG ([CEINMS_trialDir fp 'NormFibreLengths.sto'],...
        TimeWindow,CEINMS_muscles,0);
    
    [MVel,~] = LoadResults_BG ([CEINMS_trialDir fp 'NormFibreVelocities.sto'],...
        TimeWindow,CEINMS_muscles,0);
    
    

    for kk = 1: length(LabelsID)
        x = ID_os(:,kk);
        y = ID_CEINMS(:,kk);
        [r pvalue] = corrcoef(x,y);
        rmse(k,kk) = round(rms(x-y)/range(y)*100,1);
        rsq(k,kk) = round(r(1,2)^2,2);
        
        Results.CEINMS_mom.(results_coordinates{kk})(:,k) = y;
        Results.OS_mom.(results_coordinates{kk})(:,k) = x;
        Results.rmse_mom.(results_coordinates{kk})(:,k) =  rmse(k,kk);
        Results.rsq_mom.(results_coordinates{kk})(:,k) = rsq(k,kk) ;
    end
    
    
    
    for kk = 1: length(LabelsMuscles)
        x = EMG_os(:,kk);
        y = EMG_CEINMS(:,kk);
        [r pvalue] = corrcoef(x,y);
        rmse(k,kk) = round(rms(x-y)/range(y)*100,1);
        rsq(k,kk) = round(r(1,2)^2,2);
        
        Results.CEINMS_exc.(LabelsMuscles{kk})(:,k) = y;
        Results.OS_exc.(LabelsMuscles{kk})(:,k) = x;
        Results.rmse_exc.(LabelsMuscles{kk})(:,k) = rmse(k,kk);
        Results.rsq_exc.(LabelsMuscles{kk})(:,k) = rsq(k,kk) ;
        
        Results.CEINMS_mf.(LabelsMuscles{kk})(:,k) = MForce(:,kk) ;
        Results.CEINMS_ml.(LabelsMuscles{kk})(:,k) = MLength(:,kk) ;
        Results.CEINMS_mv.(LabelsMuscles{kk})(:,k) = MVel(:,kk) ;        
    end
    
    
     plotMuscleForces(CEINMS_trialDir,side)
    
end

