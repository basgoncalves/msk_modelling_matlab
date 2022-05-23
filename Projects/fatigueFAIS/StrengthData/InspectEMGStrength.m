%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% 
% inspect the force and EMG from the isometric trials from the c3d files

function InspectEMGStrength(Subjects)

fp = filesep;
[SubjectFoldersInputData,~] = smfai(Subjects);

for ff = 1:length(SubjectFoldersInputData)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{ff});
    saveDir = [Dir.Results fp 'HipIsometric' fp 'indivudalTrials_EMG' fp SubjectInfo.ID];
    mkdir(saveDir)
    
    if isempty(Trials.Isometrics_pre) || isempty(Trials.Isometrics_post) || isempty(fields(SubjectInfo))
       continue 
    end
    updateLogAnalysis(Dir,'Inspect EMG Isometrics',SubjectInfo,'start')

   
    MuscleLabels = {'Voltage.1-VM','Voltage.2-VL','Voltage.3-RF',...
        'Voltage.4-GRA','Voltage.5-TA','Voltage.6-AL','Voltage.7-ST',...
        'Voltage.8-BF','Voltage.9-MG','Voltage.10-LG','Voltage.11-TFL',...
        'Voltage.12-Gmax','Voltage.13-Gmed-intra','Voltage.14-PIR-intra',...
        'Voltage.15-OI-intra','Voltage.16-QF-intra'};
    
%% pre data    
    [trialType,trialNumber,groups] = getTrialType_multiple(Trials.Isometrics_pre);
    for i = unique(groups)'
        figure
        [ha, pos] = tight_subplot(4,4,0.05,0.05,0.08);
        set(gcf, 'Position', [107 76 1728 895]);
        idx = find(groups == i)';
        for g = idx
            load([Dir.sessionData fp Trials.Isometrics_pre{g} fp 'AnalogData.mat']);
            [results,Labels] = findData(AnalogData.RawData,AnalogData.Labels,MuscleLabels,1);
            for ii = 1:size(results,2)
                axes(ha(ii)); hold on
                plot(results(:,ii))
                title(Labels{ii})
                ylim([-3 3])
                yticklabels(yticks)
                mmfn_emg
            end
        end
        suptitle(trialType{idx(1)})
        set(gcf, 'InvertHardcopy', 'off');
        saveas(gcf,[saveDir fp trialType{idx(1)} '_Pre.jpeg'])
        close all
    end
%% post data    
    [trialType,trialNumber,groups] = getTrialType_multiple(Trials.Isometrics_post);
    for i = unique(groups)'
        figure
        [ha, pos] = tight_subplot(4,4,0.05,0.05,0.08);
        set(gcf, 'Position', [107 76 1728 895]);
        idx = find(groups == i)';
        for g = idx
            load([Dir.sessionData fp Trials.Isometrics_post{g} fp 'AnalogData.mat']);
            [results,Labels] = findData(AnalogData.RawData,AnalogData.Labels,MuscleLabels,1);
            for ii = 1:size(results,2)
                axes(ha(ii)); hold on
                plot(results(:,ii))
                title(Labels{ii})
                yticklabels(yticks)
                ylim([-3 3])
                mmfn_inspect
            end
        end
        suptitle(trialType{idx(1)})
        set(gcf, 'InvertHardcopy', 'off');
        saveas(gcf,[saveDir fp trialType{idx(1)} '_Post.jpeg'])
        close all
    end
    
    
    updateLogAnalysis(Dir,'Inspect EMG Isometrics',SubjectInfo,'end')

end