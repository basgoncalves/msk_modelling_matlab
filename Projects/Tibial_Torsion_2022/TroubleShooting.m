
function TroubleShooting
activeFile = [mfilename('fullpath') '.m'];
testing_model_path = fileparts(activeFile);
mskmodelling_path = fileparts(fileparts(testing_model_path));
try fp;catch; addpath(genpath(mskmodelling_path));end

% osim3_og = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\CODE3.3_incltibia\gait2392_genericsimpl.osim';
% file=importdata(osim3_og);
% file_out = file(1:1881+4);
% 
% osim3_morphed = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\CODE3.3_incltibia\DEFORMED_MODEL\FINAL_PERSONALISEDTORSIONS.osim';
% file=importdata(osim3_morphed);
% file_out = file(1:1881+4);
% 
% osim4_og_hans = 'C:\Users\Biomech\Documents\1-DataFolder\Tibial_Tosion2022\HansSimulations\models\Ref_scaled_opt_N10_2times2392Fmax.osim';
% file=importdata(osim4_og_hans);
% file_out = file(1:1881+4);
% 
% osim4_og_bas = 'C:\Users\Biomech\Documents\1-DataFolder\Tibial_Tosion2022\BasSimulations\models\Ref_scaled_opt_N10_2times2392Fmax.osim';
% torsion_tool_bops(osim4_og_bas,4) 
% 
% osim3_og = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\osim3\gait2392_genericsimpl.osim';
% torsion_tool_bops(osim3_og,3) 
% 
% osim4_og = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\osim4\gait2392_genericsimplOS4.osim';
% torsion_tool_bops(osim4_og,4)
%
% osim4_bas = [testing_model_path '\gait2392_genericsimplOS4_BG.osim'];
% torsion_tool_bops(osim4_bas,4)

osim4_bas_markers = [testing_model_path '\testing_models\gait2392_genericsimplOS4_BG_markers.osim'] ;
torsion_tool_bops(osim4_bas_markers,4)
