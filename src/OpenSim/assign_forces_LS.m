function data = assign_forces_LS(data,assign_markers,assign_bodies, thresh, filter_freq)
% function data = assign_forces(data,assign_markers,assign_bodies, thresh)
%
% Function to assign any recorded forces to a specific body based on the
% position of a nominated marker attached to the body.
%
% INPUT -   data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m as well as a filename string
%           assign_markers - cell array of marker names to be used as
%               guides to match to a force vector COP (e.g. heel marker)
%           assign_bodies - cell array with the matching body name that any
%               matching forces can be assigned to
%           thresh - an array of length 2 e.g. [30 0.15] represnting the
%               the 1) threshold force to use to determine a force event (default 30)
%               and 2) the mean distance from the marker to the COP
%               that is used to assess a positive assignment (in meters -
%               defaults to 0.2m)
%           filter_freq - frequency to low-pass filter the GRF data
%               (default = 25, set to -1 for no filtering);
%
% OUTPUT -  data - structure containing the relevant data with assignments
%
% Written by Glen Lichtwark (University of Queensland)
% Updated September 2014

% Updated June 2016 by Gavin Lenton (Griffith University) for compability with load
% sharing project data.
% Code now assigns force even when two markers are within the designated
% threshold.

if nargin<5
	filter_freq = 25; % default filter frequency
end

if nargin<4
	thresh(1) = 30; % default force threshold
	thresh(2) = 0.2; % default position threshold
end

% make sure the correct data is available
if ~isfield(data,'marker_data')
	error(['Ensure that the data structure contains a field called "marker_data" '...
		'that contains marker fields and coordinates - see btk_loadc3d']);
end

if ~isfield(data,'fp_data')
	error(['Ensure that the data structure contains a field called "fp_data" '...
		'that contains force plate data - see btk_loadc3d']);
end

% check that there is one assigned marker for each assigned body
if iscell(assign_markers)
	if iscell(assign_bodies)
		if length(assign_markers) ~= length(assign_bodies)
			error('Cell arrays for assigned markers and bodies must be the same length')
		else N = length(assign_markers);
		end
	else error('Assigned marker list and assigned bodies must both be cell arrays of same length with paired matchings')
	end
else error('The body and marker assignment lists must be cell arrays');
end

% define the ratio of force sampling frequency to marker sampling frequency
% F = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; %assume same sampling frequency on all plates!!!
dt = 1/data.fp_data.Info(1).frequency;

% initilise the first lot of force arrays (this will grow as different
% bodies contact each plate)
for b = 1:2
	data.GRF.FP(b).F = zeros(size(data.fp_data.GRF_data(b).F));
	data.GRF.FP(b).M = zeros(size(data.fp_data.GRF_data(b).M));
	data.GRF.FP(b).P = zeros(size(data.fp_data.GRF_data(b).P));
end

% Loop through force plates
for i = 1:length(data.fp_data.GRF_data)
	
	% if this is a cyclic movement, then it is best to make the baseline
	% zero as this improves capacity for detecting events
	
	% Find the zero value of the first force plate
	% Know that the end of the trial does not contain a stance because we
	% process from right HS to right HS
	if i == 1
		zeroValue = mean(data.fp_data.GRF_data(i).F(900:end-10,3));
		
		% subtract this value from the data
		data.fp_data.GRF_data(i).F(:,3) = data.fp_data.GRF_data(i).F(:,3) - zeroValue;
	end
	
	% filter the force and determine when the foot is in contact with the
	% ground - this is not the same filtering as is done on the final data
	% and is required to be able to determine the contact periods
	Fv = lpfilter(data.fp_data.GRF_data(i).F(:,3), 30,dt, 'damped');
		
	if (max(Fv)-min(Fv))>400
		Fv = Fv-median(Fv(Fv<(min(Fv)+25)));
	end
	
	% Remove any minus values
	minusValues = Fv < 0;
	Fv(minusValues) = 0;
	data.fp_data.GRF_data(i).F(minusValues,3) = 0;
	
	nt = find(Fv>thresh(1));
	
	if ~isempty(nt)
		
		% find out when the gaps between ground contact times are and use this
		% to define on and off times (there will always be an on as the first
		% point and off as the last point), a gap of greater than 25
		% miliseconds is considered a new event (change the 0.025 value below
		% to adjust this).
		dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);
		
		% If dnt is empty then try reducing gap length to 0.010
		if isempty(dnt)
			dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.010);
		end
		
		% Create on and off events
		on_i = [nt(1); nt(dnt+1)];
		off_i = [nt(dnt); nt(end)];
		
		if (off_i(1)-on_i(1)) < 7
			off_i(1) = [];
			on_i(1) = [];
		end
		
		if (off_i(end)-on_i(end)) < 7
			off_i(end) = [];
			on_i(end) = [];
		end
		
		% Finds if events are really close
		ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.015);
		if ~isempty(ns)
			if ns(end) == length(off_i)
				ns(end) = [];
			end
			off_i(ns) = [];
			on_i(ns+1) = [];
		end
		
		
		%% Detect if force assignments were incorrect
		% (Should always be at least two on and two off events in FP1)
		if i == 1 && length(on_i) ~= 2
			disp('Threshold not high enough to detect multiple events, increasing to 50N')
			% Try increasing threshold
			thresh = 50;
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
			
			ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.08);
			if ~isempty(ns)
				if ns(end) == length(off_i)
					ns(end) = [];
				end
				off_i(ns) = [];
				on_i(ns+1) = [];
			end
			
			if i == 1 && length(on_i) ~= 2
				disp('Threshold not high enough to detect multiple events, increasing to 100N')
				% Try increasing threshold
				thresh = 100;
				nt = find(Fv>thresh(1));
				
				dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.010);
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
		end
		if i == 2 && length(on_i) ~= 3
			disp('Not enough events on FP2, modifying parameters')
			% Try increasing threshold
			try thresh = 50;
				nt = find(Fv>thresh(1));
				dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.015);
				on_i = [nt(1); nt(dnt+1)];
				off_i = [nt(dnt); nt(end)];
				disp('Changed FP thresh');
			catch
			end
			if length(on_i) ~= 3
				
				% Then try reducing time between events
				thresh = 30;
				nt = find(Fv>thresh(1));
				disp('Changed time between events');
				
				try dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.005);
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
					dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.005);
					on_i = [nt(1); nt(dnt+1)];
					off_i = [nt(dnt); nt(end)];
					disp('Changed FP thresh and event timing');
				catch
				end
			end
			
			% Try again and reduce time between events to 1 frame
			if length(on_i) ~= 3
				% Do both
				thresh = 80;
				nt = find(Fv>thresh(1));
				try
					dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.001);
					on_i = [nt(1); nt(dnt+1)];
					off_i = [nt(dnt); nt(end)];
					disp('Changed FP thresh and event timing AGAIN');
				catch
				end
			end
		end
		
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
		
		% Create variable to keep track of event frames
		FP(i).On = on_i;
		FP(i).Off = off_i;
		
		% loop through each event (from one value of on_i to its corresponding off_i)
		% and determine which of the bodies is contacting to make this force
		for j = 1:length(on_i)
			
			% define the current period of interest
			a = on_i(j):off_i(j);
			
			% FP 1 = R/L
			% FP 2 = L/R/L
			
			% FIRST FORCE PLATE CONDITIONS
			
			% IF force plate = first (e.g., 1) and it's the first force assignment the
			% force should always go to right body because trials always start with
			% right heel-strike
			if i == 1 && j == 1
				if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
					
					% Clean up AP force
					force_AP = data.fp_data.GRF_data(i).F(:,2) > 0;
					data.fp_data.GRF_data(i).F(force_AP,2) = 0;
					data.fp_data.GRF_data(i).F(1:find(force_AP,1,'first'),2) = 0;
					
					data.GRF.FP(i).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP(i).M(a(1):dnt(end),:) = data.fp_data.GRF_data(i).M(a(1):dnt(end),:);
					
					% Fix beginning and end of COP data
					% ML
					centre_plate_2_ML = mode(data.fp_data.GRF_data(2).P(:,1));
					% Fix beginning
					data.fp_data.GRF_data(i).P(1:a(1)+1,1) = centre_plate_2_ML;
					% Fix end
					data.fp_data.GRF_data(i).P(a(1):a(1)+10,1) = mean(data.fp_data.GRF_data(i).P(a,1));
					ML_bad = data.fp_data.GRF_data(i).P(1:a(end),1) < (centre_plate_2_ML - 10);
					data.fp_data.GRF_data(i).P(ML_bad,1) = mean(data.fp_data.GRF_data(i).P(a,1));
					
					% AP
					centre_plate_1_AP = mode(data.fp_data.GRF_data(1).P(:,2));
					% Fix beginning
					data.fp_data.GRF_data(i).P(1:a(1)+3,2) = centre_plate_1_AP;
					AP_bad = find(data.fp_data.GRF_data(i).P(200:a(end),2) > centre_plate_1_AP);
					% Fix end
					data.fp_data.GRF_data(i).P(AP_bad + 199,2) = centre_plate_1_AP;
					data.GRF.FP(i).P(a(1):dnt(end),:) = data.fp_data.GRF_data(i).P(a(1):dnt(end),:);
					
					% Clean up moments at the beginning
					data.GRF.FP(i).M(a(1):a(1)+5,:) = 0;
					
				else % otherwise just assign the raw data
					data.GRF.FP(i).(assign_bodies{i}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP(i).(assign_bodies{i}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
					data.GRF.FP(i).(assign_bodies{i}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
				end
				
				% If force plate  = 1 and it's the second force assignment we always
				% know it will be for the second (i.e., left) body.
			elseif i == 1 && j == 2
				if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
					data.GRF.FP(j).F(a,:) = lpfilter(data.fp_data.GRF_data(i).F(a,:),10,dt, 'damped');
					data.GRF.FP(j).M(a,:) = lpfilter(data.fp_data.GRF_data(i).M(a,:),10,dt, 'damped');
					data.GRF.FP(j).P(a,:) = lpfilter(data.fp_data.GRF_data(i).P(a,:),10,dt, 'damped');
					
					% OLD FILTERING HERE
					%                          data.GRF.FP(j).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
					%                          data.GRF.FP(j).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
					%                          data.GRF.FP(j).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
					
				else % otherwise just assign the raw data
					data.GRF.FP(i).(assign_bodies{j}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP(i).(assign_bodies{j}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
					data.GRF.FP(i).(assign_bodies{j}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
				end
				
				%SECOND FORCE PLATE CONDITIONS
				
				% If force plate = 2 and it's the first force
				% assignment we know that it's the left body toe-off
			elseif i == 2 && j == 1
				if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
					data.GRF.FP(i).F(a,:) = lpfilter(data.fp_data.GRF_data(i).F(a,:),10,dt, 'damped');
					data.GRF.FP(i).M(a,:) = lpfilter(data.fp_data.GRF_data(i).M(a,:),10,dt, 'damped');
					data.GRF.FP(i).P(a,:) = lpfilter(data.fp_data.GRF_data(i).P(a,:),10,dt, 'damped');
					
					% OLD FILTER HERE
					%                          data.GRF.FP(i).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
					%                          data.GRF.FP(i).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
					%                          data.GRF.FP(i).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
					
				else % otherwise just assign the raw data
					data.GRF.FP(i).(assign_bodies{i}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP(i).(assign_bodies{i}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
					data.GRF.FP(i).(assign_bodies{i}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
				end
				
				% If force plate = 2 and it's the second force
				% assignment we know that it's the right body late
				% stance
			elseif i == 2 && j == 2
				if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 26Hz)
					
					if length(on_i) == 3
						
						% Add the Forces from first and second plates during
						% transition period.
						
						% ML GRF is noisy so have to fix
						force_ML = data.fp_data.GRF_data(i).F(:,1);
						force_ML(1:a(1)-1,1) = 0; force_ML(a(end)+1:end, 1) = 0;
						
						data.GRF.FP(1).F(a,2:3) = [(data.fp_data.GRF_data(i).F(a(1):FP(1).Off(1),2:3)+...
							data.fp_data.GRF_data(1).F(a(1):FP(1).Off(1),2:3));...
							data.fp_data.GRF_data(i).F(FP(1).Off(1)+1:a(end),2:3)];
						
						data.GRF.FP(1).F(a,1) = [(force_ML(a(1):FP(1).Off(1)-1,:)+...
							data.fp_data.GRF_data(1).F(a(1):FP(1).Off(1)-1,1));...
							force_ML(FP(1).Off(1):a(end),1)];
						
						data.GRF.FP(1).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
						
						% Clean up moments at end
						data.GRF.FP(1).M(a(end)-5:a(end),:) = 0;
						
						% Centre of each plate in AP direction
						centre_plate_2_AP = mode(data.fp_data.GRF_data(2).P(:,2));
						centre_plate_2_ML = mode(data.fp_data.GRF_data(2).P(:,1));
						
						% Fix beginning and end of COP data
						% ML
						% Fix beginning
						data.fp_data.GRF_data(i).P(a(1)-1,1) = centre_plate_2_ML;
						data.fp_data.GRF_data(i).P(a(1):a(1)+15,1) = mean(data.fp_data.GRF_data(i).P(a,1));
						data.fp_data.GRF_data(i).P(1:a(1)-2,1) = centre_plate_2_ML;
						
						% Fix end
						ML_bad_2 = find(data.fp_data.GRF_data(i).P(a(1):a(end)+1,1) < (centre_plate_2_ML - 10)) + (a(1)-1);
						data.fp_data.GRF_data(i).P(ML_bad_2,1) = mean(data.fp_data.GRF_data(i).P(a,1));
						data.fp_data.GRF_data(i).P(a(end)-10:a(end),1) = mean(data.fp_data.GRF_data(i).P(a,1));
						data.fp_data.GRF_data(i).P(a(end)+1,1) = centre_plate_2_ML;
						
						% AP
						% Fix end
						data.fp_data.GRF_data(i).P(a(end)-1:a(end),2) = centre_plate_2_AP;
						
						% Find period when foot comes onto second plate
						locCOP2On = find(data.fp_data.GRF_data(2).P(a,2) > 600) + a(1);
						
						interval = locCOP2On(1)-30:FP(1).Off(1);
						
						% Find rate at which slope is decreasing
						theta = data.fp_data.GRF_data(1).P(150:250,2);
						t = (1:1:101)';
						slope = mean(log(theta)./t);
						tau = -1/slope;
						
						% Create gap filling
						if interval(1) >= a(1)-30
							
							start_gap = data.fp_data.GRF_data(1).P(interval(1),2);
							finish_gap = data.fp_data.GRF_data(2).P(interval(end),2);
							spaces = (start_gap - finish_gap) / abs(tau);
							COP_gap_AP = linspace(start_gap, finish_gap, spaces);
							COP_gap_ML = ((data.fp_data.GRF_data(2).P(interval,1) + data.fp_data.GRF_data(1).P(interval,1))/2)';
							
							% Assign from first peak in COP to end of
							% stance
							
							% Determine the difference between created gap
							% and defined interval
							diffFromGap = length(interval) - length(COP_gap_AP);
							
							% If they are different then pad the interval
							% with the difference
							if diffFromGap > 0
								interval = floor(locCOP2On(1)-(30-(diffFromGap/2))):floor(FP(1).Off(1)-(diffFromGap/2));
								COP_gap_ML = ((data.fp_data.GRF_data(2).P(interval,1) + data.fp_data.GRF_data(1).P(interval,1))/2)';
							elseif diffFromGap < 0
								interval = floor(locCOP2On(1)-(30+(abs(diffFromGap)/2))):floor(FP(1).Off(1)+(abs(diffFromGap)/2));
								COP_gap_ML = ((data.fp_data.GRF_data(2).P(interval,1) + data.fp_data.GRF_data(1).P(interval,1))/2)';
							else
							end
							
							% Assign to the first force plate
							data.GRF.FP(1).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
							data.GRF.FP(1).P(interval,2) = COP_gap_AP';
							data.GRF.FP(1).P(interval,1) = COP_gap_ML';
							
						else
							disp('Interval is outside time when foot is on plate, discard this trial')
						end
					else
						% Old method of stitching
						data.GRF.FP(1).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
						data.GRF.FP(1).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
						data.GRF.FP(1).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
					end
				else % otherwise just assign the raw data
					data.GRF.FP(i).(assign_bodies{1}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP(i).(assign_bodies{1}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
					data.GRF.FP(i).(assign_bodies{1}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
				end
				
				% If force plate = 2 and it's the third force
				% assignment we know that it's the left body stance
			elseif i == 2 && j == 3
				if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
					data.GRF.FP(i).F(a,:) = lpfilter(data.fp_data.GRF_data(i).F(a,:),10,dt, 'damped');
					data.GRF.FP(i).M(a,:) = lpfilter(data.fp_data.GRF_data(i).M(a,:),10,dt, 'damped');
					data.GRF.FP(i).P(a,:) = lpfilter(data.fp_data.GRF_data(i).P(a,:),10,dt, 'damped');
					
					
					%                          data.GRF.FP(i).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
					%                          data.GRF.FP(i).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
					%                          data.GRF.FP(i).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
					
				else % otherwise just assign the raw data
					data.GRF.FP.(assign_bodies{i}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
					data.GRF.FP.(assign_bodies{i}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
					data.GRF.FP.(assign_bodies{i}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
				end
				
			else
				% Display that the force was not assigned
				disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
					' cannot be assigned to either body. Try adjusting the thresholds to improve detection.'])
			end
			
			% UNCOMMENT THIS TO INCLUDE FORCE ASSIGNMENT BASED ON
			% DISTANCE
			
			%         if ~isempty(aD)
			%             if length(aD) < 2
			%                 if filter_freq > 0 % filter the data if a filter frequency is defined (defaults at low pass 25Hz)
			%                     data.GRF.FP(i).(assign_bodies{aD}).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
			%                     data.GRF.FP(i).(assign_bodies{aD}).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
			%                     data.GRF.FP(i).(assign_bodies{aD}).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
			%                 else % otherwise just assign the raw data
			%                     data.GRF.FP(i).(assign_bodies{aD}).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
			%                     data.GRF.FP(i).(assign_bodies{aD}).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
			%                     data.GRF.FP(i).(assign_bodies{aD}).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
			%                 end
			%             else
			%                  % If more than one marker falls within the threshold then
			%                  % just use the opposite force assignment because feet are
			%                  % always alternating on plate
			%                     data.GRF.FP(i).(opposite_bodyAssigned).F(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).F(a,:));
			%                     data.GRF.FP(i).(opposite_bodyAssigned).M(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).M(a,:));
			%                     data.GRF.FP(i).(opposite_bodyAssigned).P(a,:) = matfiltfilt(dt,filter_freq,2,data.fp_data.GRF_data(i).P(a,:));
			%
			%                     % Inform the user that feet were close
			%                 disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
			%                     ' was assigned to a body, check these results to ensure accurate assignment.']);
			%             end
			%         else % if no marker falls within the threshold then don't assign and inform the user
			%                  disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
			%                     ' cannot be assigned to either body. Try adjusting the thresholds to improve detection.'...
			%                     'D = ' num2str(D) '.']);
			%         end
			%     end
		end
		
		% if there are no forces assigned to a body (i.e. it stays zero), then
		% remove this force assignment
		for b = 1:length(assign_bodies)
			if (sum(sum(data.GRF.FP(i).F)) == 0)
				data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'F');
				data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'M');
				data.GRF.FP(i).(assign_bodies{b}) = rmfield(data.GRF.FP(i).(assign_bodies{b}),'P');
			end
		end
	else
		disp(['There is no GRF data for force plate ', num2str(i), ', please check the trial data']);
		
	end
end



