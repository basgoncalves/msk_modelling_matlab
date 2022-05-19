function events = findHeelStrike(data, motionDirection)
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
markersNames = fieldnames(data.marker_data.Markers);
footMarkers = sort(markersNames(contains(markersNames, 'HEE'))); % Gets the foot markers
toeMarkers = sort(markersNames(contains(markersNames, 'MT') & contains(markersNames, '5'))); % Gets the 5th metatarsal markers
sacralMarkers = sort(markersNames(contains(markersNames, 'PSI')));

% Assign marker names
sacralMarker = sacralMarkers{2};
footMarkerR = footMarkers{2}; toeMarkerR = toeMarkers{2};
footMarkerL = footMarkers{1}; toeMarkerL = toeMarkers{1};

% Make sure events correspond with frame correctly.
firstFrame = data.marker_data.First_Frame;

% Find horizontal distance between heel marker and sacrum
maxDistanceR = (data.marker_data.Markers.(footMarkerR) - data.marker_data.Markers.(sacralMarker));
maxDistanceL = (data.marker_data.Markers.(footMarkerL) - data.marker_data.Markers.(sacralMarker));

% Find horizontal distance between toe marker and sacrum
toeOffR = data.marker_data.Markers.(sacralMarker) - data.marker_data.Markers.(toeMarkerR);
toeOffL = data.marker_data.Markers.(sacralMarker) - data.marker_data.Markers.(toeMarkerL);

% Find range of heel marker in vertical direction and value corresponding
% to 30% of this range
rangeHeelHeightRight = range(data.marker_data.Markers.(footMarkerR)(:,verticalDirection));
rangeHeelHeightLeft = range(data.marker_data.Markers.(footMarkerL)(:,verticalDirection));

% Right foot
thirtyPercentRight = 0.3 * rangeHeelHeightRight;
framesBelowThirtyRight = data.marker_data.Markers.RHEE(:,verticalDirection) < thirtyPercentRight;

% Left foot
thirtyPercentLeft = 0.3 * rangeHeelHeightLeft;
framesBelowThirtyLeft = data.marker_data.Markers.LHEE(:,verticalDirection) < thirtyPercentLeft;

% Use the findpeaks function to determine when the heel marker is furthest
% from the sacrum marker. Specify the minimum distance between peaks so the
% function does not compute multiple peaks close to eachother. Can also
% specify a minimum peak height.

[pks1, HSRight] = findpeaks(maxDistanceR(:,progressionDirection), 'MinPeakDistance', 50);
[pks1, HSLeft] = findpeaks(maxDistanceL(:,progressionDirection), 'MinPeakDistance', 50);

[pks1, TORight] = findpeaks(toeOffR(:,progressionDirection), 'MinPeakDistance', 50);
[pks1, TOLeft] = findpeaks(toeOffL(:,progressionDirection), 'MinPeakDistance', 50);

% The heel strike event should only occur when foot is lower than 30% of the range of heel height during the trial
bad_HS_right = framesBelowThirtyRight(HSRight) < 1;
bad_HS_left = framesBelowThirtyLeft(HSLeft) < 1;

% Check if any heel strikes have an error and display them
if any(bad_HS_right)
	
	% Get index of bad HS
	indexBadHS = HSRight(bad_HS_right) + firstFrame;
	sprintf('An incorrect right heel strike has been detected at frame: %d\n', indexBadHS)
	
	% Pause for 10 seconds to write these frames down
	pause(10);
	
elseif any(bad_HS_left)
	
	% Get index of bad HS
	indexBadHS = HSLeft(bad_HS_left) + firstFrame;
	sprintf('An incorrect left heel strike has been detected at frame: %d\n', indexBadHS)
	
	% Pause for 10 seconds to write these frames down
	pause(10);
	
end

% Make sure events correspond with frame correctly.
events.rightHS = HSRight + firstFrame + 2; % Added 2 frames because we're usually about 2 frames off force plate data with this method
events.rightTO = TORight + firstFrame + 2;
events.leftHS = HSLeft + firstFrame + 2;
events.leftTO = TOLeft + firstFrame + 2;

end

