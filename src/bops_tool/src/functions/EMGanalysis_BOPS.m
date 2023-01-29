
% --------------------------------------------------------------------------------------------------------------- %
function EMGanalysis_BOPS

    bops = load_setup_bops;
    
    % settings
    MuscleNames = {'latgas', 'soleus','recfem', 'tfl','medham'};
    FirstSubject = 1;
    colors = colorBG(0,2); 
    manual_check = 0;
    
    for iSub = 4:length(bops.subjects)
    % convert emg to mat structure
    prompt = ['Want to convert EMGs to mat again?'];
    answer = questdlg(prompt,'choice','Convert again','Continue to plotting','Continue');
    if isequal(answer,'Convert again')
        gather_mat_data(bops,MuscleNames,FirstSubject);
    end
    
    % plot data
    load([bops.directories.Results fp 'emg.mat'])
    if ~exist('emg')
        emg = EMG_final;
    end
    
    trialList = fields(emg);
    Subjects  = fields(emg.(trialList{1}));                      % Select trials to plot 
    plot_trials = trialList(~contains(trialList,'og_'));                    % NOT containing "og_"
    plot_trials = plot_trials(~contains(plot_trials,'warmup'));             % NOT containing "warmup"
    plot_trials = plot_trials(~contains(plot_trials,'increase'));           % NOT containing "increase"
    
    nSubPlots = length(plot_trials);  % remove 1 as it is the warmup
    nMuscles = length(MuscleNames);
    checked_emg = emg;
    close all
    for iSubj = 1%:lengh(Subjects)
        for iTrial = 1:length(plot_trials)
            [ha,pos,FirstCol,LastRow,LastCol] = tight_subplotBG(nMuscles);    % create figure with nSubPlot
            
            trialName = strrep(trialList{iTrial},'avoid','');
            trialName = strrep(trialName,'_','');
            suptitle(['Change ' trialName ' ' Subjects{iSubj}])                 % title whole figure
            for iMuscle = 1:nMuscles
                
                axes(ha(iMuscle))
                %----------------------------------------------- PLOT DATA ------------------------------------------------------%
                avoid_trial = ['avoid_' trialName '_'];
                savedir = [bops.directories.Results fp avoid_trial Subjects{iSubj} '.png'];
                [checked_emg] = plot_trial(checked_emg,avoid_trial,Subjects{iSubj},MuscleNames{iMuscle},colors(1,:),manual_check,savedir);
                
                increase_trial = ['increase_' trialName '_'];
                savedir = [bops.directories.Results fp increase_trial Subjects{iSubj} '.png'];
                [checked_emg] = plot_trial(checked_emg,increase_trial,Subjects{iSubj},MuscleNames{iMuscle},colors(2,:),manual_check,savedir);
                %----------------------------------------------- PLOT DATA ------------------------------------------------------%
            end
            mmfn_inspect % make figure nice 
            tight_subplot_ticks(ha,LastRow,FirstCol)  
            ax = gca;
            legend(ax.Children([2,4]),{'increase' 'avoid'})                         % LEGEND (avoid ploted first but ax.Children stars from the last ploted line)
            saveas(gcf,[bops.directories.Results fp trialName '_' Subjects{iSubj} '.png'])
            close all
            save([bops.directories.Results fp 'checked_emg.mat'],'checked_emg')
        end
    end
    checked_emg
    
    %------------------------------------------------------ Functions -----------------------------------------------%
    %----------------------------------------------------------------------------------------------------------------%
    %----------------------------------------------------------------------------------------------------------------%
    %----------------------------------------------------------------------------------------------------------------%
    %----------------------------------------------------------------------------------------------------------------%
    
    %------------------------------    create the structure to store all data     -----------------------------------%
    function [emg] = create_data_struct(bops,MuscleNames)
    
    trialList_bops = split(bops.Trials.Dynamic);
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
    
    %----------------------------------------------------------------------------------------------------------------%
    function gather_mat_data(bops,MuscleNames,FirstSubject)
    
    [emg] = create_data_struct(bops,MuscleNames);  % create_data_strucr
    trialList_bops = [split(bops.Trials.Dynamic) split(bops.Trials.MaxEMG)];
    
    for iSub = FirstSubject:length(bops.subjects)
        for iSess = 1:length(bops.sessions)
            
            subject = bops.subjects{iSub};
            session = bops.sessions{iSess};
            
            settings = load_subject_settings(subject,session,'EMGanalysis');
            if isempty(settings); continue; end
            
            fprintf('%s - %s \n',subject,session)
            trialList_subject   = settings.trials.dynamic';                                                             % get trials from xml
            
            for iTrial = 1:length(trialList_subject)
                
                trialName = trialList_subject{iTrial};
                for trialName_struct = trialList_bops
                    if contains(trialName,trialName_struct{1}) == 1; break; end                                         % find which trial_type
                end
                
                %             [osimFiles] = getdirosimfiles_BOPS(trialName);                                                          % get directories of opensim files for this trial
                
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
        save([bops.directories.Results fp 'emg.mat'],'emg')
    end
    %----------------------------------------------------------------------------------------------------------------%
    
    %----------------------------------------------- PLOT DATA ------------------------------------------------------%
    function [emg] = plot_trial(emg,avoid_trial,Subject,MuscleName,colors,manual_check,savedir)
    muscle_emg = emg.(avoid_trial).(Subject).(MuscleName);
    muscle_emg_checked = select_good_curves(muscle_emg,MuscleName,manual_check,savedir);                                % select good emg decrease
    emg.(avoid_trial).(Subject).(MuscleName) = muscle_emg_checked;
    M = mean(muscle_emg_checked,2);
    SD = std(muscle_emg_checked,0,2);
    plotShadedSD(M,SD,colors)                                                                                           % plot data
    title([MuscleName])
    %----------------------------------------------------------------------------------------------------------------%
    
    %------------------- Select good curves basedon correlation between mean and individual curves ------------------%
    function M_out = select_good_curves(M,title_plot,manual_check,savedir)
    
    bops = load_setup_bops;
    
    Deleted_curves=[];
    M_out = M;
    count = 0;
    if contains(title_plot,'recfem') || contains(title_plot,'tfl')
        threshold = 0.3;
    else
        threshold = 0.7;
    end
    
    meanM = mean(M,2);
    for iCol = flip(1:size(M_out,2))
        r = corrcoef(meanM,M_out(:,iCol));  % correlation between mean and individual curves
        if abs(r(1,2)) < threshold
            count = count + 1;
            Deleted_curves(:,count) = M_out(:,iCol);
            M_out(:,iCol) = [];
        end
    end
    final_fig = figure;
    final_fig.Position = [173.6000  321.8000  560.0000  420.0000];
    hold on
    bad_curves = plot(Deleted_curves,'r--');
    good_curves = plot(M_out,'g');
    mean_line = plot(mean(M,2),'k--');
    new_mean_line = plot(mean(M_out,2),'k--');
    
    legend([mean_line(1) new_mean_line(1) good_curves(1),bad_curves(1)],{'mean original' 'mean without deleted' 'good curves' 'bad curves'})
    mmfn_inspect
    
    if manual_check == 1
        prompt = ['Check lines manually?'];     % if bopsSettings does not exist in current project
        answer = questdlg(prompt,'choice','Check manually','Delete one line','This is good!','');
    else
        answer = 'This is good!';                                                                                   % coment to make selection manual
    end
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
    