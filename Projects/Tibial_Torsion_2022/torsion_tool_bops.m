

function torsion_tool_bops(model_path,osim_version)

clc; close all;  % clean workspace (use restoredefaultpath if needed)
if nargin < 1 || ~isfile(model_path)
    model_path = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\osim4\gait2392_genericsimplOS4.osim';
end

if nargin < 2
    osim_version = 4;
end

add_tosion_tool_to_path(osim_version,model_path)

% geneirc values (in degrees)
legs = {'R'};
original_AV = 17.6;  % anteversion angle
original_NS = 123.3; % neck-shaft angle
original_TT = 0;     % tibial torsion angle

femurAnteversion_angles   = original_AV + [];
femurNeckShaft_angles     = original_NS + [];
[m,n] = ndgrid(femurAnteversion_angles,femurNeckShaft_angles);

femurTorsion_angles     = [m(:),n(:)];
tibialTorsion_angles    = original_TT + [-30,-15,0,15,30];

for iLeg = 1:length(legs)
    which_leg   = legs{iLeg};
    % apply all the femur rotations
    deform_bone = 'F';
    apply_bone_torsions(model_path,femurTorsion_angles,which_leg,deform_bone)

    % apply all the tibial rotations
    deform_bone = 'T';
    apply_bone_torsions(model_path,tibialTorsion_angles,which_leg,deform_bone)
end


%============================================================================================%
%=====================================CALLBACK FUNCTIONS=====================================%
%============================================================================================%
function add_tosion_tool_to_path(osim_version,model_path)

osim_version_str = ['osim' num2str(floor(osim_version))];

% get dir of the current file
activeFile = [mfilename('fullpath') '.m'];
mskmodelling_path = fileparts(fileparts(fileparts(activeFile)));

% if the mskmodelling pipeline is not in the path add it
try fp;catch; addpath(genpath(mskmodelling_path));end


% define dir of the torsion tool and check all the versions in the folder
torsion_tool_path = [mskmodelling_path fp 'src\TorsionTool-Veerkamp2021'];
torsion_tool_path_version = ([torsion_tool_path fp osim_version_str]);
all_versions = ls(torsion_tool_path);


% check which versions of the torsion tool ar in the path
onPath_current_version = is_on_path(torsion_tool_path_version);
onPath_other_versions = [];
for i = 3:size(all_versions,1)
    if ~isequal(strtrim(all_versions(i,:)), osim_version_str)
        onPath_other_versions(end+1) = is_on_path([torsion_tool_path fp strtrim(all_versions(i,:))]);
    end
end


% if none or more than one version are in the path
if onPath_current_version==0 || any(onPath_other_versions == 1)
    disp(['adding torsion tool for OpenSim version ' osim_version_str ' to the path'])
    warning off
    rmpath(genpath(torsion_tool_path))                      % remove all versions from path
    addpath(genpath(torsion_tool_path_version))             % add to path only the needed version
end


% if 
dir_model_path = fileparts(model_path);
if ~isfolder([dir_model_path fp 'femur'])
    
    fprintf('\n \n copying vtp files to the location of used model... \n \n')

    copyfile([torsion_tool_path_version fp 'femur'],[dir_model_pathfp 'femur'])
    copyfile([torsion_tool_path_version fp 'tibia'],[dir_model_pathfp 'tibia'])
    copyfile([torsion_tool_path_version fp 'calcn'],[dir_model_pathfp 'calcn'])
    copyfile([torsion_tool_path_version fp 'talus'],[dir_model_pathfp 'talus'])
    copyfile([torsion_tool_path_version fp 'toes'] ,[dir_model_pathfp 'toes'])
end

function apply_bone_torsions(model_path,Torsion_angles,which_leg,deform_bone)

[dir_contains_model,model,ext] = fileparts(model_path);
model = [model ext];
markerset = 'MarkerSet.xml';
cd(dir_contains_model)
if ~exist(markerset,'file')
    get_markerset_osim_model(model)
end

for i = 1:length(Torsion_angles)

    cd(dir_contains_model)
    if contains(deform_bone,'T')
        angle_TT        = Torsion_angles(i);
        TT_str          = strrep(num2str(angle_TT),'-','minus');
        deformed_model  = [which_leg '_TT_' TT_str];
        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_TT);
    else
        angle_AV = femurCombos(iFem,1);
        angle_NS = femurCombos(iFem,2);
        AV_str = strrep(num2str(angle_AV),'-','minus');
        NS_str = strrep(num2str(angle_NS),'-','minus');
        deformed_model = [which_leg '_NSA_' NS_str '_AVA_' AV_str];
        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_AV, angle_NS);
    end
end