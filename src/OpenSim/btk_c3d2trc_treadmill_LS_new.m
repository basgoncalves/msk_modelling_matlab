function [data, force_dataMoto] = btk_c3d2trc_treadmill_LS_new(varargin)
% function btk_c3d2trc_treadmill(file) OR
% function btk_c3d2trc_treadmill(data)
%
% Function to convert data from a C3D file into the TRC and MOT file
% formats for OpenSim when using an AMTI treadmill, where the force
% assignments need to be adjusted to create the GRF mot file.
%
% INPUT -   file - the C3D file path that you wish to load (leave blank to
%               choose from a dialog box) OR
%           data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m
%           anim - animate 'on' or 'off' (default - 'on')
%           croppedTrialNum - number of loop used to name the output file
%           folder
%
% OUTPUT -  data - structure containing the relevant data from the c3dfile
%                  Creates the TRC file and _grf.MOT file for OpenSim
%
% example - data = btk_c3dtrc('filein.c3d','off');
%           data = btk_c3dtrc(data,'on');
%
% Written by Glen Lichtwark (University of Queensland)
% Updated September 2012

% Modified by Gavin Lenton for DST Group load sharing project
% Updated July 2016

%% load data
if nargin > 0
    if ~isstruct(varargin{1})
        % load C3d file
        file = varargin{1};
        if isempty(fileparts(file))
            pname = cd;
            if ispc
                pname = [pname '\'];
            else
                pname = [pname '/'];
            end
            fname = file;
        else
            [pname, name, ext] = fileparts(file);
            fname = [name ext];
        end
        % load the c3dfile
        data = btk_loadc3d([pname, fname], 10);
        
    else
        data = varargin{1};
        if ~isfield(data,'marker_data')
            error('Please ensure that the following field is included in structure - marker_data. Please use btk_loadc3d for correct outputs');
        end
        if isfield(data,'marker_data')
            [pname, name, ext] = fileparts(data.marker_data.Filename);
            if ispc
                pname = [pname '\'];
            else
                pname = [pname '/'];
            end
            fname = [name ext];
        else
            fname = data.marker_data.Filename;
        end
        
    end
    if length(varargin) < 2
        anim = 'on';
    else
        anim = varargin{2};
    end
else
    [fname, pname] = uigetfile('*.c3d', 'Select C3D file');
    % load the c3dfile
    data = btk_loadc3d([pname, fname], 5);
    anim = 'on';
end

%% define the start and end frame for analysis as first and last frame unless
% this has already been done to change the analysed frames
if ~isfield(data,'Start_Frame')
    data.Start_Frame = 1;
    data.End_Frame = data.marker_data.Info.NumFrames;
end

%%
% define some parameters
nrows = data.End_Frame-data.Start_Frame+1;
nmarkers = length(fieldnames(data.marker_data.Markers));

data.time = (1/data.marker_data.Info.frequency:1/data.marker_data.Info.frequency:(data.End_Frame-data.Start_Frame+1)/data.marker_data.Info.frequency)';

nframe = 1:nrows;

% anim the trial if animation = on
if strcmp(anim,'on')
    data.marker_data.First_Frame = data.Start_Frame;
    data.marker_data.Last_Frame = data.End_Frame;
    if isfield(data,'fp_data')
        btk_animate_markers(data.marker_data, data.fp_data, 5)
    else
        btk_animate_markers(data.marker_data)
    end
end

%%
% we need to reorder the lab coordinate system to match that of the OpenSim
% system --> SKIP THIS STEP IF LAB COORDINATE SYSTEM IS SAME AS MODEL
% SYSTEM
markers = fieldnames(data.marker_data.Markers); % get markers names

if strcmp(data.marker_data.Info.units.ALLMARKERS,'mm')
    p_sc = 1000;
    data.marker_data.Info.units.ALLMARKERS = 'm';
else
    p_sc = 1;
end

% go through each marker field and re-order from X Y Z to Y Z X
for i = 1:nmarkers
    data.marker_data.Markers.(markers{i}) =  [data.marker_data.Markers.(markers{i})(:,2)...
        data.marker_data.Markers.(markers{i})(:,3) data.marker_data.Markers.(markers{i})(:,1)]/p_sc;
end

%% Write trc file containing marker data

% initialise the matrix that contains the data as a frame number and time row
data_out = [nframe; data.time'];

% each of the data columns (3 per marker) will be in floating format with a
% tab delimiter - also add to the data matrix
for i = 1:nmarkers
    
    % add 3 rows of data for the X Y Z coordinates of the current marker
    % first check for NaN's and fill with a linear interpolant - warn the
    % user of the gaps
    clear m
    m = find(isnan(data.marker_data.Markers.(markers{i})((data.Start_Frame:data.End_Frame),1))>0);
    if ~isempty(m)
        clear t d
        disp(['Warning -' markers{i} ' data missing in parts. Frames ' num2str(m(1)) '-'  num2str(m(end))])
        t = time;
        t(m) = [];
        d = data.marker_data.Markers.(markers{i})((data.Start_Frame:data.End_Frame),:);
        d(m,:) = [];
        data.marker_data.Markers.(markers{i})((data.Start_Frame:data.End_Frame),:) = interp1(t,d,time,'linear','extrap');
    end
    data_out = [data_out; data.marker_data.Markers.(markers{i})((data.Start_Frame:data.End_Frame),:)'];
end

% Assign marker info to markersData
markersData = data_out';

% Apply filter
data_out_filtered = zeros(size(markersData));

% Sampling freq
Fs = 1/data.marker_data.Info.frequency;

% Filter freq
Fc = 10;

% Apply 2nd order Butterworth filt @ 8 Hz.
for col = 3:size(data_out,1)
    data_out_filtered(:,col) = lpfilter(markersData(:,col),Fc,Fs, 'damped');
    
    markersData(:,col) = data_out_filtered(:,col);
end

%% Define path and file names
% indexName = regexp(fname(1:end-4), 'd\d*');
fileNameTRC = [fname(1:end-4), '.trc'];
fileNameGRF = regexprep(fileNameTRC, '.trc', '_grf.mot');

% Define path name to new folder
% newpathname = [strrep(pname, 'InputData', 'ElaboratedData'),...
% 	'dynamicElaborations', filesep, fileNameTRC(1:indexName)];
newpathname = [strrep(pname, 'InputData', 'ElaboratedData'),...
    'dynamicElaborations'];

% Final path name to store .trc and .mot files
finalpathname = [newpathname, filesep, fileNameTRC(1:end-4)];

% Add folder for the condition and walking speed in session
if ~exist(finalpathname, 'dir')
    mkdir(finalpathname);
end

fullFileNameTRC = [finalpathname filesep fileNameTRC];

% Marker labels names
MLabels = markers;

% Write the trc file
writetrc_LS(markersData,MLabels,data.marker_data.Info.frequency,fullFileNameTRC);

%% Write motion file containing GRFs

% Specify progression direction - this will change how we treat COP data
progDir = varargin{3};

if isfield(data,'fp_data')
    
    dt = 1/data.fp_data.Info(1).frequency;
    
    Fp_change = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; % assume that all force plates are collected at the same frequency!!!

    % Changed this to start from frame 1, not from frame 10.
    fp_time = 1/data.marker_data.Info.frequency:dt:(Fp_change*(data.End_Frame-data.Start_Frame+1))/data.fp_data.Info(1).frequency;
    
%     fp_time1 = 1/data.fp_data.Info(1).frequency:1/data.fp_data.Info(1).frequency:(Fp_change*(data.End_Frame-data.Start_Frame+1))/data.fp_data.Info(1).frequency;
    
    % initialise force data matrix with the time array
    force_data_out = fp_time';
    
    % add the force, COP and moment data for current plate to the force matrix
    % Needs to loop through both force plates
    for i = 1:2
        
        % 		% rescale the GRF COP to meters if necessary
        % 		data.GRF.FP(i).P =  data.GRF.FP(i).P/p_sc;
        % 		% rescale the moments to meters as well, if necessary
        % 		data.fp_data.GRF_data(i).M =  data.fp_data.GRF_data(i).M/p_sc;
      
        
        % Define the period which we are analysing
        
        % Modified K to start from first frame and not start from first
        % frame * 10.
        K = 1:1:(Fp_change*(data.End_Frame-1)+1);
        
        % reorder data so lab coordinate system to match that of the OpenSim
        % system
        if ~isempty(fieldnames(data.GRF.FP(i)))
            data.GRF.FP(i).P =  [data.GRF.FP(i).P(:,2)/p_sc ...
                data.GRF.FP(i).P(:,3)/p_sc data.GRF.FP(i).P(:,1)/p_sc];
            data.GRF.FP(i).F =  [data.GRF.FP(i).F(:,2) ...
                data.GRF.FP(i).F(:,3) data.GRF.FP(i).F(:,1)];
            data.GRF.FP(i).M =  [data.GRF.FP(i).M(:,2) ...
                data.GRF.FP(i).M(:,3) data.GRF.FP(i).M(:,1)]/p_sc;
            
            % If plate one then it's the first foot data
            
            if i == 1
                force_data_out = [force_data_out, data.GRF.FP(i).F(K,:)...
                    data.GRF.FP(i).P(K,:) data.GRF.FP(i).M(K,:)];
                
                % If plate two it's the second foot data
            elseif i == 2
                
                force_data_out = [force_data_out, data.GRF.FP(i).F(K,:)...
                    data.GRF.FP(i).P(K,:) data.GRF.FP(i).M(K,:)];
            else
                fprintf('GRF data does not exist for trial %s', fname);
            end
            
        end
        
    end
    
    % Find period when foot comes onto second plate
    locCOP2On = data.FP(2).On(2);
    locCOP1Off = data.FP(1).Off(1);
    timeBeforeTransition = locCOP2On(1)-50; % If COP isn't super smooth there is scope to increase time before transition or time after transition
    
    % Define length of interval where we want to correct COP
    % - this corresponds to the transition of the stance foot from one plate to another
    interval = timeBeforeTransition:locCOP2On+100;
    % 	interval = timeBeforeTransition:data.FP(1).Off(1);
    
    leg = varargin{4}; % Get name of the leg
    
    % Get name of markers on the foot
    markersNames = fieldnames(data.marker_data.Markers);
    
    % Define foot marker names based on test leg
    if contains(leg, 'R') || contains(leg, 'r')
        footMarkers = sort(markersNames(contains(markersNames, 'RMT') | contains(markersNames, 'RCAL'))); % Gets the foot markers
        footmarkerCalc = footMarkers{1}; footmarker1 = footMarkers{2}; footmarker5 = footMarkers{3};
        
    elseif contains(leg, 'L') || contains(leg, 'l')
        footMarkers = sort(markersNames(contains(markersNames, 'LMT') | contains(markersNames, 'LCAL'))); % Gets the foot markers
        footmarkerCalc = footMarkers{1}; footmarker1 = footMarkers{2}; footmarker5 = footMarkers{3};
    else
        error('User did not specify test leg');
    end
    
    % Use mean of foot marker positions to get GRF COP values
    % Get mean of toe markers, then get mean of that with Calc marker
    filler_data_x_toes = mean([data.marker_data.Markers.(footmarker5)(:,1), data.marker_data.Markers.(footmarker1)(:,1)],2);
    filler_data_x_heel = data.marker_data.Markers.(footmarkerCalc)(:,1);
    filler_data_x = mean([filler_data_x_heel, filler_data_x_toes],2);
    filler_data_z_toes = mean([data.marker_data.Markers.(footmarker5)(:,3), data.marker_data.Markers.(footmarker1)(:,3)],2);
    filler_data_z_heel = data.marker_data.Markers.(footmarkerCalc)(:,3);
    filler_data_z = mean([filler_data_z_heel, filler_data_z_toes],2);
    
    % Resample marker data to freq of force data
    timeVecTrial = fp_time';
    timeVec = data.time;
    filler_data2_x = pchip(timeVec, filler_data_x, timeVecTrial);
    filler_data2_z = pchip(timeVec, filler_data_z, timeVecTrial);
    filler_data2_x_toes = pchip(timeVec, filler_data_x_toes, timeVecTrial);
    filler_data2_z_toes = pchip(timeVec, filler_data_z_toes, timeVecTrial);
    filler_data2_x_heel = pchip(timeVec, filler_data_x_heel, timeVecTrial);
    filler_data2_z_heel = pchip(timeVec, filler_data_z_heel, timeVecTrial);
    
    % do some cleaning of the COP before contact
    r = find(force_data_out(:,3)>0);
    
    % Define interval to fix COP at heel strike.
    intervalAPFix = locCOP2On-50;
    intervalMLFix = round(locCOP1Off/10);
    
    % Progression direction is x-axis
    if progDir == 1
             
        % Make frames after contact consistent(closer to heel) - because of noise in A/P
        force_data_out(r(1):r(1)+intervalAPFix,7) = (mean([force_data_out(r(1):r(1)+intervalAPFix,7),...
            filler_data2_z(r(1):r(1)+intervalAPFix,1)],2) +...
            filler_data2_z_heel(r(1):r(1)+intervalAPFix,1))/2;
        force_data_out(r(1):r(1)+intervalMLFix,5) = (mean([force_data_out(r(1):r(1)+intervalMLFix,5),...
            filler_data2_x(r(1):r(1)+intervalMLFix,1)],2) +...
            filler_data2_x_heel(r(1):r(1)+intervalMLFix,1))/2;
        
        % Assign to the first force plate
        force_data_out(interval,7) = mean([force_data_out(interval,7), filler_data2_z(interval)],2);
        
        %         % Fix AP force at heel-strike because there are large errors due
        %         % to noise
        A = lpfilter(force_data_out(:,4), 10, dt, 'damped');
        %         A(1:data.FP(1).On(1),1) = 0;
        dd = find(A(:,1)<0); % Find when AP value are below 1 initially because it means it's the noise at foot contact
        force_data_out(1:dd(1),4) = abs(A(1:dd(1)))*-1;
        
    elseif progDir == 2 % Progression direction is y-axis
       
        % Make frames after contact consistent(closer to heel) - because of noise in A/P
        force_data_out(r(1):r(1)+intervalAPFix,5) = (mean([force_data_out(r(1):r(1)+intervalAPFix,5),...
            filler_data2_x(r(1):r(1)+intervalAPFix,1)],2) +...
            filler_data2_x_heel(r(1):r(1)+intervalAPFix,1))/2;
        force_data_out(r(1):r(1)+intervalMLFix,7) = (mean([force_data_out(r(1):r(1)+intervalMLFix,7),...
            filler_data2_z(r(1):r(1)+intervalMLFix,1)],2) +...
            filler_data2_z_heel(r(1):r(1)+intervalMLFix,1))/2;
        
        % Assign to the first force plate
        force_data_out(interval,5) = (mean([force_data_out(interval,5), filler_data2_x(interval)],2)+...
            filler_data2_x(interval))/2;
        
%         % Fix AP force at heel-strike because there are large errors due
%         % to noise
        A = lpfilter(force_data_out(:,2), 10, dt, 'damped');
%         A(1:data.FP(1).On(1),1) = 0;
        dd = find(A(:,1)<0);
        force_data_out(1:dd(1),2) = abs(A(1:dd(1)))*-1;
        
    else
        disp('Have not added functionality when progression direction is the z-axis')
    end
    
    % Clean up COP before and after contact - this would be different columns for the leg
    % striking the force plate second (e.g., j would start at 14 and end at 16)
    for j = 5:7
        force_data_out(1:r(1),j) = force_data_out(r(1),j); % Values from first frame to first actual data frame are the same
        force_data_out(r(end):end,j) = force_data_out(r(end),j); %Values from last data frame to end frame are the same
    end
    
    % Find if there are any zeros in between data - this occurs at toe-off sometimes
    % because of treadmill noise
    t = diff(force_data_out(:,3));
    tt = t(r(1):r(end));
    
    % If there are any gaps find them and use it to index later
    if any(tt == 0)
        firstIndex = find(tt == 0); value = tt((firstIndex(firstIndex>500))-1) *-1;
        % If index or gap occurs early then we don't worry
        if ~isempty(value)
            endIndex = find(force_data_out(:,3) == value(1));
        else
             endIndex = r(end);
        end
    else
        endIndex = r(end);
    end
    
    %% FILTERING - currently at 8 Hz butterworth filt to match marker data
    
    force_data_filtered = zeros(size(force_data_out));
    
    for col = 2:size(force_data_out,2)
        force_data_filtered(:,col) = lpfilter(force_data_out(:,col),Fc,dt, 'damped');
        force_data_filtered(1:r(1)-2,col) = 0; % Set values when foot is not on plate to zero
        force_data_filtered(endIndex+1:end,col) = 0; % Set values after toe-off to zero
    end
      
    % Fix if there are issues with COP
    f = find(abs(diff(force_data_out(:,3)))>0);
    
    % Uses minimum of RMT1/5 markers to finish on 'toes'
    force_data_filtered(f(end)-20:f(end),5) = (force_data_filtered(f(end)-20:f(end),5) + min(filler_data2_x_toes))/2;
    force_data_filtered(f(end)-20:f(end),7) = (force_data_filtered(f(end)-20:f(end),7) + min(filler_data2_z_toes))/2;
    
    % M/L and A/P free moments equal to zero as they contribute negligibly
    % to ID
    force_data_filtered(:, [8,10]) = 0;
    
    % assign a value of zero to any NaNs
    force_data_filtered(logical(isnan(force_data_filtered))) = 0;
    
    % Re-arrange so data matches MOtoNMS convention
    force_dataMoto = force_data_filtered(:, 2:19);
    
    force_dataMoto(:,7:12) = force_data_filtered(:,11:16);
    force_dataMoto(:,13:15) = force_data_filtered(:,8:10);
    force_dataMoto(:,16:18) = force_data_filtered(:,17:19);
    
    %% Print MOT
    
    % Find when peaks occur to determine if Force is dodgy - looking for
    % two prominent vertical GRF peaks
    [pks, loc1] = findpeaks(force_data_filtered(:,3), 'MinPeakDistance', 200, 'MinPeakProminence', 300);
    
    if any(isempty(fieldnames(data.GRF.FP(i))))
        % Specify new file name if there is missing data name so I know to
        % check data
        disp('Trial is missing data, GRFs not printed')
        
        % Checker to see if vertical GRF peaks are too close or if the first peak occurs too late
    elseif any(force_dataMoto(loc1(1):loc1(end), 2) < 200) || loc1(1) > 300
        
        % If there is issue with force assignment then print with modified
        % name
        disp('Trial has dodgy data, printing with modified filename');
        fullFileNameGRF = [finalpathname, filesep, fileNameGRF(1:end-4), '_NFU.mot'];
        % Write the MOT file using MOtoNMS function
        writeMot_LS(force_dataMoto ,force_data_out(:,1), fullFileNameGRF);
        
    else
        
        % Otherwise name and print normally
        fullFileNameGRF = [finalpathname, filesep, fileNameGRF];
        
        % Write the MOT file using MOtoNMS function
        writeMot_LS(force_dataMoto ,force_data_out(:,1), fullFileNameGRF);
    end
    
else
    disp('Force plate data incorrect for rear plate so not printing mot file')
    force_dataMoto = 1;
    
end
