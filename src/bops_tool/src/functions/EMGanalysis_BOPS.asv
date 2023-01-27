
% --------------------------------------------------------------------------------------------------------------- %
function EMGanalysis_BOPS

bops = load_setup_bops;

[EMG_final,MuscleNames,trialList_bops] = create_data_struct(bops);

for iSub = 4:length(bops.subjects)
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
                trial_data = EMG_final.(trialName_struct{1}).(subject).(muscle);

                for iContact = 1:length(footContacts)-1                                                             % devide the emg data in multiple gait cycles
                    frames = footContacts(iContact):footContacts(iContact+1);
                    trial_data(:,end+1) = TimeNorm(emgEnvelope(frames,iMuscle),Markers.Rate);                       % time normalise each
                end

                EMG_final.(trialName_struct{1}).(subject).(muscle) = trial_data;
            end
        end
        cmdmsg('EMG analyis finished')
    end
    save([bops.directories.Results fp 'emg.mat'],'EMG_final')
end


trialList = fields(EMG_final.(MuscleNames{1}));
count = 0;
for iTrial = 1:length(trialList)
    for iMuscle = 1
        trialName = trialList{iTrial};
        if size(EMG_final.(MuscleNames{iMuscle}).(trialName),2) > 2 && ~contains(trialName,'og_')
            count = count +1;
        end
    end
end


ha = tight_subplotBG(count);

trialList = fields(EMG_final.(MuscleNames{1}));
count = 0;
for iTrial = 1:length(trialList)
    for iMuscle = 1
        trialName = trialList{iTrial};
        if size(EMG_final.(MuscleNames{iMuscle}).(trialName),2) > 2 && ~contains(trialName,'og_')
            count = count +1;
            axes(ha(count))
            plot(EMG_final.(MuscleNames{iMuscle}).(trialName))
            title([trial_name '_' MuscleNames{iMuscle}])
        end
    end
end


function [EMG_final,MuscleNames,trialList_bops] = create_data_struct(bops)                                          % create the structure to store all data

MuscleNames = {'latgas', 'soleus','recfem', 'tfl','medham'};
trialList_bops = split(bops.Trials.Dynamic);

fprintf('creating struct..')
EMG_final = struct;
for iSub = 1:length(bops.subjects)                                                                                  % loop through subjects
    subject = bops.subjects{iSub};
    for iTrial = 1:length(trialList_bops)                                                                           % loop through dynamic trials 
        for iMusc = 1:length(MuscleNames)                                                                           % loop through muscles
            trialName = trialList_bops{iTrial};
            muscle = MuscleNames{iMusc};
            EMG_final.(trialName).(subject).(muscle)=[];                                                            % struct initiate
        end
    end
end
