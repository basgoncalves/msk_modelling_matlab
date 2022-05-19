% Find events of the force plates during running after stitching all the
% force plates together using "combineForcePlates_multiple"
%
% SyncMethod: 1 = interpolation Marker data; 2 = downsalmple force;

function events = findHeelStrike_Running(data, motionDirection,SyncMethod)
%Identify frames in which the heel marker is at the maximum distance from
%the sacrum marker
%   Run through the marker data and identify the peaks in which the heel
%   marker is the furthest distance from the sacrum marker.

% Specify lab coordinate system direction here as they appear in mat file.
% Outputs are always xyz, so for Griffith lab the y-axis points forward and
% z-axis points up.
% X-direction = 1, Y-direction = 2, Z-direction = 3;
progressionDirection = motionDirection;
verticalDirection = 3; % This is normally z-axis in most labs

if nargin < 3
    SyncMethod = 1;
end
% Find the foot marker names
markersNames = fieldnames(data.marker_data.Markers);
HeelMarkers = sort(markersNames(contains(markersNames, 'HEE'))); % Gets the foot markers
toeMarkers = sort(markersNames(contains(markersNames, 'MT') & contains(markersNames, '1'))); % Gets the 5th metatarsal markers
sacralMarkers = sort(markersNames(contains(markersNames, 'SACR')));


% Assign marker names
sacralMarker = sacralMarkers{3};
HeelMarkerR = HeelMarkers{2}; toeMarkerR = toeMarkers{2};
HeelMarkerL = HeelMarkers{1}; toeMarkerL = toeMarkers{1};

% Make sure events correspond with frame correctly.
firstFrame = data.marker_data.First_Frame;

% get sample frequency
fs_Analog = data.analog_data.Info.frequency;
fs_Markers = data.marker_data.Info.frequency;

% Find verical path heel marker 
PathHeelMarkerRz = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerR)(:,3))));
PathHeelMarkerLz = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerL)(:,3))));

% Find sagital path heel marker 
PathHeelMarkerRy = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerR)(:,2))));
PathHeelMarkerLy = smooth(smooth(smooth(data.marker_data.Markers.(HeelMarkerL)(:,2))));

% Find verical path TOE marker 
PathToeMarkerRz = smooth(smooth(smooth(data.marker_data.Markers.(toeMarkerR)(:,3))));
PathToeMarkerLz = smooth(smooth(smooth(data.marker_data.Markers.(toeMarkerL)(:,3))));

% Find sagital path TOE marker 
PathToeMarkerRy = smooth(smooth(smooth(data.marker_data.Markers.(toeMarkerR)(:,2))));
PathToeMarkerLy = smooth(smooth(smooth(data.marker_data.Markers.(toeMarkerL)(:,2))));


GRFz = data.GRF.FP.F(:,3);

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

PathToeMarkerRz = interp1(originalLength,PathToeMarkerRz,InterpPoints)';
PathToeMarkerLz = interp1(originalLength,PathToeMarkerLz,InterpPoints)';
PathToeMarkerRy = interp1(originalLength,PathToeMarkerRy,InterpPoints)';
PathToeMarkerLy = interp1(originalLength,PathToeMarkerLy,InterpPoints)';

elseif SyncMethod ==2

    GRFz = downsample (GRFz,fs_Analog/fs_Markers);
    
end
%% Left heel strikes
[~,LeftPeaks] = findpeaks(-PathHeelMarkerLz,1);
GRF_Binary = zeros(length(GRFz)+50,1);
GRF_Binary(LeftPeaks) = 1;
N_HS = 1;                                               % number of heel strikes                            
for ii = 2:length(GRF_Binary)
    if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1                 % if rising burst =  heel strike
       HSLeft(N_HS)= ii;                                 
       GRF_Binary (ii:ii+50)=0;                         % make the next 50 frames = 0 to eleminate artifacts 
       N_HS = N_HS+1;
    end
end

%% Right heel strikes
[~,RightPeaks] = findpeaks(-PathHeelMarkerRz,1);
[~,RightPeaks] = findpeaks(-PathToeMarkerRz,1);
GRF_Binary = zeros(length(GRFz)+50,1);
GRF_Binary(RightPeaks) = 1;
N_HS = 1;                                               % number of heel strikes                            
for ii = 2:length(GRF_Binary)
    if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1                 % if rising burst =  heel strike
       HSRight(N_HS)= ii;                               
       GRF_Binary (ii:ii+50)=0;                         % make the next 50 frames = 0 to eleminate artifacts 
       N_HS = N_HS+1;
    end
end

%% Heel strike based on forceplate

GRF_Zeros = find(GRFz);
GRF_Binary = zeros((length(GRFz)+50),1);
GRF_Binary(GRF_Zeros) = 1;

for ii = 2:length(GRF_Binary)
    if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1     % if rising burst =  heel strike
       if PathHeelMarkerRy(ii)<PathHeelMarkerLy(ii)       % if Y-position of Heel_R < Heel_L (right leg in front)
          HSRight_2 = ii;
          
       elseif PathHeelMarkerLy(ii)<PathHeelMarkerRy(ii)       % if Y-position of Heel_L < Heel_R (left leg in front)
           HSLeft_2 = ii;
       end
        
    elseif GRF_Binary(ii-1) == 1 && GRF_Binary(ii) == 0     % if falling burst = toe Off
       if PathHeelMarkerRy(ii)>PathHeelMarkerLy(ii)               % if Z-position of Heel_R > Heel_L (left in front)
           TORight = ii;
       elseif PathHeelMarkerLy(ii)>PathHeelMarkerRy(ii)       % if Z-position of Heel_L > Heel_R (right in front)
           TOLeft = ii; 
       end
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
% x= HSRight(2)*5;
% line([x x], [0 max(GRF)]); 


% Make sure events correspond with frame correctly.

% heel strike marker data
if exist('HSRight')==1; events.rightHS = HSRight + firstFrame;  
    else; events.rightHS =[]; end

if exist('HSLeft')==1;events.leftHS = HSLeft + firstFrame;
else; events.leftHS = []; end


% heel strike forceplace
if exist('HSRight_2')==1; events.rightHS_forceplate = HSRight_2 + firstFrame;
else; events.rightHS_forceplate =[]; end     
    
if exist('HSLeft_2')==1; events.leftHS_forceplate = HSLeft_2 + firstFrame;
else; events.leftHS_forceplate =[];end


% toe off forceplace
if exist('TORight')==1; events.rightTO_forceplate = TORight + firstFrame;
else; events.rightTO_forceplate = [];end

if exist('TOLeft')==1; events.leftTO_forceplate = TOLeft + firstFrame;
else; events.leftTO_forceplate =[]; end
