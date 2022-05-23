%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Compare all iterations of CEINMS exe and check best RMSE with torque
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   SimulationsDir = [char] directory of the your ceinms simulations for
%   one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% CompareCEINMSIterations
function BestItr = RMSEmomVSemg(Dir,SimulationsDir,SubjectInfo)
tic
fp = filesep;

%% organise folders and directories
cd(SimulationsDir)
[~,trialName]  = fileparts(SimulationsDir);
saveDir = [Dir.Results_CEINMS fp trialName];mkdir(saveDir);

% find the iterations from CEINMS (use if doing multiple comparions, eg: change Gamma values)
files = dir(SimulationsDir);
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
fprintf('finding Gait Cycle... \n')
TimeWindow = TimeWindow_FatFAIS(Dir,trialName);

MatchWord = 1; % 1= yes; 0 = no;
[ID_os,~] = LoadResults_BG ([Dir.ID fp trialName fp 'inverse_dynamics.sto'],...
    TimeWindow,Settings.moments,MatchWord);

[MeasuredEMG,~] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp 'emg.mot'],...
    TimeWindow,Settings.RecordedEMG,MatchWord);

%% compare Joint moments

disp(['Comparing moments'])
R2_mom = [];RMSE_mom = []; RMSE_momRelative = [];
for k = 1:length(OrderedIterations)
    
    fname = OrderedIterations{k};
    fprintf([fname '\n'])
    %load CIENMS Torques
    [ID_itr,Labels] = LoadResults_BG ([SimulationsDir  fp fname fp 'Torques.sto'],...
        TimeWindow,Settings.coordinates,MatchWord);
    if isempty(ID_itr)
        RMSE_mom(k,1:length(Settings.coordinates)) = NaN;
        continue
    end
    
    for kk = 1:length(Settings.coordinates)
        
        % Rsquared
        x = ID_os(:,kk);
        y = ID_itr(1:end,kk);
        [r, pvalue] = corrcoef(x,y);
        R2_mom(k,kk) = round(r(1,2)^2,2);
        pvalue = pvalue(1,2);
        % RMSE
        RMSE_mom(k,kk) = round(rms(y-x),1);
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
saveas(gcf,[SimulationsDir fp 'JointMoments_RMSE.jpeg'])
%% compare excitations
disp(['Comparing excitations'])
R2_exc = [];RMSE_exc = [];RMSE_excRelative = [];
for k = 1:length(OrderedIterations)% loop through CEINMS iterations for the same trial
    
    fname = OrderedIterations{k};
    fprintf([fname '\n'])
    % load CEINMS activations
    [EMG_itr,Labels] = LoadResults_BG ([SimulationsDir  fp fname fp 'AdjustedEmgs.sto'],...
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
saveas(gcf,[SimulationsDir fp  'Excitations_RMSE.jpeg'])
%% compare RMSE excitations and moments
% mean RMSE per iteration
RMSE_exc(RMSE_exc==Inf) = NaN;
M_EMG = nanmean(RMSE_exc,2);
M_mom = nanmean(RMSE_mom,2);
NaNidx = unique([find(isnan(M_EMG)); find(isnan(M_mom))]);

M_EMG(NaNidx)=[];
M_mom(NaNidx)=[];
OrderedIterations(NaNidx)=[];

% best Gamma BG
figure
hold on
NormEMG_RMSE = M_EMG./max(M_EMG);
NormMOM_RMSE = M_mom./max(M_mom);
for  ii = 1:length(NormEMG_RMSE)
    plot(NormEMG_RMSE(ii),NormMOM_RMSE(ii),'.','MarkerSize',20)
end

[~,minIdx] =min(NormEMG_RMSE + NormMOM_RMSE);
ax = gca;
c = ax.Children(length(NormEMG_RMSE)-minIdx+1).Color;
% plot(M_EMG(minIdx),M_mom(minIdx),'.','Color',c,'MarkerSize',40)
plot(NormEMG_RMSE(minIdx),NormMOM_RMSE(minIdx),'.','Color',c,'MarkerSize',40);
F = gca;
lg = legend(F.Children(1),{['best = ' OrderedIterations{minIdx}]},'Interpreter','latex');

xlabel({'mean RMSE EMG ' '(relative to max Error)'})
ylabel({'mean RMSE mom  ' '(relative to max Error)'})
ax.Position = [0.2   0.15    0.5    0.7];
lg.FontSize = 10;
lg.Position = [0.78    0.46    0.0826    0.5928];
mmfn_inspect

BestItr{1,2} = 'mean RMSE mom';
BestItr{1,3} = 'mean RMSE EMG';
BestItr{1,4} = 'mean RMSE mom (%)';
BestItr{1,5} = 'mean RMSE mom (%)';
BestItr{2,1} = OrderedIterations {minIdx};
BestItr{2,2} = M_mom(minIdx);
BestItr{2,3} = M_EMG(minIdx);
BestItr{2,4} = NormMOM_RMSE(minIdx);
BestItr{2,5} = NormEMG_RMSE(minIdx);
cd(SimulationsDir)
saveas(gcf,[SimulationsDir fp 'ErrorMOMvsEMG.jpeg'])
close all
% save fibre kinematics 
save RMSE RMSE_mom RMSE_exc Settings BestItr gamma_opt
