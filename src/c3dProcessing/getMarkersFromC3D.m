function [markersList] = getMarkersFromC3D(c3dFile, pname)
%Get markers from c3d file for analysis of ROM
%   Input ROM c3d file from load sharing data and output the marker data
%   for joint angle calculation.

% Obtain marker data
markerDataLoc = [pname, filesep, c3dFile];
c3dID=btkReadAcquisition(markerDataLoc);
Markers=btkGetMarkers(c3dID);

% Create empty structure for marker data.
markersList = struct();

% Define the marker trajectories of interest
markerNames = {'LASI' ,'LPSI', 'LLFC', 'LMFC', 'LMT1', 'LMT5', 'LCAL', 'LLMAL', 'LMMAL',... % LEFT SIDE HIP/LEG
     'RASI' ,'RPSI', 'RLFC', 'RMFC', 'RMT1', 'RMT5', 'RCAL', 'RLMAL', 'RMMAL',... % RIGHT SIDE HIP/LEG
     'T8', 'CLAV', 'THO3', 'LACR1', 'LPUA1', 'LPUA2', 'LPUA3', 'LLEP', 'LMEP', 'LCAR',... % TORSO AND LEFT SIDE ARM
     'RACR1', 'RPUA1', 'RPUA2', 'RPUA3', 'RLEP', 'RMEP', 'RCAR'}; % RIGHT SIDE ARM

% Loop through all markers and obtain those in c3d from markerNames list.
for markers = 1:length(markerNames)
     try
     markersList.(markerNames{markers}) = Markers.(markerNames{markers})(:,1:3);
     catch % Catch if marker is not in c3d file and break the for-loop
          disp(['Marker ', markerNames{markers},...
               ' does not exist in c3d file, please check ' c3dFile,...
               ' for missing trajectories'])
          break
     end
end

end
