

function [XML,MarkersSet] = createMarkersXML (modelDir)


import org.opensim.modeling.*

osimModel = Model(modelDir);
osimModel.initSystem();
markers = osimModel.getMarkerSet;
Nmarkers = osimModel.getNumMarkers;

MarkersSet = char;
for i = 0:Nmarkers-1
   MarkersSet = [MarkersSet ' ' char(markers.get(i))];
end

MarkersSet(1) =[];          % delete first space

XML = struct;
XML.Name = osimModel.getName;
XML.MarkersSetStaticTrials = MarkersSet;
XML.MarkersSetDynamicTrials = MarkersSet;