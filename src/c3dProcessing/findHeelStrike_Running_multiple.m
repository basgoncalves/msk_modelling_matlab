% Find events of the force plates during running
%
% SyncMethod: 1 = interpolation Marker data; 2 = downsalmple force;

function [events,motionDirection] = findHeelStrike_Running_multiple(data, motionDirection,SyncMethod)
%Identify frames in which the heel marker is at the maximum distance from
%the sacrum marker
%   Run through the marker data and identify the peaks in which the heel
%   marker is the furthest distance from the sacrum marker.

% Specify lab coordinate system direction here as they appear in mat file.
% Outputs are always xyz, so for Griffith lab the y-axis points forward and
% z-axis points up.
% X-direction = 1, Y-direction = 2, Z-direction = 3;
% progressionDirection = motionDirection;
verticalDirection = 3; % This is normally z-axis in most labs
APdirection = 2; % This is normally z-axis in most labs

if nargin < 3
    SyncMethod = 1; %1 = interpolation Marker data; 2 = downsalmple force;
end
% Find the foot marker names
markersNames = fieldnames(data.marker_data.Markers);
HeelMarkerR = char(sort(markersNames(contains(markersNames, 'RHEE')))); % Gets the foot markers
HeelMarkerL = char(sort(markersNames(contains(markersNames, 'LHEE')))); % Gets the foot markers
ThighMarkerL = char(sort(markersNames(contains(markersNames, 'LTHI')))); % Gets the LeftThigh markers
ThighMarkerR = char(sort(markersNames(contains(markersNames, 'RTHI')))); % Gets the LeftThigh markers

ToeMarkerR = char(sort(markersNames(contains(markersNames, 'RMT')))); % Gets the 5th metatarsal markers
ToeMarkerL = char(sort(markersNames(contains(markersNames, 'LMT')))); % Gets the 5th metatarsal markers

% sacralMarkers = sort(markersNames(contains(markersNames, 'SACR')));

% Make sure events correspond with frame correctly.
firstFrame = data.marker_data.First_Frame;

% get sample frequency
fs_Analog = data.analog_data.Info.frequency;
fs_Markers = data.marker_data.Info.frequency;
% if heel markes do not exist, just use the foot markers to check plates

if isempty(HeelMarkerR)
    HeelMarkerR = char(sort(markersNames(contains(markersNames, 'RMT'))));
    HeelMarkerR = HeelMarkerR(1,:);
    warning('right heel was not found extist')
end

if isempty(HeelMarkerL)
    HeelMarkerL = char(sort(markersNames(contains(markersNames, 'LMT'))));
    HeelMarkerL = HeelMarkerL(1,:);
    warning('left heel was not found extist. Toes used intead')
end

% Find verical and AP path heel marker
PathHeelMarkerRz = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerR)(:,verticalDirection))));
PathHeelMarkerRy = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerR)(:,APdirection))));
PathThighMarkerRz = smooth(smooth(smooth(data.marker_data.Markers.(ThighMarkerR(2,:))(:,verticalDirection))));
PathThighMarkerRy = smooth(smooth(smooth(data.marker_data.Markers.(ThighMarkerR(2,:))(:,APdirection))));
PathToeMarkerRz = smooth(smooth(smooth(data.marker_data.Markers.(ToeMarkerR(1,:))(:,verticalDirection))));
PathToeMarkerRy = smooth(smooth(smooth(data.marker_data.Markers.(ToeMarkerR(1,:))(:,APdirection))));


PathHeelMarkerLz = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerL)(:,verticalDirection))));
PathHeelMarkerLy = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerL)(:,APdirection))));
PathThighMarkerLz = smooth(smooth(smooth(data.marker_data.Markers.(ThighMarkerL(2,:))(:,verticalDirection))));
PathThighMarkerLy = smooth(smooth(smooth(data.marker_data.Markers.(ThighMarkerL(2,:))(:,APdirection))));
PathToeMarkerLz = smooth(smooth(smooth(data.marker_data.Markers.(ToeMarkerR(1,:))(:,verticalDirection))));
PathToeMarkerLy = smooth(smooth(smooth(data.marker_data.Markers.(ToeMarkerR(1,:))(:,APdirection))));


Nforceplates = length(data.fp_data.GRF_data);

for p = 1: Nforceplates
    
    GRFz(:,p) = data.fp_data.GRF_data(p).F(:,3);
end
%% Sync force and marker data

if SyncMethod ==1
    % interpolate Marker data
    originalData = PathHeelMarkerRy;
    finaData = GRFz;
    InterpRatio = length(originalData)/length(finaData);
    originalLength = (InterpRatio:length(originalData))';
    InterpPoints =  InterpRatio:InterpRatio:length(originalData);
    
    PathHeelMarkerRz = interp1(originalLength,PathHeelMarkerRz,InterpPoints)';
    PathHeelMarkerLz = interp1(originalLength,PathHeelMarkerLz,InterpPoints)';
    PathHeelMarkerRy = interp1(originalLength,PathHeelMarkerRy,InterpPoints)';
    PathHeelMarkerLy = interp1(originalLength,PathHeelMarkerLy,InterpPoints)';
    
elseif SyncMethod ==2
    
    GRFz = downsample (GRFz,fs_Analog/fs_Markers);
    
end

% check motion direction

if PathHeelMarkerLy(1) < PathHeelMarkerLy(end)
    motionDirection = 'forward';
elseif    PathHeelMarkerLy(1) >PathHeelMarkerLy(end)
    motionDirection = 'backward';
end

%% Left heel strikes
if ~isempty(HeelMarkerL)
    [~,LeftPeaks] = findpeaks(-PathHeelMarkerLz,1);
    GRF_Binary = zeros(length(GRFz)+50,1);
    GRF_Binary(LeftPeaks) = 1;
    N_S = 1;
    markerEvents= struct;% number of heel strikes
    
    for ii = 2:length(GRF_Binary)
        if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1                 % if rising burst =  heel strike
            markerEvents.Left_Foot_Strike(N_S)= ii;
            GRF_Binary (ii:ii+50)=0;                         % make the next 50 frames = 0 to eleminate artifacts
            N_S = N_S+1;
        end
    end
end
if ~isfield (markerEvents, 'Left_Foot_Strike')
    markerEvents.Left_Foot_Strike=[];
end

%% Right heel strikes
if ~isempty(HeelMarkerR)
    [~,RightPeaks] = findpeaks(-PathHeelMarkerRz,1);
    
    GRF_Binary = zeros(length(GRFz)+50,1);
    GRF_Binary(RightPeaks) = 1;
    N_S = 1;                                               % number of heel strikes
    for ii = 2:length(GRF_Binary)
        if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1                 % if rising burst =  heel strike
            markerEvents.Right_Foot_Strike(N_S)= ii;
            GRF_Binary (ii:ii+50)=0;                         % make the next 50 frames = 0 to eleminate artifacts
            N_S = N_S+1;
        end
    end
end
if ~isfield (markerEvents, 'Right_Foot_Strike')
    markerEvents.Right_Foot_Strike=[];
end

%% Heel strike based on forceplate
forceplateEvents= struct;
forceplateEvents(1).Right_Foot_Strike = [];
forceplateEvents(1).Right_Foot_Off = [];
forceplateEvents(1).Left_Foot_Strike = [];
forceplateEvents(1).Left_Foot_Off = [];
StrikeOrder = {'None'};
FootOffOrder = {'None'};


for p = 1: Nforceplates
    
    
    GRF_Zeros = find(GRFz(:,p));                     % 
    
    GRF_Binary = zeros((length(GRFz(:,p))+50),1);
    GRF_Binary(GRF_Zeros) = 1;
    
    
    if ~isempty (GRF_Zeros) && length(find(GRF_Binary))>2
        
        if mean(PathHeelMarkerRy(find(GRF_Binary)))==0          % if marker data
            OldPath = PathHeelMarkerRy;
            PathHeelMarkerRy = PathToeMarkerRy;
            PathToeMarkerRy = OldPath;
        end
        
        if mean(PathHeelMarkerLy(find(GRF_Binary)))==0          % if marker data
            OldPath = PathHeelMarkerLy;
            PathHeelMarkerLy = PathToeMarkerLy;
            PathToeMarkerLy = OldPath;
        end
        
        % calculate horizontal velocity of marker 
        velocity_R = abs(mean(calcVelocity (PathHeelMarkerRy(find(GRF_Binary)),fs_Markers)));
        velocity_L = abs(mean(calcVelocity (PathHeelMarkerLy(find(GRF_Binary)),fs_Markers)));
        
        if velocity_R > velocity_L                                                          %if right foot is moving faster
            contact = find(GRF_Binary);
        forceplateEvents(p).Left_Foot_Strike = contact(1);
        forceplateEvents(p).Left_Foot_Off = contact(end);
        elseif velocity_R < velocity_L                                                      %if left foot is moving faster
            contact = find(GRF_Binary);
        forceplateEvents(p).Right_Foot_Strike = contact(1);
        forceplateEvents(p).Right_Foot_Off = contact(end);
        end
        
    else
        forceplateEvents(p).Right_Foot_Strike = [];       %only need one empty cell to create empty column
    end
    
end

% figure
% plot(GRF)
% hold on
% plot(PathfootMarkerL)
% plot(PathfootMarkerR)
% legend ('Force','LeftMarker','RightMarker')
%
% figure
% plot (data.GRF.FP(1).F(:,3))
% hold on
% plot (data.GRF.FP(1).F(:,3))
% y = interp(PathfootMarkerR,5);
% plot(y);
%
% x= Right_Foot_Strike(2)*5;
% line([x x], [0 max(GRF)]);


% Make sure events correspond with frame correctly.

events. markerEvents = markerEvents;
events.forceplateEvents = forceplateEvents;
