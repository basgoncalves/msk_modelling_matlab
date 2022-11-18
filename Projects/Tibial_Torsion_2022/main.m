

function main

clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed)
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
MSKmodellingdir  = fileparts(fileparts(fileparts(activeFile.Filename))); 
addpath(genpath(MSKmodellingdir));                     

osim_version = 'osim4';                                                                                             % just the verions number before the "." (e.g. 3.2 and 3.3 = "osim3")
torsion_tool_path = ([MSKmodellingdir fp 'src\TorsionTool-Veerkamp2021' fp osim_version]);
rmpath(genpath(fileparts(torsion_tool_path)))
addpath(genpath(torsion_tool_path))

disp(['using torsion tool for ' osim_version])

mainDir = 'C:\Users\Biomech\Documents\1-UVienna\Tibial_Tosion2022\BasSimulations\';
cd([mainDir 'models'])

mainDir = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\osim4\';
cd([mainDir])
% model = ['Ref_scaled_opt_N10_2times2392Fmax.osim']; 
% 
% mainDir = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021';
% cd([mainDir])
model = 'gait2392_genericsimpl_v44.osim';
markerset = ['MarkerSet.xml']; 

if ~exist(markerset,'file')
    osim2markerset(model)
end

legs = {'R'};
femurAnteversion    = [];
femurNeck_shaft     = [];
tibialTorsion       = [-30,-15,0,15,30];

[m,n] = ndgrid(femurAnteversion,femurNeck_shaft);
femurCombos = [m(:),n(:)];


for iLeg = 1:length(legs)
    for iFem = 1:length(femurCombos)
            deform_bone = 'F';
            which_leg = legs{iLeg};
            angle_AV = femurCombos(iFem,1);     % anteversion angle (in degrees)
            angle_NS = femurCombos(iFem,2);     % neck-shaft angle (in degrees)
            
            AV_str = strrep(num2str(angle_AV),'-','minus');
            NS_str = strrep(num2str(angle_NS),'-','minus');

            deformed_model = [which_leg '_NSA_' NS_str '_AVA_' AV_str];

            make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_AV, angle_NS);
    end

    for iTT = 1:length(tibialTorsion)
        deform_bone = 'T';
        which_leg   = legs{iLeg};
        angle_TT    = tibialTorsion(iTT);            % tibial torsion angle (in degrees) % generic = 0 degrees

        TT_str = strrep(num2str(angle_TT),'-','minus');

        deformed_model = [which_leg '_TT_' TT_str];
        cd([mainDir])

        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_TT);
    end
end