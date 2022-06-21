function plotBOPS(analysis,trialList)
%%
bops         = load_setup_bops;
subject      = load_subject_settings;
SubjectInfo  = subject.subjectInfo;

if ~exist('trialList','var') || isempty(trialList)
    trialList = subject.trials.trialList;
end

if nargin < 1
    analyses = fields(bops.plotresults);
    [indx,~] = listdlg('PromptString','select the analysis to plot','ListString',analyses);                                              % select subjects                                                                                                
    analysis = analyses{indx};
end

if contains(bops.analysis_type.plot, 'manual')
    manualSelectionAnalyses(trialList,bops)
end

saveDir = [bops.directories.Results fp analysis fp SubjectInfo.ID fp bops.current.session];
mkdir(saveDir)
switch analysis
    case 'summary';         plotSummary (trialList,saveDir) 
    case 'emg';             plotEMG (trialList,saveDir) 
    case 'ik';              plotIK (trialList,saveDir)
    case 'id';              plotID (trialList,saveDir)
    case 'rra';             plotRRA (trialList,saveDir)
%     case 'id_postrra';      runBOPS_ID_postrra
%     case 'lucaoptimizer';   runBOPS_LucaOptimizer
%     case 'handsfield';      runBOPS_Handsfield
    case 'ma';              runBOPS_MA
%     case 'ceinms';          runBOPS_CEINMS
    case 'so';              plotSO(trialList,saveDir)
%     case 'jra';             runBOPS_JRA
    otherwise
end


function plotSummary (trialList,saveDir)
%%
bops = load_setup_bops;
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    
    [ik,ik_labels] = LoadResults_BG(trialDirs.IKresults,[],[],0,0);
    
    [id,id_abels] = LoadResults_BG(trialDirs.IDresults,[],[],0,0);
    
end

bops.plot_variables.ik = 'pelvis_tilt pelvis_list pelvis_rotation hip_adduction hip_rotation knee_angle ankle_angle';
xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);


saveas(gcf,[saveDir fp trialName '.jpeg'])

function plotIK (trialList,saveDir)
%%
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    filename = trialDirs.IKresults;
    plotFile(trialName,filename)
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
winopen(saveDir)

function plotID (trialList,saveDir)
%%
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    filename = trialDirs.IDresults;
    plotFile(trialName,filename)
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
winopen(saveDir)

function plotRRA (trialList,saveDir)
%%
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    filename1 = trialDirs.RRAkinematics;
    filename2 = trialDirs.IKresults;
    plotCompare(trialName,filename1,filename2)
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
winopen(saveDir)

function plotMA (trialList,saveDir)
%%
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    filename1 = trialDirs.RRAkinematics;
    filename2 = trialDirs.IKresults;
    plotCompare(trialName,filename1,filename2)
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
winopen(saveDir)

function plotSO (trialList,saveDir)
%%
for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);
    filename = trialDirs.SOforceResults;
    plotFile(trialName,filename)
    saveas(gcf,[saveDir fp trialName '.jpeg'])
    close all
end
winopen(saveDir)

function plotEMG (trialList,saveDir)
%%
bops         = load_setup_bops;
subject      = load_subject_settings;
Dir          = subject.directories;
SubjectInfo  = subject.subjectInfo;
EMGmuscles   = bops.emg.Muscle;
MuscleLabels = bops.emg.MuscleLabels;

MaxEMG = importdata([Dir.dynamicElaborations fp 'maxemg' fp 'maxemg.txt']);

for g = 1:length(trialList)                                                                                         % Plot individual trials
    trialName = [trialList{g}];
    disp(trialName)
    [LinearEnv,Labels] = LoadResults_BG([Dir.dynamicElaborations fp trialName fp 'emg.mot'],[],['time' EMGmuscles],0,0);
    if isempty(LinearEnv)
       continue 
    end
    time = LinearEnv(:,1);    LinearEnv(:,1) = []; Labels(:,1) = [];
    
    load([Dir.sessionData fp trialName fp 'AnalogData.mat']);
    time = time - AnalogData.FirstFrame/AnalogData.Rate*10; % in case the data has been cropped
    time(time<0.001)=[]; % remove any data smaller than 1 frame (1/framerate)
    frames = round([time(1,1)*AnalogData.Rate : time(end,1)*AnalogData.Rate],0);
    [HighPassEMG,~] = findData(AnalogData.RawData(frames,:),AnalogData.Labels,MuscleLabels,1);
    %     HighPassEMG = TimeNorm(HighPassEMG,AnalogData.Rate);
    figure
    [ha, ~] = tight_subplotBG(4,4,0.05,0.05,0.08,[107 76 1728 895]);
    
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
        title([Labels{ii}],'Interpreter','none')
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


[ha, ~] = tight_subplotBG(4,4,0.05,0.05,0.08,[107 76 1728 895]);                                                    % plot the max trial
for ii = 1:size(LinearEnv,2)
    trialName = MaxEMG.textdata{ii+1,3};
    
    load([Dir.sessionData fp trialName fp 'AnalogData.mat']);
    [HighPassEMG,~] = findData(AnalogData.RawData,AnalogData.Labels,MuscleLabels,1);
    
    axes(ha(ii)); hold on
    plot(HighPassEMG(:,ii))
    ylabel('mV')
    title([Labels{ii} '-' trialName],'Interpreter','none')
    ylim([-3 3])
    yticklabels(yticks)
    if ii >12
        xticklabels(xticks./AnalogData.Rate)
        xlabel('time (s)')
    end
end
mmfn_emg
suptitle('max EMG tirals')
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf,[saveDir fp 'MaxEMGTrial.jpeg'])
close all

for m = 1:length(MuscleLabels)                                                                                      % plot EMG per muslce group
    trialList = Trials.MaxEMG;
    n = ceil(sqrt(length(trialList)));
    [ha, ~] = tight_subplotBG(n,n,0.03,0.03,0.03,[107 76 1728 895]);
    for g = 1:length(trialList)
        trialName = [trialList{g}];
        load([Dir.sessionData fp trialName fp 'AnalogData.mat']);
        [HighPassEMG,Label] = findData(AnalogData.RawData,AnalogData.Labels,MuscleLabels{m},1);
        
        axes(ha(g)); hold on
        plot(HighPassEMG)
        ylabel('mV')
        title(trialName,'Interpreter','none')
        ylim([-3 3])
        yticklabels(yticks)
    end
    suptitle(MuscleLabels{m});
    mmfn_emg
    set(gcf, 'InvertHardcopy', 'off');
    saveas(gcf,[saveDir fp MuscleLabels{m} '.jpeg'])
    close all
end

cmdmsg(['plot EMG done for ' SubjectInfo.ID])

function plotFile(trialName,filepath)
%%
[LinearEnv,Labels] = LoadResults_BG(filepath,[],[],0,0);
disp(trialName)
if isempty(LinearEnv); return;  end

Ncoor   = length(Labels);
[ha,~,FirstCol,LastRow,LastCol] = tight_subplotBG(Ncoor,0,0.05,0.05,0.08);

for ii = 1:size(LinearEnv,2)
    axes(ha(ii)); hold on
    plot(LinearEnv(:,ii))
    yaxisnice(5)
    yticklabels(yticks)
    if any(ii==FirstCol)
        ylabel('angle (deg)')
    end
    title([Labels{ii}],'Interpreter','none')
    yticklabels(yticks)
end
suptitle(trialName);

tight_subplot_ticks (ha,LastRow,FirstCol)

mmfn_emg
set(gcf, 'InvertHardcopy', 'off');

function plotCompare(trialName,filename1,filename2)
%%
[LinearEnv1,Labels] = LoadResults_BG(filename1,[],[],0,0);
[LinearEnv2,Labels] = LoadResults_BG(filename2,[],[],0,0);
disp(trialName)
if isempty(LinearEnv); return;  end

Ncoor   = length(Labels);
[ha,~,FirstCol,LastRow,LastCol] = tight_subplotBG(Ncoor,0,0.05,0.05,0.08);

for ii = 1:size(LinearEnv,2)
    axes(ha(ii)); hold on
    plot(LinearEnv1(:,ii))
    plot(LinearEnv2(:,ii))
    yaxisnice(5)
    yticklabels(yticks)
    if any(ii==FirstCol)
        ylabel('angle (deg)')
    end
    title([Labels{ii}],'Interpreter','none')
    yticklabels(yticks)
end
suptitle(trialName);

tight_subplot_ticks (ha,LastRow,FirstCol)

mmfn_emg
set(gcf, 'InvertHardcopy', 'off');

function manualSelectionAnalyses(trialList,bops)
%%

for g = 1:length(trialList)
    trialName = [trialList{g}];
    [trialDirs] = getdirosimfiles_BOPS(trialName);

    
end

 xml_write(bops.directories.bops,bops,'bops',bops.xmlPref);

