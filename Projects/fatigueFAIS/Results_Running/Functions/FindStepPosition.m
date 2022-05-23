%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   OrganiseFAI
%   FindGaitCycle_Running
%   btk_loadc3d
%   TimeNorm
%INPUT
%   SubjectFoldersElaborated = cell vector containing the directories of
%                               the ElaboratedData for all participants
%   sessionName = string with the name of the session 
%   Trials = (optional) cell vector 
%   Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
%-------------------------------------------------------------------------
%OUTPUT
%   Pos = average position of the foot contact at the indicated frames
%         relative to the global origin of the laboratory (meters) 
%--------------------------------------------------------------------------

%% Function/Script name
function Pos = FindStepPosition (DirC3Dfile, Markers,Leg,Frames)
fp = filesep;

c3dData = btk_loadc3d(DirC3Dfile);
fs = c3dData.marker_data.Info.frequency;

MarkerNames = fields(c3dData.marker_data.Markers);
MarkerNames = MarkerNames(find (contains(MarkerNames, Leg)));
MarkerNames = MarkerNames(find(contains(MarkerNames,Markers)));

%Step Location at foot contact
Pos = struct;
for k = 1: length(MarkerNames)
    Pos.V(k) = c3dData.marker_data.Markers.(MarkerNames{k})(Frames,3)/1000;
    Pos.AP(k) = c3dData.marker_data.Markers.(MarkerNames{k})(Frames,2)/1000;
    Pos.ML(k) = c3dData.marker_data.Markers.(MarkerNames{k})(Frames,1)/1000;
end

Pos.V = mean(Pos.V);
Pos.AP = mean(Pos.AP);
Pos.ML = mean(Pos.ML);


                