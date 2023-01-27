% osim_model_path = 'C:\Users\Biomech\Documents\DataFolder\Tibial_Tosion2022\HansSimulations\models\Ante15_scaled_opt_N10_2times2392Fmax.osim'


function markerset_path = get_markerset_osim_model(osim_model_path)

import org.opensim.modeling.*
warning on
disp('loading model and markerset...')

% load model
try
    osimModel = Model(osim_model_path);
    [pathname,filename, ext] = fileparts(osim_model_path);

catch
    [filename, pathname, ~] = uigetfile( {'*.osim'},'Select the OpenSim model to extract the markerset from');
    osim_model_path = [pathname filename];
    osimModel = Model(osim_model_path);
end

% create markerset
markerset = osimModel.get_MarkerSet;

markerset_path = strrep(osim_model_path, '.osim', '_markerset.xml');
markerset.print(markerset_path)

clear all
