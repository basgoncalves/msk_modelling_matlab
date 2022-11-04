
mainDir = 'C:\Users\Biomech\Documents\1-UVienna\Tibial_Tosion2022\BasSimulations\';
cd([mainDir 'models'])
% model = ['Ref_scaled_opt_N10_2times2392Fmax.osim']; 
% 
% mainDir = 'C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021';
% cd([mainDir])
model = 'gait2392_genericsimpl.osim';
markerset = ['MarkerSet.xml']; 

if ~exist(markerset,'file')
    osim2markerset(model)
end

legs = {'R'};
femurAnteversion    = [];
femurNeck_shaft     = [];
tibialTorsion       = [-30 -15 0 15 30];

[m,n] = ndgrid(femurAnteversion,femurNeck_shaft);
femurCombos = [m(:),n(:)];


for iLeg = 1:length(legs)
    for iFem = 1:length(femurCombos)
            deform_bone = 'F';
            which_leg = legs{iLeg};
            angle_AV = strrep(num2str(femurCombos(iFem,1)),'-','minus');     % anteversion angle (in degrees)
            angle_NS = strrep(num2str(femurCombos(iFem,2)),'-','minus');     % neck-shaft angle (in degrees)
            deformed_model = [which_leg '_NSA_' angle_NS '_AVA_' angle_AV];

            make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_AV, angle_NS);
    end

    for iTT = 1:length(tibialTorsion)
        deform_bone = 'T';
        which_leg   = legs{iLeg};
        angle_TT    = strrep(num2str(tibialTorsion(iTT)),'-','minus');            % tibial torsion angle (in degrees) % generic = 0 degrees
        deformed_model = [which_leg '_TT_' strrep(num2str(angle_TT),'-','minus')];
        cd([mainDir 'models'])

        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_TT);
    end
end