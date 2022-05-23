
% GroupData = group data after running "importExternalBiomech.m"


function [StartingFrame,OutputData] = AdjustMissingGaitCyclePhases(Dir,RunningPhase,Data)


fp = filesep;
load([Dir.Results_RSFAI fp 'ReferenceData.mat'])

if contains(RunningPhase,'Stance')
    
elseif contains(RunningPhase,'Swing')
    
elseif contains(RunningPhase,'PeakHipFlexion')
    
    f = fields(G.angles.hip_flexion);
    cols = 1:47;
    for i = 1:length(f)
        [~,idx(i)] = max(nanmean(G.angles.hip_flexion.(f{i})(:,cols),2));
        
    end
    StartingFrame = round(mean(idx));
else
    OutputData = Data;
    StartingFrame = [];
    return
end

lengthNewData = length(Data)-StartingFrame;
interval = length(Data)/lengthNewData;
Ncols = size(Data,2);
OutputData(1:StartingFrame,1:Ncols)=NaN;
OutputData(StartingFrame+1:length(Data),1:Ncols) = interp1(Data,[1:interval:length(Data)]);


