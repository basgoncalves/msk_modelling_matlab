%% Description - Goncalves, BM (2019)
%   fileDir = directory of the c3d file 
%   GaitCycleType:  1 = Foot Strike to Foot strike (default), 2 = Toe off to Toe off


function [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running (fileDir,TestedLeg,GaitCycleType)

fp= filesep;
data = btk_loadc3d(fileDir);
trialName = split(fileDir,filesep);
trialName = trialName{end};
%Combine all the force plates data
dataOutput = combineForcePlates_multiple(data);
data.GRF = dataOutput.GRF;

% get sample frequency  
fs_Analog = data.analog_data.Info.frequency;
fs_Markers = data.marker_data.Info.frequency;
fs_ratio = fs_Analog/fs_Markers;
first_frame = data.marker_data.First_Frame;

if nargin ==1
    TestedLeg =1;
    dips(' Tested leg not specified, right leg used for trial')
end

% Find event frames for the Analog data
if isempty(fieldnames(data.marker_data.Markers))
    sprintf ('%s does not contain any marker data',Files(Trial).name)
    [~,name]=fileparts(which(fileDir));
    RunningEMG.(name)= [];
    EventsFromC3D = 0;
elseif ~isempty(fieldnames(data.Events.Events)) % if the c3d already ah events marked
    Events = data.Events.Events;
    F = fieldnames(data.Events.Events);
    for iF = 1:length(F)
        name = F{iF};
        Events.(name) = round(fs_Markers.*Events.(name))-first_frame+1;  % plus one since vicon always starts at one
        
    end
    
    MarkerEvents= Events;
    [eventsRunning,motionDirection] = findHeelStrike_Running_multiple(data, 'backward',2);
    EventsFromC3D = 1;
    
else
    
    [eventsRunning,motionDirection] = findHeelStrike_Running_multiple(data, 'backward',2);
    %         eventsRunning = Contact_ForcePlate_BG(data, 2);
    MarkerEvents = eventsRunning.markerEvents;
    EventsFromC3D = 0;
end

% remove name of the subject from MarkerEvent names (to make Vicon and Moca
% event names the same)
[~,Subject]= fileparts(fileparts(fileparts((fileDir))));
MarkerEvents = TrimStruct (MarkerEvents,['C' Subject '_']);

FPevents.Right_Foot_Strike= min([eventsRunning.forceplateEvents.Right_Foot_Strike]);
FPevents.Right_Foot_Off= max([eventsRunning.forceplateEvents.Right_Foot_Off]);
FPevents.Left_Foot_Strike= min([eventsRunning.forceplateEvents.Left_Foot_Strike]);
FPevents.Left_Foot_Off= max([eventsRunning.forceplateEvents.Left_Foot_Off]);
% Assign Foot contact and toe off frames

foot_contacts=[];
ToeOff=[];
%% Right leg
if contains(TestedLeg,'R')    
    
    if EventsFromC3D == 1   % if c3d has events
        if isfield(MarkerEvents,'Right_Foot_Strike') &&...
                MarkerEvents.Right_Foot_Strike(1) >1
            foot_contacts = MarkerEvents.Right_Foot_Strike;
        else
            foot_contacts =[];
        end
        
        if isfield(MarkerEvents,'Right_Foot_Off') &&...
                MarkerEvents.Right_Foot_Off(1) >1
            ToeOff = MarkerEvents.Right_Foot_Off;
        else
            ToeOff =[];
        end
    elseif ~isempty(FPevents.Right_Foot_Strike) &&...       %if FP events exist
            ~isempty(FPevents.Right_Foot_Off)
        
        FPcontact = FPevents.Right_Foot_Strike(1);%*fs_ratio;
        [~,closestIndex] = min(abs(MarkerEvents.Right_Foot_Strike-(FPcontact)));
        
        if closestIndex>1
            foot_contacts = [MarkerEvents.Right_Foot_Strike(closestIndex-1) FPcontact];
        elseif length(MarkerEvents.Right_Foot_Strike)>1
            foot_contacts = [FPcontact MarkerEvents.Right_Foot_Strike(closestIndex+1)];
        else
            foot_contacts = FPevents.Right_Foot_Strike;
        end
        if ~isempty(FPevents.Right_Foot_Off)
            ToeOff = FPevents.Right_Foot_Off;%*fs_ratio;
        else
            ToeOff=[];
        end
    end
    if length(MarkerEvents.Right_Foot_Strike) >1
        foot_contacts = MarkerEvents.Right_Foot_Strike(1:2);%*fs_ratio;
        
    end
    
   
elseif contains(TestedLeg,'L')
%% left leg  
    if EventsFromC3D == 1
        if isfield(MarkerEvents,'Left_Foot_Strike') &&...
                 MarkerEvents.Left_Foot_Strike(1) >1 
            foot_contacts = MarkerEvents.Left_Foot_Strike;
        else
            foot_contacts =[];
        end
        
        if isfield(MarkerEvents,'Left_Foot_Off') &&...
                  MarkerEvents.Left_Foot_Off(1) >1
            ToeOff = MarkerEvents.Left_Foot_Off;
        else
            ToeOff =[];
        end
        
    elseif ~isempty(FPevents.Left_Foot_Strike) && ~isempty(FPevents.Left_Foot_Off)
        FPcontact = FPevents.Left_Foot_Strike(1);%*fs_ratio;
        [~,closestIndex] = min(abs(MarkerEvents.Left_Foot_Strike-(FPcontact)));
        
        if closestIndex>1
            foot_contacts = [MarkerEvents.Left_Foot_Strike(closestIndex-1) FPcontact];
        elseif length(MarkerEvents.Left_Foot_Strike)>1
            foot_contacts = [FPcontact MarkerEvents.Left_Foot_Strike(closestIndex+1)];
        else
            foot_contacts = FPevents.Left_Foot_Strike;
        end
        if ~isempty(FPevents.Left_Foot_Off)
            ToeOff = FPevents.Left_Foot_Off;%*fs_ratio;
        else
            ToeOff=[];
        end
    elseif length(MarkerEvents.Left_Foot_Strike) >1
        foot_contacts = MarkerEvents.Left_Foot_Strike(1:2);%*fs_ratio;
        
    end
end

%%
if ~exist('GaitCycleType')
    return
end

if GaitCycleType == 2
    
    
    if length(ToeOff)>1 && length(ToeOff)<3
        ToeOff = [ToeOff(1) ToeOff(2)];
    elseif length(ToeOff)==1 && length(foot_contacts)>1 
        
        Offset = ToeOff - foot_contacts(2);
        TempFootContact = foot_contacts (2);
        ToeOff= (foot_contacts+Offset);
        foot_contacts= (TempFootContact);
        
    elseif length(ToeOff)<1 && length(foot_contacts)<1

        fprintf('not enough events to compute a gait cycle for %s\n',trialName)
    end
    
end

%% define Gait cycles
GaitCycle= struct;
ToeOff = unique(ToeOff); %delete repeats
foot_contacts = unique(foot_contacts); %delete repeats
% create offset so the cycle is from toeoff to toeoff

if length(ToeOff) == 1 && length(foot_contacts) > 1
    
    Offset = ToeOff - foot_contacts(2);
    GaitCycle.ToeOff= (foot_contacts+data.marker_data.First_Frame+Offset);
    GaitCycle.foot_contacts= (ToeOff+data.marker_data.First_Frame-Offset);  
elseif length(ToeOff) == 2  

    GaitCycle.foot_contacts=foot_contacts+data.marker_data.First_Frame;
    GaitCycle.ToeOff=ToeOff+data.marker_data.First_Frame;
elseif length(ToeOff) == 1 && length(foot_contacts) == 1

    GaitCycle.foot_contacts=foot_contacts+data.marker_data.First_Frame;
    GaitCycle.ToeOff=ToeOff+data.marker_data.First_Frame;
    sprintf('Gait cycle only includes stance for: %s', trialName)
else

    GaitCycle.foot_contacts=[];
    GaitCycle.ToeOff=[];
    sprintf('No events found in: %s', trialName)
end

%% Load c3d data
% find the minimal and maximal frame index that contains all markers and use
% those to crop the trial. OPENSIM does not work with NANs created in the
% TRC when the markers are not visible

DirAcq = [fileparts(fileDir) fp 'acquisition.xml'];
acquisitionInfo = xml_read(DirAcq);
MarkersSet=textscan(acquisitionInfo.MarkersProtocol.MarkersSetDynamicTrials, '%s','delimiter', ' ');
MarkersSet=MarkersSet{1};

% get marker info from trials
MarkersLabels={};
MarkersLabels{1}= fields(data.marker_data.Markers);
MarkersList=MarkersSet(:);

% delete unused markers
MarkersList(~contains(MarkersList,MarkersLabels{1,1})) = [];

markers = MarkersList;
initialFrame = 1;

[Nrow, ~]= size(data.marker_data.Markers.(markers{1}));
finalFrame = Nrow;
Threshold = 0.8;

%% find first row with at least 80% markers visible
for FirstRow = 1:Nrow
    emptyRows = 0;
    for m = 1: length (markers)
        if data.marker_data.Markers.(markers{m})(FirstRow,1)==0         %check if row is empty
            emptyRows = emptyRows +1;   
        end
    end  
    if emptyRows < (1- Threshold)*length (markers)
        initialFrame = FirstRow;
        break
    end
end
%% find the last frame based on the position of the sacrum markers (1 metre after the FP) 
Sacr = markers(find(contains(markers,'SACR')));
Threshold = -100;  % a-p position (in mm) to stop the trial
finalFrame = 0;
for m = 1: length (Sacr)
    idx = find(data.marker_data.Markers.(Sacr{m})(:,2)<Threshold);
    
    if idx(1) > finalFrame
        finalFrame = idx(1);
        break
    end
end


%% Calculate time window for openSim
OpenSimOffset = data.marker_data.First_Frame;
initialFrame = initialFrame+3;                     % add and remove 2 frames from the where cropping the trial
finalFrame = finalFrame-3;
time_range = [(initialFrame+OpenSimOffset)/fs_Markers (finalFrame+OpenSimOffset)/fs_Markers];
IK.InverseKinematicsTool.time_range = time_range;

GaitCycle.FirstFrameC3D = data.marker_data.First_Frame;
GaitCycle.FirstFrameOpenSim = time_range(1)*fs_Markers;
GaitCycle.FinalFrameOpenSim = time_range(2)*fs_Markers;

if length(GaitCycle.ToeOff) == 2 &&  length(GaitCycle.foot_contacts) == 1 
    GaitCycle.FCPercent = (GaitCycle.foot_contacts-GaitCycle.ToeOff(1))/(GaitCycle.ToeOff(2)-GaitCycle.ToeOff(1))*100;
    
elseif length(GaitCycle.foot_contacts) == 2 &&  length(GaitCycle.ToeOff) == 1 
    GaitCycle.TOPercent = (GaitCycle.ToeOff-GaitCycle.foot_contacts(1))/(GaitCycle.foot_contacts(2)-GaitCycle.foot_contacts(1))*100;
end
%time in seconds
GaitCycle.TO_time = GaitCycle.ToeOff / fs_Markers;
GaitCycle.FC_time = GaitCycle.foot_contacts / fs_Markers;


