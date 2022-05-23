function SF = getScaleFactors(dirElab, partID, idModel)
% INPUTS
% -------------------------------------------
% dirElab - stg  - Path to elaborated data. Scaled models are a subfolder
% partID  - cell - Participant identifier 
% idModel - stg  - Name of the folder with the models in it
% -------------------------------------------
% OUTPUTS
% SF      - dbl - scale factor
% -------------------------------------------
% About me
% Gets the femoral scale factors for all input participant IDs from
% 'MeasurementScalingFactors.xml' created during scaling with Osim

partID(ismember(partID,'cohort')) = [];
for n = 1:length(partID)
    % Check for hyphen in FASHIoN partIDs and include
    if strfind(partID{n}, 'FAS-') == 1
        % proceed
    else
        partID{n} = regexprep(partID{n}, 'FAS', 'FAS-');
    end
    dirModel = ([dirElab filesep partID{n} filesep 'Session_1\musculoskeletalModels\' idModel]);
    scaleset = xml_read([dirModel filesep partID{n} '_MeasurementScalingFactors.xml']);
    scaleset = scaleset.ScaleSet.objects.Scale;
    segments = {scaleset.segment}.';
    for s = 1:length(segments)
        if strcmp(segments{s}, 'femur_r')
            idx = s;
            break
        end
    end
    SF(n) = scaleset(idx).scales(1);
end