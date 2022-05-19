% Determine motion direction based on the initial and final position of
% markers
% c3dFilePathAndName = full file path of the c3d file
% AlgorithmMarkers =  {RH, RTHI, RMT, LH, LTHI, LMT}
% RH = right heel
% RTHI = right thigh
% R5MT = right 5th metatarsal
%
% CoordinateSystemOrientation = [123] The coordinate system orientation refers to the global or laboratory coordinate system. We used the following convention:
% 1st axis: direction of motion
% 2nd axis: vertical axis
% 3rd axis: right hand rule
% see C3D2MAT

function motionDirection = determineMotionDirection(c3dFilePathAndName, detectMarkers)

if nargin < 2
    detectMarkers = {'RHEE' 'R5MT' 'LHEE' 'L5MT'};
elseif isequal(class(detectMarkers),'char')
    detectMarkers = split(detectMarkers,' ')';
    
end

APdirection         = 1;                                                                                            % coordinate system normally y-axis in most labs

data = btk_loadc3d(c3dFilePathAndName);
markersNames = fields(data.marker_data.Markers);
markersPresent = sort(markersNames(contains(markersNames,detectMarkers)));                                          % Gets right side markers

coordinates = smooth(smooth(smooth(data.marker_data.Markers.(markersPresent{1})(:,APdirection))));                  % Find coordinates in the AP direction

if      coordinates(1) < coordinates(end)                                                                           % check motion direction
    motionDirection = 'forward';
elseif  coordinates(1) >coordinates(end)
    motionDirection = 'backward';
end
