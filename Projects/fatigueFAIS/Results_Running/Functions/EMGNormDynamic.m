



function [IsmEMG,NormEMG,maxTrial] = EMGNormDynamic(DirElaborated, Isometrics_pre,DynamicTrials)
fp = filesep;

IsmEMG=[];
Muscles = {'Voltage.1-VM','Voltage.2-VL','Voltage.3-RF',...
    'Voltage.4-GRA','Voltage.5-TA','Voltage.6-AL',...
    'Voltage.7-ST','Voltage.8-BF','Voltage.9-MG','Voltage.10-LG',...
    'Voltage.11-TFL','Voltage.12-Gmax'};

SessionDataDir = [DirElaborated fp 'SessionData'];
for k = 1:length(Muscles)
    
    for i = 1: length(Isometrics_pre)
        
        load([SessionDataDir fp Isometrics_pre{i} fp 'AnalogData.mat'])
        [SelectedData,SelectedLabels,IDxData] = findData...
            (AnalogData.RawData,AnalogData.Labels,Muscles{k},1);
        
        IsmEMG(:,i) = max(movmean(SelectedData,AnalogData.Rate/10));
    end
    [~,ii] =max(IsmEMG);
    maxTrial = Isometrics_pre{ii};
    
    NormEMG=[];
    for i = 1: length(DynamicTrials)
        
        load([SessionDataDir fp DynamicTrials{i} fp 'AnalogData.mat'])
        [SelectedData,SelectedLabels,IDxData] = findData...
            (AnalogData.RawData,AnalogData.Labels,Muscles{k},1);
        
        NormEMG(:,i) = max(movmean(SelectedData,AnalogData.Rate/10))/max(IsmEMG);
    end
    
    figure
    bar(NormEMG)
    xticklabels(DynamicTrials)
    xtickangle(45)
    ylabel(['EMG (%' maxTrial ')'])
    mmfn
    set(gca,'Position',[0.25 0.2 0.65 0.65])
    title(Muscles{k})
end