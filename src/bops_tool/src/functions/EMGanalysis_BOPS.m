
% --------------------------------------------------------------------------------------------------------------- %
function EMGanalysis_BOPS

bops = load_setup_bops;

% ---------------------------  Settings ------------------------%
MuscleNames = {'latgas', 'soleus','recfem', 'tfl','medham'};
FirstSubject = 1;
colors = colorBG(0,2);
manual_check = 0;
resultsDir = bops.directories.ResultsEMG;
if ~isfolder(resultsDir)
    mkdir(resultsDir)
end

% --------------------------- convert emg to mat structure (if needed) ------------------------%
prompt = ['Want to convert EMGs to mat again?'];
answer = questdlg(prompt,'choice','Convert again','Continue to plotting','Continue');
if isequal(answer,'Convert again')
    gather_mat_data(bops,MuscleNames,FirstSubject);
end

% -------------------------------------- LOAD DATA ------------------------%
load([resultsDir fp 'emg.mat'])
if ~exist('emg'); emg = EMG_final; end

% [empty_trials] = check_missing_data(bops,emg,MuscleNames);

try
    load([resultsDir fp 'checked_emg.mat']);
catch
    checked_emg = emg;
end

% -------------------------- SELECT TRIALS TO PLOT ------------------------%
trialList = fields(emg);
Subjects  = fields(emg.(trialList{1}));                      % Select trials to plot NOT containing
plot_trials = trialList(~contains(trialList,'og_'));                    % "og_"
plot_trials = plot_trials(~contains(plot_trials,'warmup'));             % "warmup"
plot_trials = plot_trials(~contains(plot_trials,'increase'));           % "increase"
plot_trials = plot_trials(~contains(plot_trials,'cmj'));                % "cmj"
plot_trials = plot_trials(~contains(plot_trials,'sprint'));             % "sprint"

nSubPlots = length(plot_trials);  % remove 1 as it is the warmup
nMuscles = length(MuscleNames);

close all
for iSubj = 5:length(Subjects)
    iSubject = bops.subjects{iSubj};
    load_subject_settings(iSubject);  % updates bops settings with current subject and session
    write_bops_log('EMG plotting','start')

    for iTrial = 1:length(plot_trials)
        [ha,pos,FirstCol,LastRow,LastCol] = tight_subplotBG(nMuscles);    % create figure with nSubPlot

        trialName = strrep(plot_trials{iTrial},'avoid','');
        trialName = strrep(trialName,'_','');
        suptitle(['Change ' trialName ' ' iSubject])                 % title whole figure
        for iMuscle = 1:nMuscles

            axes(ha(iMuscle))
            MuscleName = MuscleNames{iMuscle};
            
            % if any 'max_emg'.iSubject,.MuscleName is not on the checked_emg struct, calculate it for this subject/muscle
            if ~isfield(checked_emg,'max_emg') || ~isfield(checked_emg.max_emg,(iSubject)) || ~isfield(checked_emg.max_emg.(iSubject),MuscleName)
                savedir = [resultsDir fp 'replace_' 'emg_from_' MuscleNames{iMuscle} '_' Subjects{iSubj} '.png'];
                [checked_emg] = get_max_emg(bops,checked_emg,iSubject,MuscleName,manual_check,savedir);
            end

            %------------------------------------ PLOT DATA (avoid and increase in same plot) ------------------------------%
            avoid_trial = ['avoid_' trialName '_'];
            savedir = [resultsDir fp avoid_trial 'emg_from_' MuscleNames{iMuscle} '_' Subjects{iSubj} '.png'];
            [checked_emg] = normalise_emg_trial(checked_emg,avoid_trial,iSubject,MuscleName,manual_check,savedir);          % normalise avoid
            [checked_emg] = plot_trial(checked_emg,avoid_trial,iSubject,MuscleName,colors(1,:));                            % plot avoid_trial

            increase_trial = ['increase_' trialName '_'];
            savedir = strrep(savedir,'avoid_','increase_');
            [checked_emg] = normalise_emg_trial(checked_emg,increase_trial,iSubject,MuscleName,manual_check,savedir);        % normalise increase
            [checked_emg] = plot_trial(checked_emg,increase_trial,iSubject,MuscleName,colors(2,:));                          % plot increase_trial
            %----------------------------------------------- PLOT DATA ------------------------------------------------------%
        end
        mmfn_inspect % make figure nice
        tight_subplot_ticks(ha,LastRow,FirstCol)
        ax = gca;
        if size(ax.Children,1) == 4
            lg = legend(ax.Children([2,4]),{'increase' 'avoid'}); % LEGEND (decrease purple / increase blue)
        else
            lg = legend(ax.Children([2,4,6]),{'increase' 'normal' 'avoid'});
        end
        lg.Box = 'off';
        lg.Position = [0.65 0.22 0.05 0.05];

        saveas(gcf,[resultsDir fp trialName fp 'mean_' trialName '_' iSubject '.png'])
        savefig(gcf,[resultsDir fp trialName 'mean_' trialName '_' iSubject '.fig'])
        close all
    end
    save([resultsDir fp 'checked_emg.mat'],'checked_emg')
    write_bops_log
end


addLabelsToPlots(checked_emg,resultsDir)


%------------------------------------------------------ Functions -----------------------------------------------%
%----------------------------------------------------------------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------%

%------------------------------    create the structure to store all data     -----------------------------------%
function [emg] = create_data_struct(bops,MuscleNames)

trialList_bops = [split(bops.Trials.Dynamic) split(bops.Trials.MaxEMG)];
fprintf('creating struct..')
emg = struct;
for iSub = 1:length(bops.subjects)                                                                                  % loop through subjects
    subject = bops.subjects{iSub};
    for iTrial = 1:length(trialList_bops)                                                                           % loop through dynamic trials
        for iMusc = 1:length(MuscleNames)                                                                           % loop through muscles
            trialName = trialList_bops{iTrial};
            muscle = MuscleNames{iMusc};
            emg.(trialName).(subject).(muscle)=[];                                                            % struct initiate
        end
    end
end
%----------------------------------------------------------------------------------------------------------------%

%------------------------------------------ gather_mat_data -----------------------------------------------------%
function gather_mat_data(bops,MuscleNames,FirstSubject)

[emg] = create_data_struct(bops,MuscleNames);  % create_data_strucr
trialList_bops = [split(bops.Trials.Dynamic) split(bops.Trials.MaxEMG)];

for iSub = FirstSubject:length(bops.subjects)
    for iSess = 1:length(bops.sessions)

        subject = bops.subjects{iSub};
        session = bops.sessions{iSess};
        settings = load_subject_settings(subject,session,'EMGanalysis');
        if isempty(settings); continue; else; end

        fprintf('%s - %s \n',subject,session)
        trialList_subject   = settings.trials.names';                                                               % get trials from xml

        for iTrial = 1:length(trialList_subject)

            trialName = trialList_subject{iTrial};
            for trialName_struct = trialList_bops
                if contains(trialName,trialName_struct{1}) == 1; break; end                                         % find which trial_type
            end

            emgDataDir = [settings.directories.sessionData fp trialName fp 'AnalogData.mat'];
            markerDataDir = [settings.directories.sessionData fp trialName fp 'Markers.mat'];
            if ~isfile(emgDataDir); continue; end

            load(emgDataDir);                                                                                       % load EMG
            load(markerDataDir);                                                                                    % load marker data

            markerRate  = Markers.Rate;                                                                             % get marker rate
            emgRate     = AnalogData.Rate;                                                                          % get EMG rate
            bp = bops.filters.EMGbp;                                                                                % filter settings
            lp = bops.filters.EMGlp;
            try
                emgLabels = bops.emg.Muscle;
                emgRaw = AnalogData.RawData(:,find(contains(AnalogData.Labels,emgLabels)));
                emgEnvelope = downsample(EMGLinearEnvelope(emgRaw,emgRate,bp,lp),emgRate/markerRate);                   % downsample EMG to marker rate and get linear envelope (filter)
            catch
                warning(['EMG data doesnt exist for ' trialName])
                continue
            end

            try
                marker_cols = find(contains(Markers.Labels,'RHEE'))*3;
                heel_marker = Markers.RawData(:,marker_cols:marker_cols+2);
                heel_marker_filt = ZeroLagButtFiltfilt((1/Markers.Rate), 2, 2, 'lp', heel_marker);                      % filter marker trajectories

                [~,footContacts]=findpeaks(-heel_marker_filt(:,1));                                                     % find contacts as the peaks of the right heel marker
            catch
                warning(['marker data doesnt exist for ' trialName])
                continue
            end

            for iMuscle = 1:5
                muscle = MuscleNames{iMuscle};
                trial_data = emg.(trialName_struct{1}).(subject).(muscle);

                for iContact = 1:length(footContacts)-1                                                             % devide the emg data in multiple gait cycles
                    frames = footContacts(iContact):footContacts(iContact+1);
                    trial_data(:,end+1) = TimeNorm(emgEnvelope(frames,iMuscle),Markers.Rate);                       % time normalise each
                end

                emg.(trialName_struct{1}).(subject).(muscle) = trial_data;
            end
        end
        cmdmsg('EMG analyis finished')
    end
    save([bops.directories.ResultsEMG fp 'emg.mat'],'emg')
end
%----------------------------------------------------------------------------------------------------------------%

%----------------------------------------- normalise_emg_trial --------------------------------------------------%
function [emg] = normalise_emg_trial(emg,trialName,Subject,MuscleName,manual_check,savedir)

muscle_emg = emg.(trialName).(Subject).(MuscleName);
muscle_emg_checked = select_good_curves(muscle_emg,MuscleName,manual_check,savedir);                                % select good emg curves

max_emg = emg.max_emg.(Subject).(MuscleName);
emg.(trialName).(Subject).(MuscleName) = muscle_emg_checked./max_emg*100;
%----------------------------------------------------------------------------------------------------------------%

%-------------------------------------------- get_max_emg -------------------------------------------------------%
function [emg] = get_max_emg(bops,emg,Subject,MuscleName,manual_check,savedir_generic)

% get max EMG from certain trials
max_triaNames = bops.Trials.MaxEMG;    
max_triaNames = max_triaNames(contains(max_triaNames,'sprint'));    
max_emg = [];
for iMax = 1:length(max_triaNames)
    trial_emg = emg.(max_triaNames{iMax}).(Subject).(MuscleName);
    if ~isempty(trial_emg)
        savedir_max = strrep(savedir_generic, 'replace',max_triaNames{iMax});
        max_emg_trial = max(max(select_good_curves(trial_emg,MuscleName,manual_check,savedir_max)));                % select good emg curves
        max_emg = max([max_emg max_emg_trial]);
    end
end


if ~isempty(emg.warmup_.(Subject).(MuscleName))
    normal_value = emg.warmup_.(Subject).(MuscleName);
    savedir_warmup = strrep(savedir_generic, 'replace','warmup');
    normal_value = select_good_curves(normal_value,MuscleName,manual_check,savedir_warmup);
    emg.warmup_.(Subject).(MuscleName) = normal_value./max_emg*100;
end

emg.max_emg.(Subject).(MuscleName) = max_emg;
%----------------------------------------------------------------------------------------------------------------%

%------------------------------------------- PLOT MEAN DATA -----------------------------------------------------%
function [emg] = plot_trial(emg,trialName,Subject,MuscleName,colors)
muscle_emg_checked = emg.(trialName).(Subject).(MuscleName);

M = mean(muscle_emg_checked,2);
SE = std(muscle_emg_checked,0,2)./sqrt(size(muscle_emg_checked,2));
plotShadedSD(M,SE,colors)       % plot mean and SE data

% plot mean warmup data if it exists AND only when plotting the 'avoid'
% data not to have repeats
if ~isempty(emg.warmup_.(Subject).(MuscleName)) && contains(trialName,'avoid') 
    M = mean(emg.warmup_.(Subject).(MuscleName),2);
    SE = std(emg.warmup_.(Subject).(MuscleName),0,2)./sqrt(size(muscle_emg_checked,2));
    plotShadedSD(M,SE,[0.6 0.6 0.6])       % plot mean and SE data
end

title([MuscleName])
%----------------------------------------------------------------------------------------------------------------%

%------------------- Select good curves basedon correlation between mean and individual curves ------------------%
function M_out = select_good_curves(M,title_plot,manual_check,savedir)

%% ------------------- Automatic slection ---------------------%
% -----------------------------------------------------------%
%-------------------------------------------------------------%
if contains(title_plot,'recfem') || contains(title_plot,'tfl')
    Rthreshold = 0.6;
else
    Rthreshold = 0.5;
end

%-------delete M columns with value greater than 5 or below 5% of the trial range -----------------------%
%--------------------------------------------------------------------------------------------------------%
M(:,any(M>5,1)) = [];                           % > 5
M(:,all(M<max(range(M)).*0.05,1)) = [];         % < 5% of signal amplitude trhoughout all trial
%--------------------------------------------------------------------------------------------------------%
Deleted_curves = NaN(size(M,1),1);
M_out = M;
count = 0;
medianM = median(M,2);
conitnue_while = 1;
factor = 1;                                 % use this factor to adjust the peason correlation AND median threshold 
while conitnue_while == 1
    M_out = M;
    Upper_three_IQR_M = medianM + iqr(M,2)/2  * 3 * factor;   % upper/lower range based on IQR
    Lower_three_IQR_M = medianM - iqr(M,2)/2  * 3 * factor;

    for iCol = flip(1:size(M_out,2))
        r = corrcoef(medianM,M_out(:,iCol));            % correlation between mean and individual curves

        isCorr_lower = abs(r(1,2)) < Rthreshold / factor;
        framesAboveIQR = sum(M_out(:,iCol) > Upper_three_IQR_M);
        framesBelowIQR = sum(M_out(:,iCol) < Lower_three_IQR_M);

        if  isCorr_lower || framesAboveIQR > 10 || framesBelowIQR> 10
            count = count + 1;
            Deleted_curves(:,count) = M_out(:,iCol);
            M_out(:,iCol) = [];
        end
    end

    if size(M_out,2) > 2                    % needs at least 3 trials smilar to eachother
        conitnue_while = 0;
    else
        factor = factor + 0.1;
        conitnue_while = 1;
    end

end
final_fig = figure;
final_fig.Position = [173.6000  321.8000  560.0000  420.0000];
hold on
bad_curves = plot(Deleted_curves,'r--');
good_curves = plot(M_out,'g');
mean_line = plot(mean(M,2),'k--');
new_mean_line = plot(mean(M_out,2),'k:');
plot(Upper_three_IQR_M,'b--')
plot(Lower_three_IQR_M,'b--')

split_savedir = split(savedir,fp);
title(split_savedir{end},'Interpreter','none')
legend([mean_line(1) new_mean_line(1) good_curves(1),bad_curves(1)],{'mean original' 'mean without deleted' 'good curves' 'bad curves'})
mmfn_inspect
if manual_check == 0
    saveas(gcf,savedir)                                      % save and close fig
    close(final_fig)
end


%% ------------------Delete individual curves------------------%
% -------------------------------------------------------------%
% -------------------------------------------------------------%

if manual_check == 1
    prompt = ['Check lines manually?'];     % if bopsSettings does not exist in current project
    answer = questdlg(prompt,'choice','Check manually','Delete one line','This is good!','');

    while isequal(answer,'Delete one line')
        [~,y] = ginput(1);
        min_val = [];
        for iCol = 1:size(M_out,2)
            [min_val(iCol),~] = min([min(abs(M_out(:,iCol)-y)) min_val]);
        end
        [~,selected_curve] = min(min_val);

        Deleted_curves(:,end+1) = M_out(:,selected_curve);
        M_out(:,selected_curve) = [];

        delete(bad_curves); bad_curves = plot(Deleted_curves,'r--');
        delete(good_curves); good_curves = plot(M_out,'g');
        delete(mean_line); mean_line = plot(mean(M,2),'k--');
        delete(new_mean_line); new_mean_line = plot(mean(M_out,2),'k--');

        answer = questdlg(prompt,'choice','Check manually','Delete one line','This is good!','');
    end

    saveas(gcf,savedir)                                      % save and close fig
    close(final_fig)

else
    answer = 'This is good!';                                                                                   % coment to make selection manual
end
%% ------------------Manual slection---------------------------%
% -------------------------------------------------------------%
% -------------------------------------------------------------%

while isequal(answer,'Check manually')
    check_fig = figure;
    M_out = M;
    hold on
    if nargin ==2
        title(title_plot)
    end

    count = 0;
    for iCol = flip(1:size(M,2))
        p = plot(M_out(:,iCol));
        mmfn_inspect
        [x,y] = ginput(1);
        if x < 1
            count = count + 1;
            Deleted_curves(:,count) = M_out(:,iCol);
            M_out(:,iCol) = [];
            delete(p)
            delete(mean_line)
            mean_line = plot(mean(M_out,2),'k--');
        else
            p.Color = [0.8 0.8 0.8];
        end
    end

    check_fig.Position = [794.6000  321.8000  560.0000  420.0000];
    final_fig =figure;
    final_fig.Position = [173.6000  321.8000  560.0000  420.0000];
    hold on
    bad_curves = plot(Deleted_curves,'r--');
    good_curves = plot(M_out,'g');
    legend([good_curves(1),bad_curves(1)],{'good curves' 'bad curves'})
    mmfn_inspect

    prompt = ['Check lines again?'];     % if bopsSettings does not exist in current project
    answer = questdlg(prompt,'choice','Check manually','No, delete red lines!','');
    close(check_fig)
    close(final_fig)
end
%----------------------------------------------------------------------------------------------------------------%

%------------------------------------------ check_missing_data --------------------------------------------------%
function [empty_trials] = check_missing_data(bops,emg,MuscleNames)

trialList = fields(emg);
Subjects  = fields(emg.(trialList{1}));
nMuscles = length(MuscleNames);
empty_trials = {};
for iSubj = 1:length(Subjects)                  % loop subjects
    iSubject = bops.subjects{iSubj};

    for iTrial = 1:length(trialList)                    % loop trials
        trialName = trialList{iTrial};

        for iMuscle = 1:nMuscles                            % loop muscles
            MuscleName = MuscleNames{iMuscle};
            if isempty(emg.(trialName).(iSubject).(MuscleName))             
                empty_trials = [empty_trials [trialName '_' iSubject '_' MuscleName]];  % if trial is empy, save its name
            end

        end
    end
end

empty_trials = empty_trials';
%----------------------------------------------------------------------------------------------------------------%

%------------------------------------------ check_missing_data --------------------------------------------------%
function addLabelsToPlots(emg,resultsDir)

trialList = fields(emg);
plot_trials = trialList(~contains(trialList,'og_'));                    % "og_"
plot_trials = plot_trials(~contains(plot_trials,'warmup'));             % "warmup"
plot_trials = plot_trials(~contains(plot_trials,'increase'));           % "increase"
plot_trials = plot_trials(~contains(plot_trials,'cmj'));                % "cmj"
plot_trials = plot_trials(~contains(plot_trials,'sprint'));             % "sprint"
plot_trials = plot_trials(~contains(plot_trials,'max_emg'));            % "max_emg"

Subjects  = fields(emg.(trialList{1}));
for iSubj = 1:length(Subjects)                  % loop subjects
    iSubject = bops.subjects{iSubj};

    for iTrial = 1:length(plot_trials)                    % loop trials
        trialName = plot_trials{iTrial};
        trialName = strrep(trialName,'avoid_','');
        trialName = strrep(trialName,'_','');

        uiopen([resultsDir fp trialName fp 'mean_' trialName '_' iSubject '.fig'],1);
        f = gcf;
        ha = f.Children;
        ha_ordered = ha;
        idx = [];
        for i=1:length(ha)
            if ~contains(class(ha(i)),'Axes')
                idx = [idx i];
            else
                ha(i).Position(1) = ha(i).Position(1)+0.03;
                ha(i).Position(2) = ha(i).Position(2)+0.05;
                ha(i).Position(3) = ha(i).Position(3)*0.9;
                ha(i).Position(4) = ha(i).Position(4)*0.9;
                if contains(ha(i).Title.String,'latgas')
                    ha_ordered(1) = ha(i);
                elseif contains(ha(i).Title.String,'soleus')
                    ha_ordered(2) = ha(i);
                elseif contains(ha(i).Title.String,'recfem')
                    ha_ordered(3) = ha(i);
                elseif contains(ha(i).Title.String,'tfl')
                    ha_ordered(4) = ha(i);
                elseif contains(ha(i).Title.String,'medham')
                    ha_ordered(5) = ha(i);
                elseif contains(ha(i).Title.String,'')
                    idx_title = i;
                end
            end
        end

        ha_ordered(6:7) = [];
        tight_subplot_ticks(ha_ordered,[3,4,5],0)
        ha_ordered(6) = ha(idx_title);
        ha_ordered(6).Position(2) = ha_ordered(6).Position(2) -0.04; 
        ha_ordered(1).YLabel.String = 'activation (% of sprint)';
        ha_ordered(4).YLabel.String = 'activation (% of sprint)';

        ha_ordered(3).XLabel.String = '% of gait cycle';
        ha_ordered(4).XLabel.String = '% of gait cycle';
        ha_ordered(5).XLabel.String = '% of gait cycle';

        saveas(gcf,[resultsDir fp trialName fp 'mean_' trialName '_' iSubject '.png'])
        savefig(gcf,[resultsDir fp trialName fp 'mean_' trialName '_' iSubject '.fig'])
        close all

    end
end
%----------------------------------------------------------------------------------------------------------------%




