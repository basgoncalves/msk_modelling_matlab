% see example data folder
% use this with "MaxEMG_hams" script

fp = filesep;
cd(DirEMGdata)
% Directory contains 2 mat files per trial 
Files = dir([DirEMGdata fp '*.mat']);
EMG = struct; % create struct with all the subjects and trials better organised
% loop through subjects
for k = 2:2:length(Files) 
    subject = strrep(Files(k).name,'_selected.mat','');
    
    disp(['arranging ' subject '...'])
    
    load([Files(k).name])
    load([subject '.mat'], 'description')
    fsEMG = description.filter_data.emg.sample_freq;
    fsForce = description.filter_data.force.sample_freq;
    Fch = find(contains(description.channels,'force_right')); %force channel index
    
    fld = fields(selectedTrials);
    
    %% find fields with same name
    TrialType = {};
    for Trial = 2 : length (fld)
        
        % the full name of 1st trial witout the numbers, eg.: HE_1 => HE
        if any(regexp(fld{Trial-1}(end-1:end) ,'[0-9]'))
            Compare_1 = fld{Trial-1}(1:end-2);
        else 
            Compare_1 = fld{Trial-1};
        end
        % the full name of 2nd trial witout the numbers, eg.: HE_1 => HE
        if any(regexp(fld{Trial}(end-1:end) ,'[0-9]'))
            Compare_2 = fld{Trial}(1:end-2);
        else
             Compare_2 = fld{Trial};
        end
        N = max([length(Compare_1),length(Compare_2)]);
        
        if strncmp(Compare_1,Compare_2,N)==0      % comapre the current Trial name with the previous one
            TrialType {end+1} = Compare_1;
        elseif Trial == length (fld)
            TrialType {end+1} = Compare_1;
        end
    end
    
    TrialType = unique(TrialType); % delete duplicates 
    TrialType = TrialType(~cellfun('isempty',TrialType)); %delete empty cells
    %% group fields with same name (eg. 'pre_knee_1' and 'pre_knee_2')
    EMG.(subject) = struct;
    for T = 1 : length (TrialType) % loop through the TrialType
        fldN = find(contains(fld,TrialType{T}))';
        EMG.(subject).(TrialType{T}) = struct;
        for F = fldN                % loop through the field containing each TrialType            
            for row = 1: size(selectedTrials.(fld{F}),1)
                % find number of trials already included and add 1
                TrialN = ['T' num2str(size(fields(EMG.(subject).(TrialType{T})),1)+1)];
                % add data
                EMG.(subject).(TrialType{T}).(TrialN).Data = selectedTrials.(fld{F}){row,2};
                % add bad trials
                if size(selectedTrials.(fld{F}),2)<3
                    EMG.(subject).(TrialType{T}).(TrialN).BadTrials = [];
                else
                    EMG.(subject).(TrialType{T}).(TrialN).BadTrials = cell2mat (selectedTrials.(fld{F}){row,3});
                end
            end
        end
    end
end
   