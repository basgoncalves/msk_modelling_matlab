% OptimalGamma = OptimalGammaCEINMS_BG(Dir,SimulationsDir,SubjectInfo)

% Compare all iterations of CEINMS exe and check best RMSE with torque
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   SimulationsDir = [char] directory of the your ceinms simulations for one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%   OptimalGamma
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
% written by Basilio Goncalves (2020) - https://www.researchgate.net/profile/Basilio_Goncalves
%% CompareCEINMSIterations
function OptimalGamma = OptimalGammaCEINMS_BG_old(Dir,SimulationDir,SubjectInfo)

fp = filesep;
if exist([SimulationDir fp 'OptimalGamma.mat'])
    load([SimulationDir fp 'OptimalGamma.mat'])
    OptimalGamma.DirDiff = strrep(OptimalGamma.DirDiff,fileparts(OptimalGamma.DirDiff),SimulationDir);  
    OptimalGamma.DirSum = strrep(OptimalGamma.DirSum,fileparts(OptimalGamma.DirSum),SimulationDir);
%     cmdmsg('OptimalGamma.mat already existed. Old file loaded')
    return
end
%% organise folders and directories
cd(SimulationDir)
[~,trialName]  = fileparts(SimulationDir);
ConvetedTrialName = getstrials({trialName},SubjectInfo.TestedLeg);ConvetedTrialName=ConvetedTrialName{1};

% find the iterations from CEINMS (use if doing multiple comparions, eg: change Gamma values)
files = dir(SimulationDir);
files(1:2) = [];
idx = ~[files.isdir];% delete names that are not files
files(idx) = [];
OrderedIterations = natsortfiles({files.name}');

%% define labels
s = lower(SubjectInfo.TestedLeg);
dofList = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
Settings = getOSIMVariablesFAI(SubjectInfo.TestedLeg,Dir.OSIM_LO,dofList);

exctGern = xml_read([Dir.CEINMSexcitationGenerator fp 'excitationGenerator.xml']);
inputEMG = struct;
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if contains(muscle,Settings.AllMuscles) && ~isempty(exctGern.mapping.excitation(m).input)
       inputEMG.(muscle) = exctGern.mapping.excitation(m).input.CONTENT;
    end
end
Settings.RecordedMuscles = fields(inputEMG);

%%  load ID, IK and measaured EMG
OSfiles = getosimfilesFAI(Dir,trialName); % directories of all the files related to this trial
TrialsXML = xml_read([Dir.CEINMStrials fp trialName '.xml']);
TimeWindow = TrialsXML.startStopTime;
MatchWord = 1; % 1= yes; 0 = no;
[ID_os,~] = LoadResults_BG (OSfiles.IDresults,TimeWindow,Settings.moments,MatchWord);
[MeasuredEMG,~] = LoadResults_BG (OSfiles.emg,TimeWindow,Settings.RecordedEMG,MatchWord);

%% compare Joint moments
disp(['Comparing moments'])
R2_mom = [];RMSE_mom = []; RMSE_momRelative = [];
for k = 1:length(OrderedIterations)
    
    fname = OrderedIterations{k};
    fprintf([fname '\n'])
    %load CIENMS Torques
    [ID_itr,~] = LoadResults_BG ([SimulationDir  fp fname fp 'Torques.sto'],TimeWindow,Settings.coordinates,MatchWord);
    if isempty(ID_itr); RMSE_mom(k,1:length(Settings.coordinates)) = NaN; continue; end
    
    for kk = 1:length(Settings.coordinates)
        x = ID_os(:,kk);
        y = ID_itr(1:end,kk);
        [r, ~] = corrcoef(x,y);
        R2_mom(k,kk) = round(r(1,2)^2,2);            % r squared
        RMSE_mom(k,kk) = round(rms(y-x),1);          % RMSE
    end
end
%% plot error for each joint
[ha, ~,FirstCol, LastRow] = tight_subplotBG(2,1,0.05,0.2,0.2,[60 60 1700 900]);
YT = strrep(OrderedIterations,'_', ' ');
axes(ha(1));bar(RMSE_mom, 'FaceColor','flat');
setupPlot([],'RMSE Moment(Nm)',{},{},{},0,...
    [],{},{},{''},[],{},...
    [],[],20);
axes(ha(2));bar(R2_mom, 'FaceColor','flat');
setupPlot([],'R^2 Moment',{},{},{},0,...
    [],{},{},YT(xticks),45,{},...
    [],[],20);

legend(Settings.coordinates,'FontSize',12,'Orientation','horizontal',...
    'Position',[0.5    0.9    0.1    0.05],'Interpreter','latex');
mmfn_inspect
saveas(gcf,[SimulationDir fp 'JointMoments_RMSE.jpeg'])
%% compare excitations
disp(['Comparing excitations'])
R2_exc = [];RMSE_exc = [];RMSE_excRelative = [];
for k = 1:length(OrderedIterations)% loop through CEINMS iterations for the same trial
    
    fname = OrderedIterations{k};
    fprintf([fname '\n'])
    % load CEINMS activations
    [EMG_itr,Labels] = LoadResults_BG ([SimulationDir  fp fname fp 'AdjustedEmgs.sto'],...
        TimeWindow,Settings.RecordedMuscles,0);
    
    if isempty(EMG_itr)
        RMSE_exc(k,1:length(Settings.RecordedMuscles)) = NaN;
        continue
    end
   
    for kk = 1:length(Settings.RecordedMuscles) 
        idx = strcmp(strtrim(Settings.RecordedEMG),inputEMG.(Labels{kk}));
        x = MeasuredEMG(:,idx);
        y = EMG_itr(:,kk);
        [r, pvalue] = corrcoef(x,y);
        R2_exc(k,kk) = round(r(1,2)^2,2);
        % RMSE as a percentage of the range
        RMSE_exc(k,kk) = rms(y-x);
    end
end

RMSE_exc(isinf(RMSE_exc)) = NaN;
%% plot error for each muscle
[ha, ~,FirstCol, LastRow] = tight_subplotBG(2,1,0.05,0.2,0.2,[60 60 1700 900]);
YT = strrep(OrderedIterations,'_', ' ');
axes(ha(1));bar(RMSE_exc, 'FaceColor','flat');
setupPlot([],'RMSE EMG',{},{},{},0,...
    [],{},{},{''},[],{},...
    [],[],20);
axes(ha(2));bar(R2_exc, 'FaceColor','flat');
setupPlot([],'R^2 EMG',{},{},{},0,...
    [],{},{},YT(xticks),45,{},...
    [],[],20);
lg = legend(Settings.RecordedMuscles,'FontSize',12,'Orientation','horizontal',...
    'Position',[0.5    0.9    0.1    0.05],'Interpreter','latex');
pause(0.2)
lg.NumColumns=ceil(lg.NumColumns/3);
mmfn_inspect
saveas(gcf,[SimulationDir fp  'Excitations_RMSE.jpeg'])
%% compare RMSE excitations and moments
% mean RMSE per iteration
RMSE_exc(RMSE_exc==Inf) = NaN;
M_EMG = nanmean(RMSE_exc,2);
M_mom = nanmean(RMSE_mom,2);
NaNidx = unique([find(isnan(M_EMG)); find(isnan(M_mom))]);

M_EMG(NaNidx)=[];
M_mom(NaNidx)=[];
OrderedIterations(NaNidx)=[];

% find alphas,betas,gammas
gammas=[];
for k = 1:length(OrderedIterations)
    idxG = strfind(OrderedIterations{k},'G')+1;
    gammas(k,1) = str2double(OrderedIterations{k}(idxG:end));
end
idxA = strfind(OrderedIterations{k},'A')+1;
idxB = strfind(OrderedIterations{k},'B')+1;
A = str2double(OrderedIterations{k}(idxA:idxB-3));
B = str2double(OrderedIterations{k}(idxB:idxG-3));

gamma_opt_Diff_EMG_MOM = MinimiseEMGandMOMerr_BG (gammas,M_EMG,M_mom); % find gamma (code from KV)
suptitle (['Beta = ' num2str(B)])
saveas(gcf,[SimulationDir fp 'OptimalGamma_Diff.jpeg'])
gamma_opt_Sum_EMG_MOM = Minimise_Sum_EMGandMOMerr_BG (gammas,M_EMG,M_mom);
suptitle (['Beta = ' num2str(B)])
saveas(gcf,[SimulationDir fp 'OptimalGamma_Sum.jpeg'])

OptimalGamma= struct;
OptimalGamma.Alpha = A;
OptimalGamma.Beta = B;

OptimalGamma.Gamma_MinDiff = gamma_opt_Diff_EMG_MOM;
OptimalGamma.DirDiff = [Dir.CEINMSsimulations fp trialName fp sprintf('A%.f_B%.f_G%.f',A,B,gamma_opt_Diff_EMG_MOM)];

OptimalGamma.Gamma_MinSum = gamma_opt_Sum_EMG_MOM;
OptimalGamma.DirSum = [Dir.CEINMSsimulations fp trialName fp sprintf('A%.f_B%.f_G%.f',A,B,gamma_opt_Sum_EMG_MOM)];

% save results
cd(SimulationDir)
save OptimalGamma OptimalGamma RMSE_mom RMSE_exc OrderedIterations Settings

close all


