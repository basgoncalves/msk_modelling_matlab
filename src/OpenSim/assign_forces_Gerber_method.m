function dataOutput = assign_forces_Gerber_method(data,thresh, progDir)
% function data = assign_forces(data,assign_markers,assign_bodies, thresh)
%
% Function to assign any recorded forces to a specific body based on the
% position of a nominated marker attached to the body.
%
% INPUT -   data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m as well as a filename string

%           thresh - an array of length 2 e.g. [30 0.15] representing
%               1) threshold force to use to determine a force event (default 30)
%               and 2) the mean distance from the marker to the COP
%               that is used to assess a positive assignment (in meters -
%               defaults to 0.2m)
%
% OUTPUT -  data - structure containing the relevant data
%
% Written by Glen Lichtwark (University of Queensland)
% Updated September 2014

% Updated June 2016 by Gavin Lenton (Griffith University) for compability with load
% sharing project data.

% define the ratio of force sampling frequency to marker sampling frequency
F = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; %assume same sampling frequency on all plates!!!
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
    
    % Find the zero value of the first force plate - most occuring value
    if i == 1
        zeroValue = mode(data.fp_data.GRF_data(i).F(:,3));
        % If it's stupid and becomes a NaN then just make it zero
        if isnan(zeroValue)
            zeroValue = 0;
        end
        
        % subtract this value from the data
        data.fp_data.GRF_data(i).F(:,3) = data.fp_data.GRF_data(i).F(:,3) - zeroValue;
    end
    
    % filter the force and determine when the foot is in contact with the
    % ground - this is not the same filtering as is done on the final data
    % and is required to be able to determine the contact periods
    Fv = lpfilter(data.fp_data.GRF_data(i).F(:,3), 20,dt, 'damped');
    
    if (max(Fv)-min(Fv))>400
        Fv = Fv-median(Fv(Fv<(min(Fv)+thresh(1))));
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
        dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.025);
        
        % If dnt is empty then try reducing gap length to 0.015
        if isempty(dnt)
            dnt = find(diff(nt)>data.fp_data.Info(1).frequency*0.005);
        end
        
        % Create on and off events
        on_i = [nt(1); nt(dnt+1)];
        off_i = [nt(dnt); nt(end)];
        
        % Check parameters for inconsistencies.
        for event = 1:length(on_i)
            if event == 1
                if (off_i(event)-on_i(event)) < 5
                    off_i(event) = [];
                    on_i(event) = [];
                    break
                end
            elseif (off_i(event)-on_i(event)) < 20
                off_i(event) = [];
                on_i(event) = [];
                break
            end
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
            disp('Threshold not high enough to detect multiple events, increasing to 30N')
            
            [on_i, off_i] = detectNewForcePlateEvents(Fv, data, i);
            
        elseif i == 2 && length(on_i) ~= 3
            disp('Not enough events on FP2, modifying parameters')
            
            [on_i, off_i] = detectNewForcePlateEvents(Fv, data, i);
        end
        
        % Check parameters for inconsistencies.
        for event = 1:length(on_i)
            if event == 1
                if (off_i(event)-on_i(event)) < 7
                    off_i(event) = [];
                    on_i(event) = [];
                end
                break
            elseif (off_i(event)-on_i(event)) < 80
                off_i(event) = [];
                on_i(event) = [];
                break
            end
        end
        
        ns = find((off_i - on_i) < data.fp_data.Info(1).frequency*0.010);
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
            
            % FP 1 = First foot heel-strike/Second foot heel-strike
            % FP 2 = Second foot toe-off/First foot toe-off/Second foot
            % toe-off
            
            % IF force plate = first (e.g., 1) and it's the first force assignment the
            % force should always go to first body
            if i == 1 && j == 1
                
                if length(on_i) == 2
                    % 					if ~isempty(dnt)
                    % 						% Just assign moments
                    % 						data.GRF.FP(i).M(a(1):dnt(end),:) = data.fp_data.GRF_data(i).M(a(1):dnt(end),:);
                    % 					end
                    
                    % Get zero values for COP
                    zeroX = mode(data.fp_data.GRF_data(i).P(:,1));
                    zeroY = mode(data.fp_data.GRF_data(i).P(:,2));
                    
                    % For A/P COP we want to clean up the begining (values should not be above
                    % the 'zero' value - this only applied to the front treadmill plate
                    if progDir == 1
                        %AP - Progression direction is x-axis
                        COPt = data.fp_data.GRF_data(i).P(:,1) > zeroX;
                        data.fp_data.GRF_data(i).P(COPt,1) = zeroX;
                    elseif progDir == 2
                        %AP - Progression direction is y-axis
                        COPt = data.fp_data.GRF_data(i).P(:,2) > zeroY;
                        data.fp_data.GRF_data(i).P(COPt,2) = zeroY;
                    end
                    
                else
                    disp('Force plate one did not assign force values correctly');
                    break
                end
                
                % If force plate  = 1 and it's the second force assignment we always
                % know it will be for the second body.
            elseif i == 1 && j == 2
                
                data.GRF.FP(j).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
                data.GRF.FP(j).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
                data.GRF.FP(j).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
                
                % If force plate = 2 and it's the first force
                % assignment we know that it's the second body toe-off
            elseif i == 2 && j == 1
                
                data.GRF.FP(i).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
                data.GRF.FP(i).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
                data.GRF.FP(i).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
                
                % If force plate = 2 and it's the second force
                % assignment we know that it's the first body late
                % stance
            elseif i == 2 && j == 2
                
                if length(on_i) == 3
                    
                else
                    disp('Force plate two did not assign force values correctly');
                    break
                end
                
                % If force plate = 2 and it's the third force then it's
                % non stance leg
            elseif i == 2 && j == 3
                
                data.GRF.FP(i).F(a,:) = data.fp_data.GRF_data(i).F(a,:);
                data.GRF.FP(i).M(a,:) = data.fp_data.GRF_data(i).M(a,:);
                data.GRF.FP(i).P(a,:) = data.fp_data.GRF_data(i).P(a,:);
                
            else
                % Display that the force was not assigned
                disp(['Force event ' num2str(j) ' on force plate ' num2str(i) ...
                    ' cannot be assigned. Try adjusting the thresholds to improve detection.'])
            end
        end
        
    else
        disp(['There is no GRF data for force plate ', num2str(i), ', please check the trial data']);
        
    end
end

if ~isempty(nt)
    data.FP = FP;
    % Combine data from the force plates here provided the events were
    % assigned correctly
    if length(FP(1).On) == 2 && length(FP(2).On) == 3
        dataOutput = combineForcePlates(data, FP, progDir);
    else
        disp('Forces were not assigned correctly for this trial, not assigning forces to data')
        dataOutput = data;
    end
else
    disp('No FP data for this trial, not assigning forces to data')
    dataOutput = data;
end
end