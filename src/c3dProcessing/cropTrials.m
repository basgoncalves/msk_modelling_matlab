function [events, legName] = cropTrials(acqLS, c3dFile_name, data, leg, motionDirection)
%Take c3d file as input and crop into multiple gait cycles
%Load c3d files and insert heel strike event. Then crop the
% trial based on the heel strike

% First find time index for all events
events = findHeelStrike(data, motionDirection);

% Change cropping based on test leg
if contains(leg, 'R') || contains(leg, 'r')
	legName = 'right';
else
	legName = 'left';
end

HSname = [legName,'HS']; % Specify name of heel strike events

% Create new c3d files of gait cycles
for ii = 1:length(events.(HSname))-1
     
	% Clone acquisition
	acq_newLS = btkCloneAcquisition(acqLS);
	
	% Crop the new acquisition based on time between heel strikes - can
	% modify this to have two acquistions if you want the left leg
	numFrames = events.(HSname)(ii+1,:) - events.(HSname)(ii,:);
	btkCropAcquisition(acq_newLS, events.(HSname)(ii), numFrames);
	
	%Write the new acquisition
	filename = [c3dFile_name(1:end-4), num2str(ii), '.c3d'];
	btkWriteAcquisition(acq_newLS, filename);
         
end

end

