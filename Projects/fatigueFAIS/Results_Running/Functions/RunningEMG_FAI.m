%% Description - Goncalves, BM (2019)
%
%Select folder that contains c3d data for all the running trials
%
% CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   emgAnalysis_noplots
%   combineForcePlates_multiple
%   findHeelStrike_Running
%-------------------------------------------------------------------------
%INPUT
%   MaxEMG = row vector used to normalize EMG data. Each columns should
%   correspond to the same muscle in both the Running file and the Max EMG
%   LegTested Right = 1 Left = 2
%   FolderDir =  directry of the folder witht
%-------------------------------------------------------------------------
%OUTPUT
%   RunningEMG = struct with all the Running trials and the labels of the
%   channels
%
%--------------------------------------------------------------------------


%% Start Function
function  [RunningEMG,RunningEvents,RawEMGrunning,TimeNormalizedEMG] = RunningEMG_FAI (DirC3D,MaxEMG,LegTested,FolderDir)

OrganiseFAI;

if nargin<2
    LegTested = 1;
end
if nargin<3
    DirC3D = uigetdir('selectFolder with running c3d files');
end

DirC3D = ([SubjFolder filesep 'run']);
cd (DirC3D);
folderC3D = sprintf('%s\\%s',DirC3D,'*.c3d');
Files = dir(folderC3D);

RawEMGrunning= struct;
RunningEvents= struct;

% create .trc files  (files for OpenSim with the
% for Trial = 1 : length (Files)
%     btk_c3d2trc(Files(Trial).name);
%
% end

for Trial = 1 : length (Files)
    
    cd (DirC3D);
    filename = sprintf ('%s\\%s',Files(Trial).folder,Files(Trial).name);
    data = btk_loadc3d(filename);
    %Combine all the force plates data
    dataOutput = combineForcePlates_multiple(data);
    data.GRF = dataOutput.GRF;
    
    % get sample frequency
    fs_Analog = data.analog_data.Info.frequency;
    fs_Markers = data.marker_data.Info.frequency;
    fs_ratio = fs_Analog/fs_Markers;
    
    
    % Find event frames for the Analog data
    if isempty(fieldnames(data.marker_data.Markers))
        sprintf ('%s does not contain any marker data',Files(Trial).name)
        [~,name]=fileparts(which(filename));
        RunningEMG.(name)= [];
        continue;
    else
        
        [eventsRunning,motionDirection] = findHeelStrike_Running_multiple(dataOutput, 'backward',2);
        %         eventsRunning = Contact_ForcePlate_BG(data, 2);
        FPevents = eventsRunning.forceplateEvents;
        MarkerEvents = eventsRunning.markerEvents;
    end
    
    % Assign Foot contact and toe off frames
    
    foot_contacts=[];
    ToeOff=[];
    if LegTested ==1
        if ~isempty(FPevents.HSRight) && ~isempty(FPevents.TORight)
            FPcontact = FPevents.HSRight(1);%*fs_ratio;
            [~,closestIndex] = min(abs(MarkerEvents.HSRight-(FPcontact)));
            
            if closestIndex>1
                foot_contacts = [MarkerEvents.HSRight(closestIndex-1) FPcontact];
            elseif length(MarkerEvents.HSRight)>1
                foot_contacts = [FPcontact MarkerEvents.HSRight(closestIndex+1)];               
            end
            if ~isempty(FPevents.TORight)
                ToeOff = FPevents.TORight(1);%*fs_ratio;
            else
                ToeOff=[];
            end
            
        elseif length(MarkerEvents.HSRight) >1
            foot_contacts = MarkerEvents.HSRight(1:2);%*fs_ratio;
            
        end
    elseif LegTested ==2
        if ~isempty(FPevents.HSLeft) && ~isempty(FPevents.TOLeft)
            FPcontact = FPevents.HSLeft(1);%*fs_ratio;
            [~,closestIndex] = min(abs(MarkerEvents.HSLeft-(FPcontact)));
            
            if closestIndex>1
                foot_contacts = [MarkerEvents.HSLeft(closestIndex-1) FPcontact];
            elseif length(MarkerEvents.HSLeft)>1
                foot_contacts = [FPcontact MarkerEvents.HSLeft(closestIndex+1)];
            end
            if ~isempty(FPevents.TOLeft)
                ToeOff = FPevents.TOLeft(1);%*fs_ratio;
            else
                ToeOff=[];
            end
        elseif length(MarkerEvents.HSLeft) >1
            foot_contacts = MarkerEvents.HSLeft(1:2);%*fs_ratio;
            
        end
    end
    
%     %% Define gait cycle
%     if ~isempty(ToeOff)
%         Cycle = foot_contacts(2)-foot_contacts(1);  % selected cycle
%         Takeoff = ToeOff-foot_contacts(1);          % Takeoff from force plates
%         PercentTO = Takeoff/Cycle;
%         
%         if PercentTO > 1        % if take off happens after the celected cycle
%             
%         end
%         
%         
%     end
    %% cut EMG data and normalize to max EMG
    
    if length (foot_contacts)<2
        sprintf ('No foot contacts for %s - EMG running',Files(Trial).name)
        continue
    else
        %Get EMG data only
        [filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename);                                  % callback fucntion
%         GRFz = data.GRF.FP.F(:,3);
%         x= foot_contacts(1)*fs_ratio;
%         line([x x], [0 max(GRFz)]);
%         x= foot_contacts(2)*fs_ratio;
%         line([x x], [0 max(GRFz)]);
        channels = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG',...
            'TFL','Gmax','Gmed','PIR','OI','QF','Force'};
        
        Cut_EMG = EMGdata(foot_contacts(1)*fs_ratio:foot_contacts(2)*fs_ratio,:);
        
        % filter settings
        fcolow = 6;
        fcohigh_Surface = 30;
        fcohigh_Intra = 50;
        actualFrames = 1: length(Cut_EMG);
        
        %filter at 30Hz - surface EMG
        [filter_EMG_30,FFT_EMG] = ...
            emgAnalysis_noplots(Cut_EMG, fs_Analog, fcolow, fcohigh_Surface);                   % callback fucntion
        %filter at 50Hz - Intramuscular EMG
        [filter_EMG_50,FFT_EMG] = ...
            emgAnalysis_noplots(Cut_EMG, fs_Analog, fcolow, fcohigh_Intra);                      % callback fucntion
        
        [Nrows,~] = size(filter_EMG_30(:,1:12));
        
        filter_EMG1=[];
        filter_EMG1 (1:Nrows,1:12)=filter_EMG_30(:,1:12);
        filter_EMG1 (1:Nrows,13:17)=filter_EMG_50(:,13:17);
        
        Normalized_EMG=[];
        for ii = 1:16
            [Rows,~] = size(filter_EMG1(:,ii));
            Normalized_EMG (1:Rows,ii) = filter_EMG1(:,ii)./MaxEMG(ii);
        end
        
        RunningEMG.(filename(1:end-4))= Normalized_EMG;
        RunningEvents.(filename(1:end-4)).footContacts = foot_contacts;
        RunningEvents.(filename(1:end-4)).ToeOff = ToeOff;
        RawEMGrunning.(filename(1:end-4))= data;
        sprintf ('%s - EMG running done',Files(Trial).name)
    end
    
end

%% time Normalised EMG
 TimeNormalizedEMG=struct;
if exist('channels')
RunningEMG.channels = channels;
 TrialNames = fields(RunningEvents);
 TimeNormalizedEMG = struct;
Trials =1:length(fields(RunningEvents)); 
for Trial = Trials
    NormalizedEMG = RunningEMG.(TrialNames{Trial});
    TrialNames = fields(RunningEvents);
    if isempty(RunningEMG.(TrialNames{Trial}))==0
        NormalizedEMG = RunningEMG.(TrialNames{Trial});
        ToeOff = RunningEvents.(TrialNames{Trial}).ToeOff-RunningEvents.(TrialNames{Trial}).footContacts(1);
        TimeNormalizedEMG.(TrialNames{Trial})= TimeNorm (NormalizedEMG,fs_Analog);
        
    end
end
   

end
