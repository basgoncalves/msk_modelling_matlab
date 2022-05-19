function [on_i, off_i] = detectNewForcePlateEvents(Fv, data, forcePlate)
%Attempts to detect gait events from Force plate data if they were detected incorrectly previously.

% Function changes the FP threshold and time between events until correct
% events are registered
% INPUT -   data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m as well as a filename string

%           Fv- variable containing boolean values for when the force plate
%           data is above threshold
%
%           forcePlate - Variable signifying which force plate is begin analysed
% OUTPUT -  new on and off events
%

% First force plate
if forcePlate == 1
	
	% Try increasing threshold
	thresh = 30;
	nt = find(Fv>thresh(1));
	
	dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);
	on_i = [nt(1); nt(dnt+1)];
	off_i = [nt(dnt); nt(end)];
	
	% Check parameters for inconsistencies.
	if (off_i(1)-on_i(1)) < 7
		off_i(1) = [];
		on_i(1) = [];
	end
	
	if (off_i(end)-on_i(end)) < 7
		off_i(end) = [];
		on_i(end) = [];
	end
	
	ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.015);
	if ~isempty(ns)
		if ns(end) == length(off_i)
			ns(end) = [];
		end
		off_i(ns) = [];
		on_i(ns+1) = [];
	end
	
	if length(on_i) ~= 2
		disp('Threshold not high enough to detect multiple events, increasing to 50N')
		% Try increasing threshold
		thresh = 50;
		nt = find(Fv>thresh(1));
		
		dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);
		on_i = [nt(1); nt(dnt+1)];
		off_i = [nt(dnt); nt(end)];
	end
	
	ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.010);
	if ~isempty(ns)
		if ns(end) == length(off_i)
			ns(end) = [];
		end
		off_i(ns) = [];
		on_i(ns+1) = [];
	end
	
% Second force plate
elseif forcePlate == 2
	
	% Try increasing threshold
	try thresh = 30;
		nt = find(Fv>thresh(1));
		dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);
		on_i = [nt(1); nt(dnt+1)];
		off_i = [nt(dnt); nt(end)];
		disp(['Changed FP thresh to: ' num2str(thresh)]);
	catch
	end
	if length(on_i) ~= 3
		
		% Then try reducing time between events
		thresh = 30;
		nt = find(Fv>thresh(1));
		disp('Changed time between events');
		
		try dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.010);
			on_i = [nt(1); nt(dnt+1)];
			off_i = [nt(dnt); nt(end)];
		catch
		end
	end
	if length(on_i) ~= 3
		% Do both
		thresh = 50;
		nt = find(Fv>thresh(1));
		try
			dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.010);
			on_i = [nt(1); nt(dnt+1)];
			off_i = [nt(dnt); nt(end)];
			disp(['Changed FP thresh to: ' num2str(thresh) ' and event timing']);
		catch
		end
	end
	
	% Try again and reduce time between events to 5 frames
	if length(on_i) ~= 3
		% Do both
		thresh = 50;
		nt = find(Fv>thresh(1));
		try
			dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.005);
			on_i = [nt(1); nt(dnt+1)];
			off_i = [nt(dnt); nt(end)];
			disp('Changed FP thresh and event timing AGAIN');
		catch
		end
	end
end

end

