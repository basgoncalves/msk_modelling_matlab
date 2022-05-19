function [data, force_data2] = btk_c3d2trc_treadmill_LS(varargin)
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
% Updated May 2016

%% load data
if nargin > 0
     if ~isstruct(varargin{1})
          % load C3d file
          file = varargin{1};
          if isempty(fileparts(file))
               pname = cd;
               if ispc
                    pname = [pname '\'];
               else pname = [pname '/'];
               end
               fname = file;
          else [pname, name, ext] = fileparts(file);
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
               else pname = [pname '/'];
               end
               fname = [name ext];
          else fname = data.marker_data.Filename;
          end
          
     end
     if length(varargin) < 2
          anim = 'on';
     else anim = varargin{2};
     end
else [fname, pname] = uigetfile('*.c3d', 'Select C3D file');
     % load the c3dfile
     data = btk_loadc3d([pname, fname], 10);
     anim = 'on';
end

%%
% if the mass, height and name aren't present then presribe - it is
% preferrable to have these defined in the data structure before running
% this function - btk_loadc3d should try and do this for vicon data
% if ~isfield(data,'Mass')
%      data.Mass = 75;
% end
%
% if ~isfield(data,'Height')
%      data.Height = 1750;
% end
%
% if ~isfield(data,'Name')
%      data.Name = 'NoName';
% end

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
     else btk_animate_markers(data.marker_data)
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
else p_sc = 1;
end

% go through each marker field and re-order from X Y Z to Y Z X
for i = 1:nmarkers
     data.marker_data.Markers.(markers{i}) =  [data.marker_data.Markers.(markers{i})(:,2)...
          data.marker_data.Markers.(markers{i})(:,3) data.marker_data.Markers.(markers{i})(:,1)]/p_sc;
end

%%
% now we need to make the headers for the column headings for the TRC file
% which are made up of the marker names and the XYZ for each marker

% first initialise the header with a column for the Frame # and the Time
% also initialise the format for the columns of data to be written to file
dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
format_text = '%i\t%2.4f\t';
% initialise the matrix that contains the data as a frame number and time row
data_out = [nframe; data.time'];

% now loop through each maker name and make marker name with 3 tabs for the
% first line and the X Y Z columns with the marker numnber on the second
% line all separated by tab delimeters
% each of the data columns (3 per marker) will be in floating format with a
% tab delimiter - also add to the data matrix
for i = 1:nmarkers
     dataheader1 = [dataheader1 markers{i} '\t\t\t'];
     dataheader2 = [dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t'...
          'Z' num2str(i) '\t'];
     format_text = [format_text '%f\t%f\t%f\t'];
     % add 3 rows of data for the X Y Z coordinates of the current marker
     % first check for NaN's and fill with a linear interpolant - warn the
     % user of the gaps
     clear m
     m = find(isnan(data.marker_data.Markers.(markers{i})((data.Start_Frame:data.End_Frame),1))>0);
     if ~isempty(m);
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
dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

disp('Writing trc file...')

%Output marker data to an OpenSim TRC file
indexName = regexp(fname(1:end-4), 'd\d*');
name = fname(1:indexName);

newfilename = strrep(fname,'c3d','trc');
newpathname = [strrep(pname, 'InputData', 'ElaboratedData'),...
     'dynamicElaborations', filesep, name];

mkdir(newpathname, fname(1:end-4));
%Create new folder to store .trc and .mot files
finalpathname = [newpathname, filesep, fname(1:end-4)];
mkdir(finalpathname);

cd(finalpathname);

%open the file
fid_1 = fopen([finalpathname , filesep, newfilename],'w');

% first write the header data
fprintf(fid_1,'PathFileType\t4\t(X/Y/Z)\t %s\n',newfilename);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', data.marker_data.Info.frequency, data.marker_data.Info.frequency, nrows, nmarkers, data.marker_data.Info.units.ALLMARKERS, data.marker_data.Info.frequency,data.Start_Frame,data.End_Frame);
fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% then write the output marker data
fprintf(fid_1, format_text,data_out);

% close the file
fclose(fid_1);

disp('Done.')

cd ..
%%
% Write motion file containing GRFs

disp('Writing grf.mot file...')

if isfield(data,'fp_data')
     
     Fp_change = data.fp_data.Info(1).frequency/data.marker_data.Info.frequency; % assume that all force plates are collected at the same frequency!!!
     
     % Changed this to start from frame 1, not from frame 10.
     %      fp_time = 1/data.marker_data.Info.frequency:1/data.fp_data.Info(1).frequency:(F*(data.End_Frame-data.Start_Frame+1))/data.fp_data.Info(1).frequency;
     
     fp_time1 = 0.001:1/data.fp_data.Info(1).frequency:(Fp_change*(data.End_Frame-data.Start_Frame+1))/data.fp_data.Info(1).frequency;
     
     % initialise force data matrix with the time array
     force_data_out = fp_time1';
     
     % Loop through the bodies and allocate forces
     for i = 1:2
          
          % rescale the GRF COP to meters if necessary
          data.fp_data.GRF_data(i).P =  data.fp_data.GRF_data(i).P/p_sc;
          % rescale the moments to meters as well, if necessary
          data.fp_data.GRF_data(i).M =  data.fp_data.GRF_data(i).M/p_sc;
          
          % do some cleaning of the COP before and after contact
          b = find(abs(diff(data.fp_data.GRF_data(i).P(:,2)))>0);
          if ~isempty(b)
               for j = 1:3
                    data.fp_data.GRF_data(i).P(1:b(1),j) = data.fp_data.GRF_data(i).P(b(1)+1,j);
                    data.fp_data.GRF_data(i).P(b(end):end,j) = data.fp_data.GRF_data(i).P(b(end)-1,j);
               end
          end
          
          
          bodies = {'calcn_r', 'calcn_l'};
          
          % define the period which we are analysing
          
          % Modified K to start from first frame and not start from first
          % frame * 10.
          K = (data.Start_Frame):1:(Fp_change*data.End_Frame);
          dt = 1/data.fp_data.Info(1).frequency;
          
          % add the force, COP and moment data for current plate to the force matrix
          % Needs to loop through both force plates
          for k = 1:2
               
               % reorder data so lab coordinate system to match that of the OpenSim
               % system
                if ~isempty(fieldnames(data.GRF.FP(k).(bodies{i})))
               data.GRF.FP(k).(bodies{i}).P =  [data.GRF.FP(k).(bodies{i}).P(:,2)/p_sc ...
                    data.GRF.FP(k).(bodies{i}).P(:,3)/p_sc data.GRF.FP(k).(bodies{i}).P(:,1)/p_sc];
               data.GRF.FP(k).(bodies{i}).F =  [data.GRF.FP(k).(bodies{i}).F(:,2) ...
                    data.GRF.FP(k).(bodies{i}).F(:,3) data.GRF.FP(k).(bodies{i}).F(:,1)];
               data.GRF.FP(k).(bodies{i}).M =  [data.GRF.FP(k).(bodies{i}).M(:,2) ...
                    data.GRF.FP(k).(bodies{i}).M(:,3) data.GRF.FP(k).(bodies{i}).M]/p_sc;
               
               % Check if moments have duplicate columns (for some reason
               % they do)
               check = iscolumn(data.GRF.FP(k).(bodies{i}).M(:,4));
               if check == 1
                    % Then delete
                    data.GRF.FP(k).(bodies{i}).M(:,4:5) = [];
               end
               
               % If plate one for either body then assign normally (i.e.,
               % concat horz).
               
               if k ==1
                    force_data_out = [force_data_out, data.GRF.FP(k).(bodies{i}).F(K,:)...
                         data.GRF.FP(k).(bodies{i}).P(K,:) data.GRF.FP(k).(bodies{i}).M(K,:)];
                    
                    % If plate two and right foot append on to end of FP 1 data
               elseif k == 2 && i == 1
                    
                    endFrameFP1 = find(data.GRF.FP(1).(bodies{i}).F(K,2) > 1);
                    startFrameFP2 = find(data.GRF.FP(2).(bodies{i}).F(K,2) > 1);
                    
                    difference = endFrameFP1(end) - startFrameFP2(1);
                    
                    startCropFrame = endFrameFP1(end) - (difference/2);
                    
                    % Stitch these forces onto those from Plate 1
                    force_data_out(startCropFrame:end, 2:10) = [data.GRF.FP(k).(bodies{i}).F(startCropFrame:end,:),...
                         data.GRF.FP(k).(bodies{i}).P(startCropFrame:end,:),...
                         data.GRF.FP(k).(bodies{i}).M(startCropFrame:end,:)];
                    
                    % If plate two and left foot append onto end of left
                    % foot data
               elseif k == 2 && i == 2
                    
                    % Same procedure for stitching - first define areas to
                    % stitch
                    
                    endFrameFP2x = find(data.GRF.FP(2).(bodies{i}).F(K(1):K(500),2) > 1);
                    endFrameFP2y = find(data.GRF.FP(2).(bodies{i}).F(500:end,2) > 35);
                    
                    % Condition statement to address if FP1 is empty for
                    % left foot.
                    if ~isempty(fieldnames(data.GRF.FP(1).(bodies{i})))
                    startFrameFP2end = find(data.GRF.FP(1).(bodies{i}).F(K,2) < 1);
                    else
                        startFrameFP2end = 1;
                    end
                    
                    % Determine difference between end of FP1 and start of
                    % FP2
                    if ~isempty(endFrameFP2y)
                    differenceFP2 = startFrameFP2end(end) - (endFrameFP2y(1) +500);
                    else
                         differenceFP2 = startFrameFP2end(end);
                    end
                    startCropFrame2 = startFrameFP2end(end) - (differenceFP2/2) -20;
                    
                    % Stitch these forces onto those from Plate 1 for end
                    % of capture
                    force_data_out(startCropFrame2:end, 11:19) =...
                         [data.GRF.FP(k).(bodies{i}).F(startCropFrame2:end,:),...
                         data.GRF.FP(k).(bodies{i}).P(startCropFrame2:end,:),...
                         data.GRF.FP(k).(bodies{i}).M(startCropFrame2:end,:)];
                    
                    % Stitch these forces onto those from Plate 1 for
                    % beginning of capture
                    force_data_out(endFrameFP2x(1):endFrameFP2x(end), 11:19) =...
                         [data.GRF.FP(k).(bodies{i}).F(endFrameFP2x(1):endFrameFP2x(end),:),...
                         data.GRF.FP(k).(bodies{i}).P(endFrameFP2x(1):endFrameFP2x(end),:),...
                         data.GRF.FP(k).(bodies{i}).M(endFrameFP2x(1):endFrameFP2x(end),:)];
                    
               else
                    disp('The FP difference is greater than 20, this means the FP stitching will not be correct');
                    uiwait
               end
               else
                   fprintf('GRF data does not exist for trial %s', fname); 
               end
          end
          
     end
     
     % Apply 10 Hz filter to smooth stiching out - don't want to filter the
     % COP here.
     force_data_out(:, 2:4) = matfiltfilt(dt,10,2, force_data_out(:, 2:4));
     force_data_out(:, 8:10) = matfiltfilt(dt,10,2, force_data_out(:, 8:10));
     force_data_out(:, 11:13) = matfiltfilt(dt,10,2, force_data_out(:, 11:13));
     force_data_out(:, 17:19) = matfiltfilt(dt,10,2, force_data_out(:, 17:19));
     
     % assign a value of zero to any NaNs
     force_data_out(logical(isnan(force_data_out))) = 0;
     
     % Re-arrange so data matches MOtoNMS convention
     force_data2 = force_data_out(:, 2:19);
     
     force_data2(:,7:12) = force_data_out(:,11:16);
     force_data2(:,13:15) = force_data_out(:,8:10);
     force_data2(:,16:18) = force_data_out(:,17:19);
     
     if any(isempty(fieldnames(data.GRF.FP(k).(bodies{i}))))
     
     % Specify new file name if there is missing data name so I know to
     % check data
     newfilename = [fname(1:end-4) '_grf_NFU.mot'];
     
     else
         % Otherwise name normally
         newfilename = [fname(1:end-4) '_grf.mot'];
     end
     
     % WRite the MOT file using MOtoNMS function
     writeMot_LS(force_data2 ,force_data_out(:,1), [finalpathname filesep newfilename]);
     
     cd ..
     
else disp('No force plate information available.')
end
end

