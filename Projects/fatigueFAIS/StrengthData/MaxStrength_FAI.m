%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%   PlotFig = Logical (1 = Plot figures: 0 = Do not plot figures)
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------
function MaxTrials = MaxStrength_FAI (strengthDir,SelectedTrials,saveDir,PlotFig)

if nargin ==0
%get the names and directories of the c3d files
strengthDir = uigetdir('',...
    'Select strength folder with .c3d files');
end

cd(saveDir);

folderC3D = sprintf('%s\\%s',strengthDir,'*.c3d');
Files = dir(folderC3D);
MaxTrials ={};
% 
% LoadBar = waitbar(0,'Please wait...');

for Trial = 1 : length (Files)
    
    
%     waitbar(Trial/length (Files),LoadBar,'Please wait...');
    TrialName = strrep(Files(Trial).name,'.c3d','');% name without '.c3d'
    
    if ~contains(TrialName,SelectedTrials)
        continue
    end
    
    dataDir = sprintf ('%s\\%s',Files(Trial).folder,Files(Trial).name);
    data = btk_loadc3d(dataDir);
    Labels = fields(data.analog_data.Channels);
    idForce = [];
    % get the index of Rig and Biodex
    for idx = 1: length (Labels)                                            % loop thorugh the labels of the mat file
        if contains (Labels{idx},'Rig')                                   % find the name "Force"
            idForce = idx;
            break
        elseif contains (Labels{idx},'Torque')                                   % find the name "Force"
            idForce = idx;
            break
        end
    end
    
    if isempty(idForce)
        uiwait(msgbox('No force Channel'));
        return
    end
    % get the force data
    AnalogForce = data.analog_data.Channels.(Labels{idx});
    fs = data.analog_data.Info.frequency;
    [ForceData,MaxForce,baselineForce,peakForce,idxPeak] = ...
        GetMaxForce (AnalogForce,fs);
     
    %% plot force data
    
    if PlotFig == 1
        figure
        plot(ForceData)
        title (TrialName,'Interpreter','None')
        ylabel ('Force (N)')
        
        % position of the max force
        hold on
        plot(idxPeak,ForceData(idxPeak),'r.','MarkerSize', 20);
        mmfn
        lg = legend ('force (N)', 'Max Force (0.5 sec window)');
        set (lg,'color','none','Location','best');
        saveas(gcf, sprintf('%s.tif',TrialName))
        close
    end
    %%
    
    col = size(MaxTrials,2)+1;
    % First row, column i = Name of the trial
    MaxTrials{1,col} = Files(Trial).name(1:end-4);                        % name without '.c3d'
    
    % Max force for each muscle / trial
    MaxTrials{2,col}= peakForce;
    
    % Min force for each muscle / trial
    MaxTrials{3,col}= min(ForceData);
    
     % baseline Force for each muscle / trial
    MaxTrials{4,col}= baselineForce;
    
%     save ((TrialName), 'ForceData','peakForce','baselineForce', 'MaxForce')
    
    sprintf('%s out of %s completed ',Trial, length (Files));
end


close all