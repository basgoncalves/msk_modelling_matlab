function G = bops_gather_ik
Dir=getdirFAI;

Subjects=splitGroupsFAI(Dir.Main,'JCFFAI');
TrialList = {'RunStraight1','RunStraight2','walking1','walking2','walking3','walking4','walking5'};
savedir = [Dir.Results_JCFFAI fp 'ik.mat'];            % directory to save data in

dofList = struct;
dofList.CEINMS = split(CEINMSSettings.dofList ,' ')';
dofList.ERR = strrep(dofList.CEINMS,'_r','');dofList.ERR = strrep(dofList.ERR,'_l','');
dofList.IK = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation' 'pelvis_tx' 'pelvis_ty' 'pelvis_tz' 'lumbar_extension' 'lumbar_bending' 'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};
dofList.MomArm = {'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};

for isubj = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{isubj});
    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    
    fprintf(['Importing data participant ' SubjectInfo.ID '\n'])    
    S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList.CEINMS);
    
     dofListExt=dofList.IK; idx=~contains(dofListExt,{'pelvis' 'lumbar'});
    dofListExt(idx) =  strcat(dofListExt(idx),['_' lower(SubjectInfo.TestedLeg)]);
    Ext = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofListExt);
    % get trial names all with same format (some trials have different names)
    Strials = getstrials(Trials.CEINMS,SubjectInfo.TestedLeg);
    for itrial = 1:length(Trials.CEINMS)
        %% Setup-trial info
        trialName = Trials.CEINMS{itrial};
        SimulationDir = [Dir.CEINMSsimulations fp trialName];
        
        if length(dir(SimulationDir))<3 || ~contains(Strials{itrial},TrialList);   continue;   end
        warning off
        
        disp([trialName '...'])
        
        trialDirs = getosimfilesFAI(Dir,trialName); % load paths for this trial
        
        JCFStruct = importdata(trialDirs.JRAresults);
        TimeWindow = [JCFStruct.data(1,1) JCFStruct.data(end,1)];
        [IK,~] = LoadResults_BG (trialDirs.IKresults,TimeWindow,Ext.coordinates,1);
        [ID,~] = LoadResults_BG (trialDirs.IDresults,TimeWindow,Ext.moments,1);
        
        if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_list'))
            idx = find(contains(Ext.coordinates,'pelvis_list')); IK(:,idx)=-IK(:,idx);end
        
        if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'pelvis_rotation'))
            idx = find(contains(Ext.coordinates,'pelvis_rotation')); IK(:,idx)=-IK(:,idx);end
        
        if contains(SubjectInfo.TestedLeg,'L')&& any(contains(Ext.coordinates,'lumbar_bending'))
            idx = find(contains(Ext.coordinates,'lumbar_bending')); IK(:,idx)=-IK(:,idx); end
        
        G = SortData(G,'IK',IK,Strials{itrial},dofList.IK,isubj);
        G = SortData(G,'ID',ID,Strials{itrial},dofList.IK,isubj);
         
    end 
end

G = MeanBaselineJCF(G);

%%   ==============================================================================================================  %
%%   ================================================ CALLBACK FUCNTIONS ==========================================  %
%%   ==============================================================================================================  %

%-----------------------------------------------------------------------------------------------------------------%
function [G,W,ST,E,BestGamma,dofList,OutVar,savedir] = setupStructure(Subjects,TrialList,update,ReRunSubjects,savedir)% setupStructure
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
%-----------------------------------------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------------------------------------%
function [G,W,ST,E] = ResultsStruct(G,W,ST,E,TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows,ReRunCols)           % create the resuls sruct for G(group data), W(work data), ST(spatiotemporal data) and E(error data)

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
%-----------------------------------------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------------------------------------%
function G = SortData(G,fld,Data,trialName,motionsG,col)                                                            % Sort data
for k = 1:size(Data,2)
    if ~isfield(G.(fld).(motionsG{k}),[trialName])
        G.(fld).(motionsG{k}).([trialName])=[];
    end
    G.(fld).(motionsG{k}).([trialName])(:,col)=Data(:,k);
    
end
%-----------------------------------------------------------------------------------------------------------------%

%-----------------------------------------------------------------------------------------------------------------%
function [G] = MeanBaselineJCF (G,varargin)                                                                         % findMeanBaselineJCF
N = length(G.participants);
for col = 1:N
    if nargin ==1
        G = updateGroup (G,col);
    else
        G = updateGroup_ST (G,col);
    end
end

