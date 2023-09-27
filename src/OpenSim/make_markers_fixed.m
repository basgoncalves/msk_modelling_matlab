function make_markers_fixed(modelPath,fixed_logic)


if nargin < 2 
    fixed_logic = false;
end

import org.opensim.modeling.*

model = Model(modelPath);

markerSet = model.getMarkerSet();
markerNames = cell(markerSet.getSize(), 1);

for i = 0:markerSet.getSize() - 1
    markerNames{i + 1} = char(markerSet.get(i).getName());
end

excludeMarkers = {'RHJC', 'RKJC', 'RAJC', 'LHJC', 'LKJC', 'LAJC'};

for i = 1:length(markerNames)
    markerName = markerNames{i};
    
    if ~ismember(markerName, excludeMarkers)
        markerSet.get(markerName).set_fixed(fixed_logic);
    end
end


model.print(modelPath);
