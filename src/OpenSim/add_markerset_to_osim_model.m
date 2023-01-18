% osim_model_path = 'C:\Git\MSKmodelling\src\bops_tool\Templates\Models\gait2392_simbody.osim'
% markerset_path = 'C:\Git\MSKmodelling\src\bops_tool\Templates\MarkersProtocols\UV_PlugInGait.xml'

function add_markerset_to_osim_model(osim_model_path,markerset_path)

import org.opensim.modeling.*
warning on
disp('loading model and markerset...')
% load model and markerset
markerset = MarkerSet(markerset_path);
osimModel = Model(osim_model_path);

% create a copy of the 'body' field named 'socket_parent_frame'
disp('adding markerset to model...')
for iMarker = 0:markerset.getSize()-1
    string_name = char(markerset.get(iMarker).getName());
    body_name =  strrep(char(markerset.get(iMarker).getParentFrameName()),'/bodyset/','');

    % if body does not exist in the current model skip this marker
    try
        osimModel.get_BodySet().get(body_name);
        osimModel.addMarker(markerset.get(iMarker));
    catch         
        warning ([string_name ' not added because ' body_name ' does not exist'])
        continue; 
    end
end

% create a new model name ending with the markerset name
[~,markerset_name] = fileparts(markerset_path);
new_model_name = strrep(osim_model_path,'.osim', ['_' markerset_name '.osim']);                                    

% save new model
osimModel.finalizeConnections()
osimModel.print(new_model_name);
disp(['model saved in ' new_model_name])
clear all