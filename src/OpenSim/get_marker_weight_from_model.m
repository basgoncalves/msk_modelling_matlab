function get_marker_weight_from_model(model_path,marker_weights_path)


import org.opensim.modeling.*;

% Load the OpenSim model
model = Model(model_path);

% Get the set of markers in the model
markerSet = model.getMarkerSet();

% Create a file to write the marker weights to
fileID = fopen(marker_weights_path, 'w');

% Write the header for the marker weights file
fprintf(fileID, '<MarkerWeights>\n');

% Loop over each marker in the set
for i = 0:markerSet.getSize()-1
    % Get the current marker
    marker = markerSet.get(i);
    
    % Write the marker information to the file
    fprintf(fileID, '  <marker>\n');
    fprintf(fileID, '    <name>%s</name>\n', char(marker.getName()));
    fprintf(fileID, '    <weight>1.0</weight>\n');
    fprintf(fileID, '  </marker>\n');
end

% Write the footer for the marker weights file
fprintf(fileID, '</MarkerWeights>\n');

% Close the file
fclose(fileID);
