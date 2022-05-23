% Basilio Goncalves 2020
% step length calculation after using MoTONMS and Open Sim TimeWindow get
% kinematics


function [SL,SF] = GetStepLength(DirC3DTrial,TimeWindow,MarkersNames,TestedLeg)


c3dData = btk_loadc3d(DirC3DTrial);
% ratio of frquency = freq of force plates / freq Mocap
fs_mocap = c3dData.marker_data.Info.frequency;
fs_ratio = c3dData.fp_data.Info(1).frequency ./ fs_mocap;
MarkerNames = fields(c3dData.marker_data.Markers);
MarkerNames = MarkerNames(find (contains(MarkerNames, TestedLeg)));
MarkerNames = MarkerNames(find(contains(MarkerNames,MarkersNames)));
FrameWindow = TimeWindow*fs_mocap;
FrameWindow = round(FrameWindow - c3dData.marker_data.First_Frame);
%Step length = difference in position(XYZ) at Toe Off 1 and 2

for i = flip(1:length(MarkerNames))
    M = mean(c3dData.marker_data.Markers.(MarkerNames{i})(FrameWindow(1):FrameWindow(2),1));
    if M == 0
        MarkerNames(i)=[];
    end
end

if ~isempty(MarkerNames)
    
    X1 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(1),1);
    X2 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(2),1);
    Y1 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(1),2);
    Y2 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(2),2);
    Z1 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(1),3);
    Z2 = c3dData.marker_data.Markers.(MarkerNames{1})(FrameWindow(2),3);
    %  step length in METERS
    SL = sqrt((X2-X1)^2 + (Y2-Y1)^2 + (Z2-Z1)^2)/1000;
    % step frequency
    SF  = 1/((FrameWindow(2)-FrameWindow(1))/fs_mocap);

end
