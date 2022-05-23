%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% 
% inspect the force and EMG from the isometric trials from the c3d files

function InspectEMG_Walking(Subjects)

fp = filesep;
[SubjectFoldersInputData,~] = smfai(Subjects);
for ff = 3:length(SubjectFoldersInputData)
    
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersInputData{ff});
    saveDir = [Dir.Results fp 'WalkingEMG' fp SubjectInfo.ID];
    mkdir(saveDir)
    
    if isempty(Trials.Walking); continue; end
    updateLogAnalysis(Dir,'Inspect EMG ',SubjectInfo,'start')

    EMGmuscles = {'        VM','        VL','        RF','       GRA',...
        '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
        '        GL','       TFL','   GLUTMAX' '   GLUTMED' '      PIRI'...
        '    OBTINT'  '        QF'}; % 
    
    MuscleLabels = {'Voltage.1-VM','Voltage.2-VL','Voltage.3-RF',...
        'Voltage.4-GRA','Voltage.5-TA','Voltage.6-AL','Voltage.7-ST',...
        'Voltage.8-BF','Voltage.9-MG','Voltage.10-LG','Voltage.11-TFL',...
        'Voltage.12-Gmax','Voltage.13-Gmed-intra','Voltage.14-PIR-intra',...
        'Voltage.15-OI-intra','Voltage.16-QF-intra'};
    MaxEMG = importdata([Dir.dynamicElaborations fp 'maxemg' fp 'maxemg.txt']);
%% Plot individual trials

TrialsToPlot = Trials.Walking(contains(Trials.Walking,Trials.ID));
for g = 1:length(TrialsToPlot)
    trialName = [TrialsToPlot{g}];
    [LinearEnv,Labels] = LoadResults_BG ([Dir.dynamicElaborations fp trialName fp 'emg.mot'],...
        [],['time' EMGmuscles],0,0);
    time = LinearEnv(:,1);    LinearEnv(:,1) = []; Labels(:,1) = [];
    
    load([Dir.sessionData fp trialName fp 'AnalogData.mat']);
    time = time - AnalogData.FirstFrame/AnalogData.Rate*10; % in case the data has been cropped
    time(time<0.001)=[]; % remove any data smaller than 1 frame (1/framerate)
    frames = round([time(1,1)*AnalogData.Rate : time(end,1)*AnalogData.Rate],0);
    [HighPassEMG,~] = findData(AnalogData.RawData(frames,:),AnalogData.Labels,MuscleLabels,1);
%     HighPassEMG = TimeNorm(HighPassEMG,AnalogData.Rate);
    [ha, pos] = tight_subplotBG(4,4,0.05,0.05,0.08,[107 76 1728 895]);

    for ii = 1:size(LinearEnv,2)
        axes(ha(ii)); hold on
        yyaxis left
        plot(LinearEnv(:,ii))
        ylim([0 1])
        yticklabels(yticks)
        ylabel('% max')
        yyaxis right
        plot(HighPassEMG(:,ii))
        ylabel('mV')
        maxtrial = MaxEMG.textdata{ii+1,3};
        title([Labels{ii} ' Normalised to ' maxtrial],'Interpreter','none')
        ylim([-3 3])
        yticklabels(yticks)
        if ii >12
            xticklabels(xticks./AnalogData.Rate)
            xlabel('time (s)')
        end
    end
    suptitle(trialName);
    lg = legend({'normalised linear envelope' 'high pass filtered'});
    mmfn_emg
    lg.Position = [0.2115    0.9260    0.0972    0.0341]; lg.FontSize = 12;
    set(gcf, 'InvertHardcopy', 'off');
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
updateLogAnalysis(Dir,'Inspect EMG walking',SubjectInfo,'end')
cmdmsg(['Inspect EMG done for ' SubjectInfo.ID])


end