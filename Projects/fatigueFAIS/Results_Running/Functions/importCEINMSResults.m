% [G,W,ST,E,BestGamma] = importCEINMSResults(Subjects,TrialList,update,ReRunSubjects)
%-------------------------------------------------------------------------
%INPUT
%   Subjects = cell with all subjects names
%   TrialList = cell with names of trials to gather
%   update (optional) = cell containg 'MuscleVariables', 'ContactForces','externalBiomech', and/or 'SpatioTemporal'
%                       If empty creates variables from scratch
%                       'none' does not update anything
%   ReRunSubjects(optional) = cell with subject codes import data (again)
%
%-------------------------------------------------------------------------
%OUTPUT
%   G = Group data with angles, moments, forces (etc..) for all
%   participants
%   W = Joint work data
%   ST = SpatioTemporalData
%   E = errors struct
%   BestGamma = best gamma and errors per trial
%-------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
function [G,W,ST,E,BestGamma] = importCEINMSResults(Subjects,TrialList,update,ReRunSubjects,savedir)
%% base setup
% Set up group struct for angles, mometns and EMG and work struct (Motions, muscles and work to extract)
fp = filesep;

% fucntio to setup the structure of the outupt files
[G,W,ST,E,BestGamma,dofList,OutVar] = setupStructure (Subjects,TrialList,update,ReRunSubjects,savedir);

%% Loop through each participant
if ~contains(update,'none')
    for Subj = 1:length(Subjects)    % loop through all participants
        %%   Set-up participant
        
        if nargin>3 && ~contains(Subjects(Subj),ReRunSubjects); continue; end        % check subjects to re run or not
        
        [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{Subj});
        CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
        
        G.participants{Subj} = SubjectInfo.ID; ST.participants{Subj} = SubjectInfo.ID;
        
        if ~exist([Dir.CEINMSsimulations])||length(Trials.CEINMS)<1;continue;end
        
        fprintf(['Importing data participant ' SubjectInfo.ID '\n'])
        
        dofList.CEINMS = split(CEINMSSettings.dofList ,' ')';
        S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList.CEINMS);
        
        dofListExt=dofList.IK; idx=~contains(dofListExt,{'pelvis' 'lumbar'});
        dofListExt(idx) =  strcat(dofListExt(idx),['_' lower(SubjectInfo.TestedLeg)]);
        Ext = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofListExt);
        
        % get trial names all with same format (some trials have different names)
        Strials = getstrials(Trials.CEINMS,SubjectInfo.TestedLeg);
        if contains(Strials,TrialList)==0
            fprintf(['participant ' SubjectInfo.ID ' does not contain any of trials:' strjoin(TrialList) '\n'])
            continue
        end
        %% loop through all trials in the list and store data in struct
        for tt = 1:length(Trials.CEINMS)
            %% Setup-trial info
            trialName = Trials.CEINMS{tt};
            [TimeWindow, FramesWindow,FootContact] = TimeWindow_FatFAIS(Dir,trialName);
            SimulationDir = [Dir.CEINMSsimulations fp trialName];
            
            if length(dir(SimulationDir))<3 || ~contains(Strials{tt},TrialList);   continue;   end
            warning off
            
            disp([trialName '...'])
            
            trialDirs = getosimfilesFAI(Dir,trialName); % load paths for this trial
            JCFStruct = importdata(trialDirs.JRAresults);
            [~,LabelsCF] = findData(JCFStruct.data,JCFStruct.colheaders,S.Joints,0);
            deleteCols = contains(LabelsCF,{'mz' 'my' 'mx' 'pz' 'py' 'px'});
            LabelsCF(:,deleteCols)=[];
            
            TimeWindow = [JCFStruct.data(1,1) JCFStruct.data(end,1)];
            %[TimeWindow,FramesWindow,FootContact] = AdjustTimeWindow(Dir,SubjectInfo,Trials,trialName,TimeWindow,FramesWindow,FootContact);
            
            % find best CEINMS iteration (including directory and mean err for EMG and MOM)
            BestItr = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
            BestItrDir = BestItr.Dir;
            
            %% Muscle Variables
            if ~exist('update') || any(contains(update,'MuscleVariables'))
                BestGamma(Subj).Participant = (['s' SubjectInfo.ID]);
                BestGamma(Subj).trialName = trialName;
                BestGamma(Subj).Alpha = BestItr.Alpha;
                BestGamma(Subj).Beta = BestItr.Beta;
                BestGamma(Subj).Gamma = BestItr.Gamma;
                
                % add the error to the structure
                [RMSE,R2,~] = CEINMS_errors(trialDirs.emg,trialDirs.IDRRAresults,BestItrDir,CEINMSSettings.excitationGeneratorFilename,CEINMSSettings.exeCfg,S.DOFmuscles);
                ncols = length(G.CEINMSmuscles);
                E.EMGrmse.(Strials{tt})(Subj,1:ncols) = RMSE.exc.All;
                E.EMGrmse_Relative.(Strials{tt})(Subj,1:ncols) = RMSE.excPerRange.All;
                E.EMGr2.(Strials{tt})(Subj,1:ncols) = R2.exc.All;
                
                for e = 1:length(dofList.ERR)
                    E.MOMrmse.(Strials{tt})(Subj,e) = RMSE.mom.(dofList.CEINMS{e});
                    E.MOMrmse_Relative.(Strials{tt})(Subj,e) = RMSE.momPerRange.(dofList.CEINMS{e});
                    E.MOMr2.(Strials{tt})(Subj,e) = R2.mom.(dofList.CEINMS{e});
                end
                
                muscleList = strcat(G.CEINMSmuscles,['_' lower(SubjectInfo.TestedLeg)]);  % load muscle parameters
                MuscleVariables = fields(OutVar.muscle)';
                for mv = 1:length(MuscleVariables)
                    [Results,~] = LoadResults_BG([BestItrDir fp MuscleVariables{mv} '.sto'],TimeWindow,muscleList,0);
                    G = SortData(G,MuscleVariables{mv},Results,Strials{tt},G.CEINMSmuscles,Subj);
                end
                EMGinputs_unique = unique(G.EMGinputs(~cellfun('isempty',G.EMGinputs)))';
                [Results,Labels] = LoadResults_BG([trialDirs.emg],TimeWindow,EMGinputs_unique,0);
                
                Results(:,[5:6]) =[]; Labels(:,[5:6]) =[]; % delete repeated Gmax and Gmed
                G = SortData(G,'MeasuredEMG',Results,Strials{tt},EMGinputs_unique,Subj);
                
            end
            
            %% load moment arms
            if ~exist('update') || any(contains(update,'MomentArms'))
                for ii = 1:length(dofList.MomArm)
                    [MomArm,~] = LoadResults_BG ([trialDirs.MA fp '_MuscleAnalysis_MomentArm_' dofList.MomArm{ii} '_' lower(SubjectInfo.TestedLeg) '.sto'],TimeWindow,muscleList,0);
                    G = SortData(G,dofList.MomArm{ii},MomArm,Strials{tt},G.CEINMSmuscles,Subj);
                end
            end
            
            %% load contact forces
            if ~exist('update') || any(contains(update,'ContactForces'))
                [~,NormContactForces,NormContactForceRate,PosImpulse,NegImpulse,Labels] = importJCF(trialDirs.JRAresults,TimeWindow,LabelsCF,SubjectInfo.TestedLeg);
                
                G = SortData(G,'ContactForces',NormContactForces,Strials{tt},{OutVar.JCF.ContactForces},Subj);
                G = SortData(G,'ContactForcesRate',NormContactForceRate,Strials{tt},{OutVar.JCF.ContactForces},Subj);
                G = SortData(G,'PosImpulseCF',PosImpulse,Strials{tt},{OutVar.JCF.ContactForces},Subj);
                G = SortData(G,'NegImpulseCF',NegImpulse,Strials{tt},{OutVar.JCF.ContactForces},Subj);
            end
            
            %% load external biomechanics
            if ~exist('update') || any(contains(update,'externalBiomech'))
                [IK,~] = LoadResults_BG (trialDirs.IKresults,TimeWindow,Ext.coordinates,1);
                [ID,~] = LoadResults_BG (trialDirs.IDresults,TimeWindow,Ext.moments,1);
                [ID_ceinms,~] = LoadResults_BG ([BestItrDir fp 'Torques.sto'],TimeWindow,dofList.CEINMS,1);
                
                if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_list'))
                    idx = find(contains(Ext.coordinates,'pelvis_list')); IK(:,idx)=-IK(:,idx);end
                
                if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_rotation'))
                    idx = find(contains(Ext.coordinates,'pelvis_rotation')); IK(:,idx)=-IK(:,idx);end
                
                if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'lumbar_bending'))
                    idx = find(contains(Ext.coordinates,'lumbar_bending')); IK(:,idx)=-IK(:,idx); end
                
                G = SortData(G,'IK',IK,Strials{tt},dofList.IK,Subj);
                G = SortData(G,'ID',ID,Strials{tt},dofList.IK,Subj);
                G = SortData(G,'ID_ceinms',ID_ceinms,Strials{tt},S.dofsimple,Subj);
                
                if ~contains(trialName,'walking','IgnoreCase',1)
                    [Work,JointPowerTimeNorm,~,~] = jointworkcalc (Dir,SubjectInfo,Trials,trialName,Ext.coordinates',Ext.moments','RRA');
                    G = SortData(G,'Powers',JointPowerTimeNorm,Strials{tt},dofList.IK,Subj);
                    W = SortData_work(W,Work,Strials{tt},fields(W)',Subj);
                end
            end
            
            %% Spatio temporal data
            if ~exist('update') || any(contains(update,'SpatioTemporal'))
                IK_pelvis = LoadResults_BG (trialDirs.IKresults,TimeWindow,{'time';['pelvis_tx'];['pelvis_ty'];['pelvis_tz']},1,0);
                
                [APgrf,Vgrf,MLgrf,~] = loadGRFfromXML (trialDirs.IDgrfxml,SubjectInfo.TestedLeg,TimeWindow);
                
                fs = 1/diff(IK_pelvis(1:2,1));
                
                Horizontalvelocity = calcVelocity (IK_pelvis(:,2),fs);
                HorizontalAcc = calcAcc (IK_pelvis(:,2),fs)./100;
                
                Vertvelocity = calcVelocity (IK_pelvis(:,3),fs);
                VertAcc = calcAcc (IK_pelvis(:,3),fs)./100;
                
                MLvelocity = calcVelocity (IK_pelvis(:,4),fs);
                MLAcc = calcAcc (IK_pelvis(:,4),fs)./100;
                
                G.GRF.AP.(Strials{tt})(1:101,Subj)= sum(APgrf,2);
                G.GRF.ML.(Strials{tt})(1:101,Subj)= sum(MLgrf,2);
                G.GRF.V.(Strials{tt})(1:101,Subj)= sum(Vgrf,2);
                ST.VmeanAP.(Strials{tt})(Subj)= mean(Horizontalvelocity);
                ST.AmeanAP.(Strials{tt})(Subj)= mean(HorizontalAcc);
                ST.VmeanML.(Strials{tt})(Subj)= mean(MLvelocity);
                ST.AmeanML.(Strials{tt})(Subj)= mean(MLAcc);
                ST.StepTime.(Strials{tt})(Subj) = TimeWindow(2)-TimeWindow(1);
                [SL,SF] = GetStepLength(trialDirs.c3d,TimeWindow,'MT',SubjectInfo.TestedLeg);
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
end

%% Average participant data across trials
G = MeanBaselineJCF(G);
ST = MeanBaselineJCF(ST,2);
if any(contains(TrialList,'RunStraight'))
    ST.FC_mean = mean(ST.FC_percentage.MeanRunStraight);
end


%%   ==============================================================================================================  %
%%   ================================================ CALLBACK FUCNTIONS ==========================================  %
%%   ==============================================================================================================  %
function [G,W,ST,E,BestGamma,dofList,OutVar,savedir] = setupStructure (Subjects,TrialList,update,ReRunSubjects,savedir)
%% setupStructure
fp = filesep;
[Dir,Temp,SubjectInfo,~] = getdirFAI(Subjects{1});
CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);

if exist(savedir); load(savedir); end

dofList = struct;
dofList.CEINMS = split(CEINMSSettings.dofList ,' ')';
dofList.ERR = strrep(dofList.CEINMS,'_r','');dofList.ERR = strrep(dofList.ERR,'_l','');
dofList.IK = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation' 'pelvis_tx' 'pelvis_ty' 'pelvis_tz' 'lumbar_extension' 'lumbar_bending' 'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};
dofList.MomArm = {'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};

S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList.CEINMS);

% add muscle names to group data
[CEINMSmuscles,EMGinputs]=assignEMGtoMuscle(Temp.CEINMSexcitationGenerator);
[~,RowsToKeep] = intersect(CEINMSmuscles,S.AllMuscles);
CEINMSmuscles=CEINMSmuscles(RowsToKeep,1); CEINMSmuscles = strrep(CEINMSmuscles,'_r','');CEINMSmuscles = strrep(CEINMSmuscles,'_l','');

CEINMSmuscles_perDOF = RenameField(S.DOFmuscles, fields(S.DOFmuscles), S.dofsimple); %rename fields by removing '_r' or '_l' from DOF and muscle names
for f= 1:length(S.dofsimple)
    CEINMSmuscles_perDOF.(S.dofsimple{f})=strrep(CEINMSmuscles_perDOF.(S.dofsimple{f}),'_r','');
    CEINMSmuscles_perDOF.(S.dofsimple{f})=strrep(CEINMSmuscles_perDOF.(S.dofsimple{f}),'_l','');
end

G.CEINMSmuscles = CEINMSmuscles;
G.EMGinputs = EMGinputs;
G.CEINMSmuscles_perDOF= CEINMSmuscles_perDOF;

EMGinputs = unique(EMGinputs(~cellfun('isempty',EMGinputs)),'stable')';

OutVar = struct;
OutVar.muscle = struct('MuscleForces',CEINMSmuscles,'AdjustedEmgs',CEINMSmuscles, 'NormFibreLengths',CEINMSmuscles,'NormFibreVelocities',CEINMSmuscles);
OutVar.MeasuredEMG = struct('MeasuredEMG',EMGinputs);
OutVar.momarm = struct('hip_flexion',CEINMSmuscles,'hip_adduction',CEINMSmuscles,'hip_rotation',CEINMSmuscles,'knee_angle',CEINMSmuscles,'ankle_angle',CEINMSmuscles);
OutVar.externalBiomech = struct('IK',dofList.IK,'ID',dofList.IK,'Powers',dofList.IK);
OutVar.IDceinms = struct('ID_ceinms',S.dofsimple);
OutVar.JCF = struct('ContactForces', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.JCFrate = struct('ContactForcesRate', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.PosImpulseCF = struct('PosImpulseCF', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.NegImpulseCF = struct('NegImpulseCF', [S.ContactForcesGenric 'hip_resultant' 'knee_resultant' 'ankle_resultant']);
OutVar.GRF = struct('GRF',{'AP','V','ML'});
STVar = {'VmeanAP' 'AmeanAP' 'VmeanML' 'AmeanML' 'StepTime' 'ContactTime' 'PosVmax' 'StepLength' 'StepFreq' 'FC_percentage'};
WorkVar = {'TotalPosWork','TotalNegWork','STpfW','STnfW','STpeW','STneW','SWpfW','SWnfW','SWpeW','SWneW'};
ErrVar = struct('EMGrmse',dofList.ERR,'EMGr2',dofList.ERR,'EMGrmse_Relative',dofList.ERR,'MOMrmse',dofList.ERR,'MOMr2',dofList.ERR,'MOMrmse_Relative',dofList.ERR);

Ncols = length(Subjects);
Nrows = 101;
ReRunCols = [];
for Subj = 1:length(Subjects)
    if ~contains(Subjects{Subj},ReRunSubjects); continue; end        % check subjects to re run or not
    ReRunCols(end+1) = Subj;
end

if exist('update') && exist(savedir) && ~isempty(update)
    if isempty(update); OutVar=struct; ErrVar=struct; WorkVar={}; STVar={}; return; end
    if ~contains(update,'MuscleVariables'); OutVar=rmfield(OutVar,{'muscle' 'MeasuredEMG'}); end
    if ~contains(update,'MomentArms'); OutVar=rmfield(OutVar,'momarm'); end
    if ~contains(update,'ContactForces'); OutVar=rmfield(OutVar,{'JCF' 'PosImpulseCF' 'NegImpulseCF'}); end
    if ~contains(update,'externalBiomech'); OutVar= rmfield(OutVar,{'externalBiomech' 'IDceinms'}); WorkVar={};end
    if ~contains(update,'SpatioTemporal'); OutVar= rmfield(OutVar,{'GRF'}); STVar={}; end
    
    [G,W,ST,E] = ResultsStruct(G,W,ST,E,TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows,ReRunCols);
else
    [G,W,ST,E] = ResultsStruct([],[],[],[],TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows);
    
    BestGamma = struct('Participant',{''},'trialName' ,{''},'Alpha',[1],'Beta',[1],'Gamma',[1]);
end
E.muscleNames = CEINMSmuscles';
E.dofNames = dofList.ERR;

function [G,W,ST,E] =  ResultsStruct(G,W,ST,E,TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows,ReRunCols)
%% create the resuls sruct for G(group data), W(work data), ST(spatiotemporal data) and E(error data)

if nargin==12; cols = ReRunCols; else; cols = 1:Ncols; end

if isempty(G)
    G = struct;     % group data (CEINMS, Ext biomech, ...)
    W = struct;     % joint work data
    E = struct;     % error emg and momments
    ST = struct;    % spatiotemporal
end

if ~isempty(fields(OutVar))
    for TypeVar  = fields(OutVar)'
        for GroupVar = fields(OutVar.(TypeVar{1}))'
            for Var = {OutVar.(TypeVar{1}).(GroupVar{1})}
                for trial = TrialList
                    if contains(GroupVar,'Impulse')
                        G.(GroupVar{1}).(Var{1}).(trial{1})(1,cols)= NaN;
                    else
                        G.(GroupVar{1}).(Var{1}).(trial{1})(1:Nrows,cols)= NaN;
                    end
                end
            end
        end
    end
end

% work paramters
if ~isempty(fields(OutVar)) && isfield(OutVar,'externalBiomech')
    for GroupVar = {OutVar.externalBiomech.IK}
        for Var = WorkVar
            for trial = TrialList
                W.(GroupVar{1}).(Var{1}).(trial{1})(1,cols)= NaN;
            end
        end
    end
end

% ST paramters
if ~isempty(STVar)
    for Var = STVar
        for trial = TrialList
            ST.(Var{1}).(trial{1})(1,cols)= NaN;
        end
    end
end

% error values paramters
Nrows = 1:40;
if ~isempty(fields(ErrVar))
    for GroupVar = fields(ErrVar)'
        for trial = TrialList
            E.(GroupVar{1}).(trial{1})(cols,Nrows)= NaN;
        end
    end
end

function G = SortData(G,fld,Data,trialName,motionsG,col)
%% Sort data
for k = 1:size(Data,2)
    if ~isfield(G.(fld).(motionsG{k}),[trialName])
        G.(fld).(motionsG{k}).([trialName])=[];
    end
    G.(fld).(motionsG{k}).([trialName])(:,col)=Data(:,k);
    
end

function [G] = MeanBaselineJCF (G,varargin)
%% findMeanBaselineJCF
N = length(G.participants);
for col = 1:N
    if nargin ==1
        G = updateGroup (G,col);
    else
        G = updateGroup_ST (G,col);
    end
end

function G = updateGroup (G,col)
%% organise group data
Pram = fields(G);           % get paramters
Pram (contains(Pram,{'participants' 'CEINMSmuscles' 'EMGinputs' 'CEINMSmuslces_perDOF'}))=[]; % delete the Parms

for paramIdx = 1:length(Pram)
    muscleNames = fields(G.(Pram{paramIdx})); % get coordinates
    for muscleIdx = 1:length(muscleNames)
        trials = fields(G.(Pram{paramIdx}).(muscleNames{muscleIdx})); % get trials
        
        Nrows = length(G.(Pram{paramIdx}).(muscleNames{muscleIdx}).(trials{1})(:,col));
        S = G.(Pram{paramIdx}).(muscleNames{muscleIdx});
        TrialsNames = fields(S);
        
        % mean straight sprint
        if any(contains(TrialsNames,'RunStraight'))
            G.(Pram{paramIdx}).(muscleNames{muscleIdx}).MeanRunStraight(1:Nrows,col) = MeanAcrossTrials(S,'RunStraight',col);
        end
        % mean CutTested
        if any(contains(TrialsNames,'CutTested'))
            G.(Pram{paramIdx}).(muscleNames{muscleIdx}).MeanCutTested(1:Nrows,col) = MeanAcrossTrials(S,'CutTested',col);
        end
        
        % mean CutOposite
        if any(contains(TrialsNames,'CutOposite'))
            G.(Pram{paramIdx}).(muscleNames{muscleIdx}).MeanCutOposite(1:Nrows,col) = MeanAcrossTrials(S,'CutOposite',col);
        end
        
        % mean walking
        if any(contains(TrialsNames,'RunStraight'))
            G.(Pram{paramIdx}).(muscleNames{muscleIdx}).MeanWalking(1:Nrows,col) = MeanAcrossTrials(S,'walking',col);
        end
    end
end

function G = updateGroup_ST (G,col)
%% organise group data
Pram = fields(G);           % get paramters
Pram (contains(Pram,{'participants' 'CEINMSmuscles' 'EMGinputs' 'CEINMSmuslces_perDOF'}))=[]; % delete the Parms
for paramIdx = 1:length(Pram)
    trials = fields(G.(Pram{paramIdx})); % get trials
    
    Nrows = length(G.(Pram{paramIdx}).(trials{1})(:,col));
    S = G.(Pram{paramIdx});
    TrialsNames = fields(S);
    
    % mean straight sprint
    if any(contains(TrialsNames,'RunStraight'))
        G.(Pram{paramIdx}).MeanRunStraight(1:Nrows,col) = MeanAcrossTrials(S,'RunStraight',col);
    end
    % mean CutTested
    if any(contains(TrialsNames,'CutTested'))
        G.(Pram{paramIdx}).MeanCutTested(1:Nrows,col) = MeanAcrossTrials(S,'CutTested',col);
    end
    
    % mean CutOposite
    if any(contains(TrialsNames,'CutOposite'))
        G.(Pram{paramIdx}).MeanCutOposite(1:Nrows,col) = MeanAcrossTrials(S,'CutOposite',col);
    end
    
    % mean walking
    if any(contains(TrialsNames,'RunStraight'))
        G.(Pram{paramIdx}).MeanWalking(1:Nrows,col) = MeanAcrossTrials(S,'walking',col);
    end
end

function MeanValues = MeanAcrossTrials(S,TrialName,col)
%% mean per participant acrsoss trials
FullTrialList = fields(S);
TrialListToAverage = FullTrialList(startsWith(FullTrialList,TrialName));
Nrows = length(S.(TrialListToAverage{1})(:,col));
SumValues = zeros(Nrows,1);

numberOfRecordedTrials = 0;
for t = 1:length(TrialListToAverage)
    currentTrial = S.(TrialListToAverage{t})(:,col);
    if  mean(isnan(currentTrial))~=1
        numberOfRecordedTrials= numberOfRecordedTrials+1;
    end
    SumValues = nansum([SumValues, currentTrial],2);
end
MeanValues = SumValues./numberOfRecordedTrials;

