function [times, legName] = cropTrialsMain(pname, c3dFile_name, acqLS, dynamicCropFolders, data, leg, motionDirection)
%Main function to crop trials based on right heel-strike times
%   Crop the walking trials into consecutive gait cycles from
%   heel-strike to next heel-strike. Gait cycles cropped to the specified
%   leg

cd(pname)

% Insert Events and crop trials into conscutive gait cycles
% that start on right heel-strike
% Only run this for walking trials, not kneeFJC or static trials.
walkingTrial = strcmp(dynamicCropFolders, c3dFile_name(1:end-4));

% Function to crop
if any(walkingTrial) == 1
	
	% Find right heel strike and right toe off
    [events, legName] = cropTrials(acqLS, c3dFile_name,data, leg, motionDirection);
    
	HSname = [legName,'HS']; TOname = [legName, 'TO'];
	
	% Create a times variable with heel-strike and toe-off
    % to use in subsequent analysis.
    % Make sure HS corresponds with TO in length otherwise error will
    % be thrown.
    if length(events.(HSname)) > length(events.(TOname))
        events.(HSname)(end) = [];
    elseif length(events.(HSname)) < length(events.(TOname))
        events.(TOname)(end) = [];
    end
    
    times = [events.(HSname), events.(TOname)];
else
    times = [];
end

clearvars -except times legName

end

