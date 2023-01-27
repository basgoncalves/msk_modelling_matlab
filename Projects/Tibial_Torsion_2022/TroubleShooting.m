
function TroubleShooting
activeFile = [mfilename('fullpath') '.m'];
testing_model_path = fileparts(activeFile);
mskmodelling_path = fileparts(fileparts(testing_model_path));
try fp;catch; addpath(genpath(mskmodelling_path));end


osim_model_path = 'C:\Users\Biomech\Documents\DataFolder\Tibial_Tosion2022\HansSimulations\models\\Ante15_scaled_opt_N10_2times2392Fmax.osim'; 
markerset_path = get_markerset_osim_model(osim_model_path);

osim_model_path = 'C:\Users\Biomech\Downloads\CODE4.0_incltibia\DEFORMED_MODEL\FINAL_PERSONALISEDTORSIONS.osim';

add_markerset_to_osim_model(osim_model_path,markerset_path)
