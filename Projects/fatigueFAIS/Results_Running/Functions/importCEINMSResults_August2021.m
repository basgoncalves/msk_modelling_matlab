% Select folder that contains individual
%-------------------------------------------------------------------------
%INPUT
%   Subjects = cell with all subjects names
%   TrialList = cell with names of trials to gather
%   update (optional) = cell containg 'MuscleVariables',
%   'ContactForces','externalBiomech', or 'SpatioTemporal'
%-------------------------------------------------------------------------
%OUTPUT
%   G = Group data with angles, moments
%   W = Joint work data
%   ST = SpatioTemporalData
%   E = errors struct
%   BestGamma = best gamma and errors per trial
%-------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
function [G,W,ST,E,BestGamma] = importCEINMSResults_August2021(Subjects,TrialList,update,ReRunSubjects)
%% base setup

fp = filesep;warning off
[Dir,Temp,SubjectInfo,~] = getdirFAI(Subjects{1});

savedir = [Dir.Results_JCFFAI fp 'CEINMSbackupResults.mat'];
CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
dofList_CEINMS = split(CEINMSSettings.dofList ,' ')';
dofList_ERR = strrep(dofList_CEINMS,'_r','');dofList_ERR = strrep(dofList_ERR,'_l','');
dofList_IK = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation' 'pelvis_tx' 'pelvis_ty' 'pelvis_tz' 'lumbar_extension' 'lumbar_bending' 'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};

dofList_MomArm = {'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};

S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList_CEINMS);

[CEINMSmuscles,EMGinputs]=assignEMGtoMuscle(Temp.CEINMSexcitationGenerator);
[~,RowsToKeep] = intersect(CEINMSmuscles,S.AllMuscles);
CEINMSmuscles=CEINMSmuscles(RowsToKeep,1);
EMGinputs = unique(EMGinputs(~cellfun('isempty',EMGinputs)))';
CEINMSmuscles = strrep(CEINMSmuscles,'_r','');CEINMSmuscles = strrep(CEINMSmuscles,'_l','');

%% Set up group struct for angles, mometns and EMG and work struct (Motions, muscles and work to extract)
OutVar = struct;
OutVar.muscle = struct('MuscleForces',CEINMSmuscles,'AdjustedEmgs',CEINMSmuscles, 'NormFibreLengths',CEINMSmuscles,'NormFibreVelocities',CEINMSmuscles);
OutVar.MeasuredEMG = struct('MeasuredEMG',EMGinputs);
OutVar.momarm = struct('hip_flexion',CEINMSmuscles,'hip_adduction',CEINMSmuscles,'hip_rotation',CEINMSmuscles,'knee_angle',CEINMSmuscles,'ankle_angle',CEINMSmuscles);
OutVar.externalBiomech = struct('IK',dofList_IK,'ID',dofList_IK,'Powers',dofList_IK);
OutVar.IDceinms = struct('ID_ceinms',S.dofsimple);
OutVar.JCF = struct('ContactForces', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.JCFrate = struct('ContactForcesRate', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.PosImpulseCF = struct('PosImpulseCF', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.NegImpulseCF = struct('NegImpulseCF', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
STVar = {'VmeanAP' 'AmeanAP' 'VmeanML' 'AmeanML' 'StepTime' 'ContactTime' 'PosVmax' 'StepLength' 'StepFreq' 'FC_percentage'};
WorkVar = {'TotalPosWork','TotalNegWork','STpfW','STnfW','STpeW','STneW','SWpfW','SWnfW','SWpeW','SWneW'};
ErrVar = struct('EMGerr',dofList_ERR,'EMGr2',dofList_ERR,'EMGerr_Relative',dofList_ERR,'MOMerr',dofList_ERR,'MOMr2',dofList_ERR,'MOMerr_Relative',dofList_ERR);
Ncols = length(Subjects);
Nrows = 101;
ReRunCols = [];
for Subj = 1:length(Subjects)
    if ~contains(Subjects,ReRunSubjects); continue; end        % check subjects to re run or not
    ReRunCols(Subj) = Subj;
end
if exist('update')&& exist(savedir)
    load(savedir)
    if isempty(update); OutVar=struct; ErrVar=struct; WorkVar={}; STVar={}; return; end
    if ~contains(update,'MuscleVariables'); OutVar=rmfield(OutVar,'muscle'); OutVar=rmfield(OutVar,'MeasuredEMG'); ErrVar=struct; end
    if ~contains(update,'MomentArms'); OutVar=rmfield(OutVar,'momarm'); end
    if ~contains(update,'ContactForces'); OutVar=rmfield(OutVar,'JCF'); end
    if ~contains(update,'externalBiomech'); OutVar= rmfield(OutVar,'externalBiomech'); OutVar=rmfield(OutVar,'IDceinms'); WorkVar={}; end
    if ~contains(update,'SpatioTemporal'); STVar={}; end

    [G,W,ST,E]=updateResulsStruct_JCFFAI(G,W,ST,E,TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows,ReRunCols); 
  
else
    [G,W,ST,E] = createResulsStruct_JCFFAI(OutVar,WorkVar,STVar,ErrVar,TrialList,Ncols,Nrows);
    BestGamma = {'Subj' 'trialName' 'OptimalSettings'};
end
%% Gather each participant
for Subj = 1:length(Subjects)    % loop through all participants
    %%   Set-up participant
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{Subj});   
    if nargin>3 && ~contains(SubjectInfo.ID,ReRunSubjects); continue; end        % check subjects to re run or not

    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    G.participants{Subj} = SubjectInfo.ID; ST.participants{Subj} = SubjectInfo.ID;
    
    if ~exist([Dir.CEINMSsimulations])||length(Trials.CEINMS)<1;continue;end
    
    fprintf(['Importing data participant ' SubjectInfo.ID '\n'])
    
    dofList_CEINMS = split(CEINMSSettings.dofList ,' ')';
    S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList_CEINMS);
    
    dofListExt=dofList_IK; idx=~contains(dofListExt,{'pelvis' 'lumbar'});
    dofListExt(idx) =  strcat(dofListExt(idx),['_' lower(SubjectInfo.TestedLeg)]);
    Ext = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofListExt);
    %% delete trials that do not match the TrialList
    % get trial names all with same format (
    Strials = getstrials(Trials.CEINMS,SubjectInfo.TestedLeg);
    
    %% loop through all trials in the list and store data in struct
    for tt = 1:length(Trials.CEINMS)%[length(Files)-1,length(Files)-2]
        %% Setup-trial info
        trialName = Trials.CEINMS{tt};
        [TimeWindow, FramesWindow,FootContact] = TimeWindow_FatFAIS(Dir,trialName);
        SimulationDir = [Dir.CEINMSsimulations fp trialName];
        
        if length(TimeWindow)<2 || length(dir(SimulationDir))<3 || ~contains(Strials{tt},TrialList)
            continue
        end
        warning off
        
        disp([trialName '...'])
        
        trialDirs = getosimfilesFAI(Dir,trialName); % load paths for this trial
        JCFStruct = importdata(trialDirs.JRAresults);
        [~,LabelsCF] = findData(JCFStruct.data,JCFStruct.colheaders,S.Joints,0);
        deleteCols = contains(LabelsCF,{'mz' 'my' 'mx' 'pz' 'py' 'px'});
        LabelsCF(:,deleteCols)=[];
        
        TimeWindow = [JCFStruct.data(1,1) JCFStruct.data(end,1)];
        %[TimeWindow,FramesWindow,FootContact] = AdjustTimeWindow(Dir,SubjectInfo,Trials,trialName,TimeWindow,FramesWindow,FootContact);
        
        %% Muscle Variables
        if ~exist('update') || any(contains(update,'MuscleVariables'))
            % find best CEINMS iteration (including directory and mean err for EMG and MOM)
            BestItr = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
            BestItrDir = BestItr.Dir;
            BestGamma{end+1,1}= (['s' SubjectInfo.ID]);
            BestGamma{end,2}= trialName;
            BestGamma{end,3} = BestItr.Gamma;
         
            % add the error to the structure
            [RMSE,R2] = CEINMS_errors(trialDirs.emg,trialDirs.IDresults,BestItrDir,CEINMSSettings.excitationGeneratorFilename,CEINMSSettings.exeCfg,S.DOFmuscles);
            cols = [4 10 16];
            
            for e = 1:length(dofList_ERR)
                E.MOMerr.(dofList_ERR{e}).(Strials{tt})(1,Subj) = RMSE.mom.(dofList_CEINMS{e});
                E.EMGerr
                E.EMGerr.(dofList_ERR{e}).(Strials{tt})(1,Subj) = nanmean(RMSE.exc.(dofList_CEINMS{e}));
                E.MOMerr_Relative.(dofList_ERR{e}).(Strials{tt})(1,Subj) = RMSE.momPerRange.(dofList_CEINMS{e});
                E.EMGerr_Relative.(dofList_ERR{e}).(Strials{tt})(1,Subj) = nanmean(RMSE.excPerRange.(dofList_CEINMS{e}));
                E.MOMr2.(dofList_ERR{e}).(Strials{tt})(1,Subj) = R2.mom.(dofList_CEINMS{e});
                E.EMGr2.(dofList_ERR{e}).(Strials{tt})(1,Subj) = nanmean(R2.exc.(dofList_CEINMS{e}));
                
                BestGamma{1,cols(e)} = 'RMSE Mom';  BestGamma{end,cols(e)} = RMSE.mom.(dofList_CEINMS{e});
                BestGamma{1,cols(e)+1} = 'RMSE exc';    BestGamma{end,cols(e)+1} = mean(RMSE.exc.(dofList_CEINMS{e}));
                BestGamma{1,cols(e)+2} = 'RMSE Mom per range';  BestGamma{end,cols(e)+2} = RMSE.momPerRange.(dofList_CEINMS{e});
                BestGamma{1,cols(e)+3}= 'RMSE exc per range';   BestGamma{end,cols(e)+3}= mean(RMSE.excPerRange.(dofList_CEINMS{e}));
                BestGamma{1,cols(e)+4} = 'R2 Mom';  BestGamma{end,cols(e)+4} = R2.mom.(dofList_CEINMS{e});
                BestGamma{1,cols(e)+5} = 'R2 exc';  BestGamma{end,cols(e)+5} = mean(R2.exc.(dofList_CEINMS{e}));
            end
            
            muscleList = strcat(CEINMSmuscles,['_' lower(SubjectInfo.TestedLeg)]);  % load muscle parameters
            MuscleVariables = fields(OutVar.muscle)';
            for mv = 1:length(MuscleVariables)
                [Results,~] = LoadResults_BG([BestItrDir fp MuscleVariables{mv} '.sto'],TimeWindow,muscleList,0);
                G = SortData(G,MuscleVariables{mv},Results,Strials{tt},CEINMSmuscles,Subj);
            end
            [Results,Labels] = LoadResults_BG([trialDirs.emg],TimeWindow,EMGinputs,0);
            Results(:,[5:6]) =[]; Labels(:,[5:6]) =[]; % delete repeated Gmax and Gmed
            G = SortData(G,'MeasuredEMG',Results,Strials{tt},EMGinputs,Subj);
        end
         %% load moment arms
        if ~exist('update') || any(contains(update,'MomentArms'))
            for ii = 1:length(dofList_MomArm)
                [MomArm,~] = LoadResults_BG ([trialDirs.MA fp '_MuscleAnalysis_MomentArm_' dofList_MomArm{ii} '_' lower(SubjectInfo.TestedLeg) '.sto'],TimeWindow,muscleList,0);
                G = SortData(G,dofList_MomArm{ii},MomArm,Strials{tt},CEINMSmuscles,Subj);
            end
        end
        
        %% load contact forces
        if ~exist('update') || any(contains(update,'ContactForces'))
            [~,NormContactForces,NormContactForceRate,PosImpulse,NegImpulse,~] = importJCF(trialDirs.JRAresults,TimeWindow,LabelsCF,SubjectInfo.TestedLeg);
            
            G = SortData(G,'ContactForces',NormContactForces,Strials{tt},{OutVar.JCF.ContactForces},Subj);
            G = SortData(G,'ContactForcesRate',NormContactForceRate,Strials{tt},{OutVar.JCF.ContactForces},Subj);
            G = SortData(G,'PosImpulseCF',PosImpulse,Strials{tt},{OutVar.JCF.ContactForces},Subj);
            G = SortData(G,'NegImpulseCF',NegImpulse,Strials{tt},{OutVar.JCF.ContactForces},Subj); end
        
        %% load external biomechanics
        if ~exist('update') || any(contains(update,'externalBiomech'))
            [IK,~] = LoadResults_BG (trialDirs.IKresults,TimeWindow,Ext.coordinates,1);
            [ID,~] = LoadResults_BG (trialDirs.IDresults,TimeWindow,Ext.moments,1);
            [ID_ceinms,~] = LoadResults_BG ([BestItrDir fp 'Torques.sto'],TimeWindow,dofList_CEINMS,1);
            
            if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_list'))
                idx = find(contains(Ext.coordinates,'pelvis_list')); IK(:,idx)=-IK(:,idx);end
            
            if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_rotation'))
                idx = find(contains(Ext.coordinates,'pelvis_rotation')); IK(:,idx)=-IK(:,idx);end
            
            if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'lumbar_bending'))
                idx = find(contains(Ext.coordinates,'lumbar_bending')); IK(:,idx)=-IK(:,idx); end
            
            G = SortData(G,'IK',IK,Strials{tt},dofList_IK,Subj);
            G = SortData(G,'ID',ID,Strials{tt},dofList_IK,Subj);
            G = SortData(G,'ID_ceinms',ID_ceinms,Strials{tt},S.dofsimple,Subj);
            
            if ~contains(trialName,'walking','IgnoreCase',1)
                [Work,JointPowerTimeNorm,~,~] = jointworkcalc (Dir,SubjectInfo,Trials,trialName,Ext.coordinates',Ext.moments','RRA');
                G = SortData(G,'Powers',JointPowerTimeNorm,Strials{tt},dofList_IK,Subj);
                W = SortData_work(W,Work,Strials{tt},fields(W)',Subj); 
            end
        end
        
        %% Spatio temporal data
        if ~exist('update') || any(contains(update,'SpatioTemporal'))
            IK_pelvis = LoadResults_BG (trialDirs.IKresults,TimeWindow,{'time';['pelvis_tx'];['pelvis_ty'];['pelvis_tz']},1,0);
            fs = 1/diff(IK_pelvis(1:2,1));
            
           
            Horizontalvelocity = calcVelocity (IK_pelvis(:,2),fs);
            HorizontalAcc = calcAcc (IK_pelvis(:,2),fs)./100;
            
            Vertvelocity = calcVelocity (IK_pelvis(:,3),fs);
            VertAcc = calcAcc (IK_pelvis(:,3),fs)./100;
            
            MLvelocity = calcVelocity (IK_pelvis(:,4),fs);
            MLAcc = calcAcc (IK_pelvis(:,4),fs)./100;
            
            ST.VmeanAP.(Strials{tt})(Subj)= mean(Horizontalvelocity);
            ST.AmeanAP.(Strials{tt})(Subj)= mean(HorizontalAcc);
            ST.VmeanML.(Strials{tt})(Subj)= mean(MLvelocity);
            ST.AmeanML.(Strials{tt})(Subj)= mean(MLAcc);
            ST.StepTime.(Strials{tt})(Subj) = TimeWindow(2)-TimeWindow(1);
            [SL,SF] = GetStepLength(trialDirs.c3d,FramesWindow,'MT',SubjectInfo.TestedLeg);
            ST.StepLength.(Strials{tt})(Subj) = SL;
            ST.StepFreq.(Strials{tt})(Subj) = SF;
            
            if contains(trialName,Trials.RunStraight)
                ST.ContactTime.(Strials{tt})(Subj) = TimeWindow(2)-FootContact.time;
                [~,ST.FC_percentage.(Strials{tt})(Subj)] = min(abs(IK_pelvis(:,1)-FootContact.time));
            end
        end
    end
    save(savedir,'G','W','ST','E','BestGamma')
end
