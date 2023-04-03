function [outputArg1,outputArg2] = plot_results()

close all
bops = load_setup_bops;
simulationsdir = 'C:\Git\research_data\TorsionToolAllModels\simulations';
subjects = {getfolders(simulationsdir).name};
sessions = {'pre', 'post'};

[muscles,dofList,jrfList,Results] = get_variables_to_extract();


for iSubj = 1:length(subjects)
    for iSess = 1%:length(sessions)

        subject = subjects{iSubj};
        session = sessions{iSess};
        
        trialsNames         = {getfolders(session_folder,'Dynamic',1).name};
        trialsNames         = trialsNames(contains(trialsNames,'_full'));

        disp(['subject ' subject])
        for iTrial = 1:length(trialsNames)

            current_trial = trialsNames{iTrial};
            trialpath = [session_folder fp current_trial];

            Results.subjects{1,end+1} = subject;
            Results.trials{1,end+1} = trialsNames{iTrial};
            cd(trialpath)

            [Results] = Add_trial_to_Results_strut (simulationsdir,subject,session,current_trial,Results);

        end
    end
end

Results = Results;
save([simulationsdir fp 'results.mat'],'Results')


load([simulationsdir fp 'results.mat'])


ik_id_fig = tight_subplotBG(2,5,0.05,[0.1 0.05],0.05,[0.028 0.23 0.96 0.62]);

N = size(Results.ik.ankle_angle,2);
for i = 1:length(dofList)
    axes(ik_id_fig(i)); hold on                   % IK
    %     M = mean(S.ik.(dofList{i}),2);
    %     SE = std(S.ik.(dofList{i}),0,2)./sqrt(N);
    %     plotShadedSD(M,SE)
    plot(Results.ik.(dofList{i}))
    title(dofList{i},"Interpreter","none")
    yticklabels(yticks)
    if i == 1; ylabel('joint angle (deg)'); end


    axes(ik_id_fig(i+5)); hold on                 % ID
    %     M = mean(S.id.(dofList{i}),2);
    %     SE = std(S.id.(dofList{i}),0,2)./sqrt(N);
    %     plotShadedSD(M,SE)
    plot(Results.ik.(dofList{i}))
    yticklabels(yticks)
    xticklabels(xticks)
    xlabel('% Gait cycle')
    if i == 1; ylabel('joint momnent (Nm/kg)'); end
end
mmfn
saveas(gcf,[simulationsdir fp 'ext_biomech.jpg'])


[muscles_fig,pos,FirstCol,LastRow,LastCol] = tight_subplotBG(n_muscle_groups,0,0.08,0.05,0.05,[0.03 0.11 0.96 0.8]);
for i = 1:n_muscle_groups
    axes(muscles_fig(i)); hold on                   % IK

    plot(Results.so.(muscle_groups{i}))
    title(muscle_groups{i},"Interpreter","none")
    yticklabels(yticks)
    if any(i==FirstCol); ylabel('Muscle forces (N)'); end

    yticklabels(yticks)
    xticklabels(xticks)
    if any(i==LastRow)
        xlabel('% Gait cycle');
        xticklabels(xticks);
    end
end
mmfn
saveas(gcf,[simulationsdir fp 'muscle_forces.jpg'])



[jrf_fig,pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(jrfList),0,0.08,0.05,0.05,[0.03 0.11 0.96 0.8]);
for i = 1:length(jrfList)
    axes(jrf_fig(i)); hold on                   % IK

    plot( Results.jrf.(jrfList{i}))
    title(jrfList{i},"Interpreter","none")
    yticklabels(yticks)
    if any(i==FirstCol); ylabel('Contact forces (N)'); end

    yticklabels(yticks)
    xticklabels(xticks)
    if any(i==LastRow)
        xlabel('% Gait cycle');
        xticklabels(xticks);
    end
end

mmfn
saveas(gcf,[simulationsdir fp 'JCF.jpg'])

%% ===============================================================================================================%
function leg = find_leg(trialpath)

% ImportC3D file and find timing based on events
c3d = btk_loadc3d([trialpath fp 'c3dfile.c3d']);
for i = 1:100
    c3d.Events.Events = TrimStruct (c3d.Events.Events,['C' num2str(i) '_']); % deelte "c_xx" in case events come from mokka
end
event_names = fields(c3d.Events.Events);

if contains(event_names{1},'Right')
    leg = 'r';
else
    leg = 'l';
end

% ===============================================================================================================%
function [muscles,dofList,jrfList,S] = get_variables_to_extract()

muscles = {};
muscles= struct;
muscles.Iliopsoas     = {['iliacus'],['psoas']};
muscles.Hamstrings    = {['bflh'],['bfsh'],['semimem'],['semiten']};
muscles.Gmax          = {['glmax1'],['glmax2'],['glmax3']};
muscles.Gmed          = {['glmed1'],['glmed2'],['glmed3']};
muscles.Gmin          = {['glmin1'],['glmin2'],['glmin3']};
muscles.RecFem        = {['recfem']};
muscles.TFL           = {['tfl']};
muscles.Adductors     = {['addbrev'],['addlong'],['addmagDist'],['addmagIsch'],['addmagMid'],['addmagProx'],['grac']};
muscles.Vasti         = {['vasint'],['vaslat'],['vasmed']};
muscles.Gastroc       = {['gaslat'],['gasmed']};
muscles.Soleus        = {['soleus']};

muscle_groups = fields(muscles);
n_muscle_groups = length(muscle_groups);

dofList = {['hip_flexion'];['hip_adduction'];['hip_rotation'];['knee_angle'];['ankle_angle'];};
jrfList = {['hip_x'];['hip_y'];['hip_z'];['lat_knee_x'];['lat_knee_y'];['lat_knee_z'];['med_knee_x'];['med_knee_y'];['med_knee_z']};

S = struct;
S.subjects = {};
S.trials = {};
for i = 1:length(dofList)
    S.ik.(dofList{i}) = [];
    S.id.(dofList{i}) = [];
end

for i = 1:n_muscle_groups
    S.so.(muscle_groups{i})= [];
end

for i = 1:length(jrfList)
    S.jrf.(jrfList{i}) = [];
end

% ===============================================================================================================%
function [OrderedResults,OrderedLabels] = LoadResults (DataDir,TimeWindow,FieldsOfInterest,MatchWholeWord,Normalise,ConvertToStruct)

warning off

if ~exist('DataDir')
    [filename,pathname] = uigetfile('*.*',cd);
    DataDir = [pathname filename];
end

try Data = importdata(DataDir);
catch
    OrderedResults  = [];
    OrderedLabels   = {};
    disp(['data could not be loaded for:' DataDir])
    return
end

if isempty(Data)||~isstruct(Data)
    OrderedResults=[];
    OrderedLabels=[];
    return
end        % if file is empty or is not struct print empty outputs

Data.data = round(Data.data,4);
[~,uniqueRows]=unique(Data.data(:,1));
Data.data = Data.data(uniqueRows,:);
fs =1/(Data.data(2,1)-Data.data(1,1));

if nargin<2||isempty(TimeWindow)                                                        % if time window is empty get data from beginning till the end
    t = 1; t(2) = size(Data.data,1);
else
    TimeWindow=round(TimeWindow,4);
    [~, closestIndex] = min(abs(Data.data(:,1)-TimeWindow(1))); t =closestIndex;        % initial time
    [~, closestIndex] = min(abs(Data.data(:,1)-TimeWindow(2))); t(2) = closestIndex;    % final time
end

if nargin<3; FieldsOfInterest={};end
if nargin<4; MatchWholeWord = 1;end                                                     % 1 for "yes" (default) or other for "no";
if nargin<5; Normalise=1;end
if nargin<6; ConvertToStruct=0;end

[results,Labels]=findData(Data.data(t(1):t(2),:),Data.colheaders,FieldsOfInterest,MatchWholeWord);      %LoadData

if Normalise==1; results = TimeNorm(results,fs);end                             % time normalise if required

% re order columns
OrderedResults=[];OrderedLabels={};c = 1;
if ~isempty(FieldsOfInterest)
    for i = 1:length(FieldsOfInterest)
        col = find(contains(Labels,FieldsOfInterest{i}));
        if isempty(col)
            OrderedResults(:,c) =NaN;
            OrderedLabels{c} =NaN;
            c=c+1;
            continue
        else
            for ii = 1:length(col)
                OrderedResults(:,c) = results(:,col(ii));
                OrderedLabels{c} = Labels{col(ii)};
                c =c+1;
            end
        end
    end
else
    OrderedResults = results;OrderedLabels =Labels;
end

if ConvertToStruct==1
    S = struct;
    for i =1:length(OrderedLabels)
        S.(OrderedLabels{i}) = OrderedResults(:,i);
    end
    OrderedResults = S;
end

% ===============================================================================================================%
function [Results] = Add_trial_to_Results_strut (simulationsdir,subject,session,current_trial,Results)


session_folder = [simulationsdir fp subject fp session];
subjectInfo = getSubjectInfo(subject);
mass        = subjectInfo.Mass_kg;
height      = subjectInfo.Height_cm/100;


trialpath = [session_folder fp current_trial];

s = find_leg(trialpath);
dofList_ik = strcat(dofList,['_' s]);
dofList_id = strcat(dofList_ik,'_moment');
jrfList_subject = {['hip_' s '_on_pelvis_in_pelvis_fx'],['hip_' s '_on_pelvis_in_pelvis_fy'],['hip_' s '_on_pelvis_in_pelvis_fz'],...
    ['med_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fx'],...
    ['med_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fy'],...
    ['med_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fz'],...
    ['lat_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fx'],...
    ['lat_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fy'],...
    ['lat_cond_joint_' s '_on_sagittal_articulation_frame_' s '_in_sagittal_articulation_frame_' s '_fz']};

[ik,~] = LoadResults('ik.mot',[],dofList_ik,1,1,0);
[id,~] = LoadResults('inverse_dynamics.sto',[],dofList_id,1,1,0);
[so,labels_muscles] = LoadResults('_StaticOptimization_force.sto',[],{},1,1,0);
[jrf,labels_jrf] = LoadResults('_joint reaction analysis_ReactionLoads.sto',[],{},1,1,0);

if contains(s,'l')
    ik(:,3) = -ik(:,3);
    id(:,3) = -id(:,3);
end


for i = 1:length(dofList)
    Results.ik.(dofList{i})(1:101,end+1) = ik(:,i);
    Results.id.(dofList{i})(1:101,end+1)  = id(:,i)./mass;
end

for i = 1:n_muscle_groups
    muscles_to_plot = strcat(muscles.(muscle_groups{i}),['_' s]);
    cols = contains(labels_muscles, muscles_to_plot);
    n_cols = size(find(cols),2);
    Results.so.(muscle_groups{i})(1:101,end+1:end+n_cols) = so(:,cols);
end

for i = 1:length(jrfList)
    jrf_to_plot = jrfList_subject{i};
    cols = contains(labels_jrf, jrf_to_plot);
    n_cols = size(find(cols),2);
    Results.jrf.(jrfList{i})(1:101,end+1:end+n_cols) = jrf(:,cols);
end