% Find events of the force plates during running (make sure you have only
% the exact number of events that you want for the "TestedLeg";
%
%

function [StanceOnFP,event_frames] = findGaitCycle_Events(c3dFilePathAndName,rightFootMarkers,leftFootMarkers)

c3dData     = btk_loadc3d(c3dFilePathAndName);
fs_grf      = c3dData.fp_data.Info(1).frequency;
fs_ratio    = fs_grf ./ c3dData.marker_data.Info.frequency;

markerStruct        = c3dData.marker_data.Markers;                                                                  % get average foot position
APposition_right    = avgPosition(markerStruct,rightFootMarkers);
APposition_left     =  avgPosition(markerStruct,leftFootMarkers);

threshold_newotons  = 20;                                                                                           % GRF threshold in Newtons

if length(APposition_right)<4
    for k = length(APposition_right)+1:4
        APposition_right    = [APposition_right; APposition_right(end)];
        APposition_left     = [APposition_left; APposition_left(end)];
    end
end

Nforceplates = length(c3dData.fp_data.GRF_data);
firstFrame  = c3dData.marker_data.First_Frame;
leg ={};
event_frames = struct;
event_frames.firstFrame = firstFrame;
for i = 1:Nforceplates
    Fz = downsample(c3dData.fp_data.GRF_data(i).F(:,3),fs_ratio);                                                   % vertical force (Fz)
    CP = downsample(c3dData.fp_data.GRF_data(i).P(:,1),fs_ratio);                                                   % centre of preassure (CP)
    
    if length(Fz)<4
        for k = length(Fz)+1:4
            Fz = [Fz; Fz(end)];
            CP = [CP; CP(end)];
        end
    end
    
    WarningOn   = 0;
    Fz_filtered = ZeroLagButtFiltfilt((1/fs_grf), 100, 1, 'lp', Fz,[],WarningOn);
    timeWindow  = find(abs(Fz_filtered)> threshold_newotons);                                                       % find data only where Fz > 20N
    
    Diff_right  = abs(mean(abs(CP(timeWindow)) - abs(APposition_right(timeWindow))));                               % calculate difference between CP and right/left feet
    Diff_left   = abs(mean(abs(CP(timeWindow)) - abs(APposition_left(timeWindow))));
    [~,idxMin]  = min([Diff_right,Diff_left]);
    
    if isempty(timeWindow)
        leg{i} = {'-'};
    elseif idxMin == 1                                                                                              % if right foot is closer to CP
        leg{i} = 'R';
    elseif idxMin == 2
        leg{i} ='L';
    else
        leg{i} = {'-'};
    end
    
%     event_frames = DetermineEvent(event_frames,Fz_filtered,timeWindow,threshold_newotons,leg{i});
    
end

StanceOnFP =  struct('Forceplatform',split(cellstr(sprintf('%d ',1:Nforceplates)),' ')', 'leg',leg);


function APposition = avgPosition(markerStruct,FootMarkers)

FootMarkers = split(FootMarkers,' ');
FootMarkers = intersect(FootMarkers,fields(markerStruct));

if length(FootMarkers) < 1
    APposition = [];
    warning on
    warning('foot markers do not exist')
    return
end

for i = 1:length(FootMarkers)
    APposition(:,i) = markerStruct.(FootMarkers{i})(:,1);
end
APposition = mean(APposition,2);


function event_frames = DetermineEvent(event_frames,Fz_filtered,timeWindow,threshold_newotons,leg) % leg = R / L

if length(timeWindow) < 1
    return
end

firstFrame = timeWindow(1);
lastFrame   = timeWindow(end);

if contains(leg,'R')
    leg_name = 'Right';
elseif contains(leg,'L')
    leg_name = 'Left';
end


if Fz_filtered(firstFrame-1) < threshold_newotons && Fz_filtered(firstFrame+1) > threshold_newotons                 % detect foot strike (i.e. fram prior force is < threshold)
    event_frames.([leg_name '_Foot_Strike']) = firstFrame;
    
end

if Fz_filtered(lastFrame-1) > threshold_newotons && Fz_filtered(lastFrame+1) < threshold_newotons                   % detect foot off (i.e. fram after force is < threshold)
    event_frames.([leg_name '_Foot_Off']) = lastFrame;
    
end

GRF_Binary = (Fz_filtered>threshold_newotons);
GRF_Binary(end+1:end+50) = 0;
% 
% if length(find(GRF_Binary))>2
%     
%     if mean(PathHeelMarkerRy(find(GRF_Binary)))==0          % if marker data
%         OldPath = PathHeelMarkerRy;
%         PathHeelMarkerRy = PathToeMarkerRy;
%         PathToeMarkerRy = OldPath;
%     end
%     
%     if mean(PathHeelMarkerLy(find(GRF_Binary)))==0          % if marker data
%         OldPath = PathHeelMarkerLy;
%         PathHeelMarkerLy = PathToeMarkerLy;
%         PathToeMarkerLy = OldPath;
%     end
%     
%     % calculate horizontal velocity of marker
%     velocity_R = abs(mean(calcVelocity (PathHeelMarkerRy(find(GRF_Binary)),fs_Markers)));
%     velocity_L = abs(mean(calcVelocity (PathHeelMarkerLy(find(GRF_Binary)),fs_Markers)));
%     
%     if velocity_R > velocity_L                                                          %if right foot is moving faster
%         contact = find(GRF_Binary);
%         forceplateEvents(p).Left_Foot_Strike = contact(1);
%         forceplateEvents(p).Left_Foot_Off = contact(end);
%     elseif velocity_R < velocity_L                                                      %if left foot is moving faster
%         contact = find(GRF_Binary);
%         forceplateEvents(p).Right_Foot_Strike = contact(1);
%         forceplateEvents(p).Right_Foot_Off = contact(end);
%     end
%     
% else
%     forceplateEvents(p).Right_Foot_Strike = [];       %only need one empty cell to create empty column
% end
% 
% 
