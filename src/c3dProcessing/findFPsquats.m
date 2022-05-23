

%the sacrum marker
%   Run through the marker data and identify the peaks in which the heel
%   marker is the furthest distance from the sacrum marker.

% Specify lab coordinate system direction here as they appear in mat file.
% Outputs are always xyz, so for Griffith lab the y-axis points forward and
% z-axis points up.
% X-direction = 1, Y-direction = 2, Z-direction = 3;
% progressionDirection = motionDirection;
function findFPsquats

verticalDirection = 3; % This is normally z-axis in most labs
APdirection = 2; % This is normally z-axis in most labs

if nargin < 3
    SyncMethod = 1; %1 = interpolation Marker data; 2 = downsalmple force;
end
% Find the foot marker names
markersNames = fieldnames(data.marker_data.Markers);
leftFoot = {'LHEE','LMT'};
leftFoot = char(sort(markersNames(contains(markersNames, leftFoot))));

rightFoot = {'RHEE','RMT'};
rightFoot = char(sort(markersNames(contains(markersNames, rightFoot))));

% Make sure events correspond with frame correctly.
firstFrame = data.marker_data.First_Frame;
% get sample frequency
fs_Analog = data.analog_data.Info.frequency;
fs_Markers = data.marker_data.Info.frequency;

% Find verical and AP path heel marker
verticalDirection = 3; % This is normally z-axis in most labs
APdirection = 2; % This is normally z-axis in most labs

Pos = struct;
Pos.Rz=[];Pos.Ry =[];Pos.Lz=[];Pos.Ly =[];
for ii = 1:size(leftFoot,1)
    Pos.Rz(:,ii) = smooth(smooth(smooth(data.marker_data.Markers.(rightFoot(ii,:))(:,verticalDirection))));
    Pos.Ry(:,ii) = smooth(smooth(smooth(data.marker_data.Markers.(rightFoot(ii,:))(:,APdirection))));
    Pos.Lz(:,ii) = smooth(smooth(smooth(data.marker_data.Markers.(leftFoot(ii,:))(:,verticalDirection))));
    Pos.Ly(:,ii) = smooth(smooth(smooth(data.marker_data.Markers.(leftFoot(ii,:))(:,APdirection))));
end

f = fields(Pos);
for ii = 1:length(f)
Pos.(f{ii}) = mean(mean(Pos.(f{ii}),2));
end

% chekc force plates
Nforceplates = length(data.fp_data.GRF_data);
y =[];
x = [];
for p = 1: Nforceplates
    for cc = 1: 4   % forceplate corners
        x(p,cc) =  data.fp_data.FP_data(p).corners(1,cc);
        y(p,cc) = data.fp_data.FP_data(p).corners(2,cc);
    end
    % length of each force plate 
    L1 = sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2);
    L2 = sqrt((x(3)-x(2))^2 + (y(3)-y(2))^2);
    
    
end



