
mainDir = 'C:\Users\Biomech\Documents\1-UVienna\Tibial_Tosion2022\BasSimulations\';

cd([mainDir 'models'])

model = ['Ref_scaled_opt_N10_2times2392Fmax.osim']; 
markerset = ['MarkerSet.xml']; 

if ~exist(markerset,'file')
    osim2markerset(model)
end

legs = {'R'};
femurAnteversion    = [];
femurNeck_shaft     = [];
tibialTorsion       = [-30 -15 0 15 30];


for iLeg = 1:length(legs)
    for iAnt = 1:length(femurAnteversion)
        for iNS = 1:length(femurNeck_shaft)
            deform_bone = 'F';
            which_leg = legs{iLeg};
            angle_AV = femurAnteversion(iAnt);  % anteversion angle (in degrees)
            angle_NS = femurNeck_shaft(iNS);    % neck-shaft angle (in degrees)
            deformed_model = [which_leg '_NSA_' strrep(num2str(angle_NS),'-','minus') '_AVA_' strrep(num2str(angle_AV),'-','minus')];

            make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_AV, angle_NS);
        end
    end

    for iTT = 1:length(tibialTorsion)
        deform_bone = 'T';
        which_leg = legs{iLeg};
        angle_TT = tibialTorsion(iTT);            % tibial torsion angle (in degrees) % generic = 0 degrees
        deformed_model = [which_leg '_TT_' strrep(num2str(angle_TT),'-','minus')];
        cd([mainDir 'models'])

        make_PEmodel(model, deformed_model, markerset, deform_bone, which_leg, angle_TT);
    end
end