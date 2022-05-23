% Find events of the force plates during running (make sure you have only
% the exact number of events that you want for the "TestedLeg";
%
%

function [StanceOnFP] = findGaitCycle_Events(c3dFilePathAndName,trialName,rightFootMarkers,leftFootMarkers)

c3dData = btk_loadc3d(c3dFilePathAndName);
fs_grf = c3dData.fp_data.Info(1).frequency;
fs_ratio = fs_grf ./ c3dData.marker_data.Info.frequency;

markerStruct = c3dData.marker_data.Markers;                                                                         % get average foot position
APposition_right = avgPosition(markerStruct,rightFootMarkers);
APposition_left =  avgPosition(markerStruct,leftFootMarkers);

if length(APposition_right)<4
    for k = length(APposition_right)+1:4
        APposition_right    = [APposition_right; APposition_right(end)];
        APposition_left     = [APposition_left; APposition_left(end)];
    end
end

Nforceplates = length(c3dData.fp_data.GRF_data);
leg ={};
for i = 1:Nforceplates
    Fz = downsample(c3dData.fp_data.GRF_data(i).F(:,3),fs_ratio);                                                   % vertical force (Fz)
    CP = downsample(c3dData.fp_data.GRF_data(i).P(:,1),fs_ratio);                                                   % centre of preassure (CP)
    
    if length(Fz)<4
        for k = length(Fz)+1:4
            Fz = [Fz; Fz(end)];
            CP = [CP; CP(end)];
        end
    end
    
    Fz_filtered = ZeroLagButtFiltfilt((1/fs_grf), 100, 1, 'lp', Fz);
    timeWindow  =  find(abs(Fz_filtered)> 20);                                                                      % find data only where Fz > 20N
    
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