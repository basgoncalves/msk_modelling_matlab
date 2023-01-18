

activeFile = matlab.desktop.editor.getActive;
bopsdir  = fileparts(activeFile.Filename);
cd([bopsdir '\..\..']);
activate_msk_modelling

osim_model_path = 'C:\Git\MSKmodelling\src\bops_tool\Templates\Models\gait2392_simbody.osim';
markerset_path = 'C:\Git\MSKmodelling\src\bops_tool\Templates\MarkersProtocols\UV_PlugInGait.xml';

add_markerset_to_osim_model(osim_model_path,markerset_path)


import org.opensim.modeling.*

osimC3D