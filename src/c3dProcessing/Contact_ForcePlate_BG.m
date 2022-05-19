% Find events of the force plates during running after stitching all the
% force plates together using "combineForcePlates_multiple"

function events = Contact_ForcePlate_BG(data, motionDirection)
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

% Find the foot marker names
markersNames = sort(fieldnames(data.marker_data.Markers));
MarkerData = orderfields(data.marker_data.Markers);
DeletedMarkers={};
for ii = 1: length(markersNames)
    currentMarker = MarkerData.(markersNames{1})(:,3);
   if ~isempty (currentMarker(currentMarker==0))
       MarkerData = rmfield(MarkerData,markersNames{1});
       DeletedMarkers{end} = markersNames{1};
   end
end

MarkerData = struct2cell(MarkerData);
HeelMarkerR =  MarkerData(find(contains(markersNames, 'RHEE'))); HeelMarkerR = HeelMarkerR{1};         % Gets the foot markers
HeelMarkerL =  MarkerData(find(contains(markersNames, 'RHEE'))); HeelMarkerL = HeelMarkerL{1};        % Gets the foot markers
toeMarkerR = MarkerData(find(contains(markersNames,'RMT'))); toeMarkerR = toeMarkerR{1};               % Gets the most medial metatarsal markers
toeMarkerL = MarkerData(find(contains(markersNames,'LMT'))); toeMarkerL = toeMarkerL{1};               % Gets the most medial metatarsal markers
sacralMarkerU =  MarkerData(find(contains(markersNames, 'SACR')));sacralMarkerU = sacralMarkerU{3};
TibialMarkers = MarkerData(find(contains(markersNames,'TIB')));

     
% Ground reaction force data
GRFx = data.GRF.FP.F(:,1);   
GRFy = data.GRF.FP.F(:,2);
GRFz = data.GRF.FP.F(:,3);


% Make sure events correspond with frame correctly.
firstFrame = data.marker_data.First_Frame;

% get sample frequency
fs_Analog = data.analog_data.Info.frequency;
fs_Markers = data.marker_data.Info.frequency;
time = 0:1/fs_Analog:length(GRFz)/fs_Analog;
dt = 1/fs_Analog;

%filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);

% Find verical path heel marker 

PathHeelMarkerRz = filtfilt(b,a,HeelMarkerR(:,3));
PathHeelMarkerLz = filtfilt(b,a,HeelMarkerL(:,3));

% Find sagital path heel marker 
PathHeelMarkerRy = filtfilt(b,a,HeelMarkerR(:,2));
PathHeelMarkerLy = filtfilt(b,a,HeelMarkerL(:,2));

% Find verical path TOE marker 
PathToeMarkerRz = filtfilt(b,a,toeMarkerR(:,3));
PathToeMarkerLz = filtfilt(b,a,toeMarkerL(:,3));

% Find sagital path TOE marker 
PathToeMarkerRy = filtfilt(b,a,toeMarkerR(:,2));
PathToeMarkerLy = filtfilt(b,a,toeMarkerL(:,2));





%% interpolate Marker data
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


%% Foot contact based on forceplate

GRF_Zeros = find(GRFz);
GRF_Binary = zeros((length(GRFz)+50),1);
GRF_Binary(GRF_Zeros) = 1;

for ii = 2:length(GRF_Binary)
    if GRF_Binary(ii-1) == 0 && GRF_Binary(ii) == 1     % if rising burst =  heel strike
       if PathHeelMarkerRy(ii)<PathHeelMarkerLy(ii)       % if Y-position of Heel_R < Heel_L (right leg in front)
          HSRight_forceplate = ii;
          
       elseif PathHeelMarkerLy(ii)<PathHeelMarkerRy(ii)       % if Y-position of Heel_L < Heel_R (left leg in front)
           HSLeft_forceplate = ii;
       end
        
    elseif GRF_Binary(ii-1) == 1 && GRF_Binary(ii) == 0     % if falling burst = toe Off
       if PathHeelMarkerRy(ii)>PathHeelMarkerLy(ii)               % if Z-position of Heel_R > Heel_L (left in front)
           TORight_forceplate = ii;
       elseif PathHeelMarkerLy(ii)>PathHeelMarkerRy(ii)       % if Z-position of Heel_L > Heel_R (right in front)
           TOLeft_forceplate = ii; 
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

%% Vertical Position _right foot
figure
yyaxis right 
plot(data.GRF.FP.F(:,end))
ylabel ('Force(N)')
hold on

DispToeRz= PathToeMarkerRz/1000;                     % displacement in m
DispHeelRz= PathHeelMarkerRz/1000; 
yyaxis left
plot (DispToeRz,'b--');  
plot (DispHeelRz,'r--');  

ToeContact = find (DispToeRz<min(DispToeRz)*1.5);
ToeContact_Binary = zeros((length(PathToeMarkerRz)),1);
ToeContact_Binary(ToeContact) = 1;
ContactsToe = find(ToeContact_Binary);
ToeStrike=[];
ToeOffRight=[];
for ii = 2:length(ToeContact_Binary)
    if ToeContact_Binary(ii-1) == 0 && ToeContact_Binary(ii) == 1     % if rising burst =  heel strike       
        ToeStrike(end+1) = ii;                
    elseif ToeContact_Binary(ii-1) == 1 && ToeContact_Binary(ii) == 0     % if falling burst = toe Off       
        ToeOffRight(end+1) = ii;        
    end    
end


HeelContact = find (DispHeelRz<min(DispHeelRz)*1.5);
HeelContact_Binary = zeros((length(PathHeelMarkerRz)),1);
HeelContact_Binary(HeelContact) = 1;
firstContactHeel = find(HeelContact_Binary);
HeelStrike=[];
HeelOff=[];
for ii = 2:length(HeelContact_Binary)
    if HeelContact_Binary(ii-1) == 0 && HeelContact_Binary(ii) == 1     % if rising burst =  heel strike       
        HeelStrike(end+1) = ii;                
    elseif HeelContact_Binary(ii-1) == 1 && HeelContact_Binary(ii) == 0     % if falling burst = toe Off       
        HeelOff(end+1) = ii;        
    end    
end

groundContactRight = min([ToeStrike HeelStrike]);

yyaxis left
%plot 
for ii = 1:length (ToeStrike)
groundContactRight(ii) = min([ToeStrike(ii) HeelStrike(ii)]);
plot (groundContactRight,0,'r.','MarkerSize',20)
end


%plot toe off
for ii = 1:length (ToeOffRight)
plot (ToeOffRight,0,'b.','MarkerSize',20)
end

legend('ToeRz','HeelRz','GroundContact','GroundContact','ToeOff','ToeOff','Force')
ylabel ('displacement (m)')
title('vertical position threshold-Right leg')

%% Vertical Position _Left foot
figure
yyaxis right 
plot(data.GRF.FP.F(:,end))
ylabel ('Force(N)')
hold on

DispToeLz= PathToeMarkerLz/1000;                     % displacement in m
DispHeelLz= PathHeelMarkerLz/1000; 
yyaxis left
plot (DispToeLz,'b--');  
plot (DispHeelLz,'r--');  

ToeContact = find (DispToeLz<min(DispToeLz)*1.6);
ToeContact_Binary = zeros((length(PathToeMarkerRz)),1);
ToeContact_Binary(ToeContact) = 1;
ContactsToe = find(ToeContact_Binary);
ToeStrike=[];
ToeOffLeft=[];
for ii = 2:length(ToeContact_Binary)
    if ToeContact_Binary(ii-1) == 0 && ToeContact_Binary(ii) == 1     % if rising burst =  heel strike       
        ToeStrike(end+1) = ii;                
    elseif ToeContact_Binary(ii-1) == 1 && ToeContact_Binary(ii) == 0     % if falling burst = toe Off       
        ToeOffLeft(end+1) = ii;        
    end    
end


HeelContact = find (DispHeelLz<min(DispHeelLz)*1.6);
HeelContact_Binary = zeros((length(PathHeelMarkerRz)),1);
HeelContact_Binary(HeelContact) = 1;
firstContactHeel = find(HeelContact_Binary);
HeelStrike=[];
HeelOff=[];
for ii = 2:length(HeelContact_Binary)
    if HeelContact_Binary(ii-1) == 0 && HeelContact_Binary(ii) == 1     % if rising burst =  heel strike       
        HeelStrike(end+1) = ii;                
    elseif HeelContact_Binary(ii-1) == 1 && HeelContact_Binary(ii) == 0     % if falling burst = toe Off       
        HeelOff(end+1) = ii;        
    end    
end

groundContactLeft = min([ToeStrike HeelStrike]);

yyaxis left
%plot 
for ii = 1:length (ToeStrike)
groundContactLeft(ii) = min([ToeStrike(ii) HeelStrike(ii)]);
plot (groundContactLeft,0,'r.','MarkerSize',20)
end


%plot toe off
for ii = 1:length (ToeOffLeft)
plot (ToeOffLeft,0,'b.','MarkerSize',20)
end

legend('ToeRz','HeelRz','GroundContact','GroundContact','ToeOff','ToeOff','Force')
ylabel ('displacement (m)')
title('vertical position threshold-Left leg')



%% Make sure events correspond with frame correctly.
events=struct;
if exist('groundContactRight')==1; events.rightHS = groundContactRight;  
    else; events.rightHS =[]; end

if exist('groundContactLeft')==1;events.leftHS = groundContactLeft;
else; events.leftHS = []; end

if exist('ToeOffRight')==1; events.TORight = ToeOffRight;  
    else; events.rightHS =[]; end

if exist('ToeOffLeft')==1;events.TOLeft = ToeOffLeft;
else; events.leftHS = []; end



if exist('TORight_forceplate')==1; events.TORight_forceplate = TORight_forceplate;
else; events.TORight_forceplate = [];end

if exist('TORight_forceplate')==1; events.TOLeft_forceplate = TOLeft_forceplate;
else; events.TOLeft_forceplate =[]; end

if exist('HSRight_forceplate')==1; events.HSRight_forceplate = HSRight_forceplate;
else; events.HSRight_forceplate =[]; end     
    
if exist('HSLeft_forceplate')==1; events.HSLeft_forceplate = HSLeft_forceplate;
else; events.HSLeft_forceplate =[];end

