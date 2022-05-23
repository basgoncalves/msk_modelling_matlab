% Script to load c3d files and insert heel strike event. Then crop the
% trial based on the heel strike

% Open processed c3d file
[fname, pname] = uigetfile('*.c3d', 'Select C3D file');

% load and convert to matlab structure 
data = btk_loadc3d([pname, fname], 10);

% Define properties for assigning forces to foot
data.FilterFreq = 25;  %Butterworth filter frequency

% Threshold - an array of length 2 e.g. [30 0.15] representing
% the 1) threshold force to use to determine a force event (default 30)
% and 2) the mean distance from the marker to the COP
% that is used to assess a positive assignment (in meters -
% defaults to 0.2m)

% Assign forces to a foot
data = assign_forces(data,{'RCAL','LCAL'},{'calcn_r','calcn_l'},[20, 0.25],data.FilterFreq);

% Create the .trc and .mot files for cropping
data = btk_c3d2trc(data,'off');

%% Select one of the trc files in the folder
[fname, pname] = uigetfile('*.trc', 'Select trc file');

% Set folder as that chosen above
trcFile_folder = pname;
trcFiles=dir([trcFile_folder,'\*.trc']);
motFiles=dir([trcFile_folder,'\*.mot']);

% Make current folder same as above
cd(pname);

%% Loop through all of the trials
for t_trial = 1:length(trcFiles)
     
     % Load the trc file using btk
     trcFile_name = trcFiles(t_trial,1).name;
     acqLS = btkReadAcquisition([trcFile_folder '\' trcFile_name]);
     data = btk_loadc3d([trcFile_folder '\' trcFile_name]);
     
     % Check if events are in the file
     [events, eventsInfo] = btkGetEvents(acqLS);
     if isempty(fieldnames(events)) == 0
        disp('Events already exist in this file')
     else
          % If not, first find when heel strike is occurring 
          [rightHS, leftHS] = findHeelStrike(data);
     end
     
     
     % I want to create a cloned acquisition, then extract each gait cycle
     % and create a new c3d file of that cropped acquisition
     
     % Right side data first
     for ii = 1:length(rightHS)-1
     % Clone acquisition
     acq_newLS = btkCloneAcquisition(acqLS);
     % Insert new events into clone
     insertGaitEvents(acq_newLS, rightHS, leftHS)
     
     % Check if events were actually appended
     [times, labels, descriptions, ids] = btkGetEventsValues(acq_newLS);
     if isempty(times)
     uiwait(msgbox('Warning: Events do not exist'));
     else
          
     % Crop the new acquisition based on time between heel strikes
     numFrames = rightHS(ii+1,:) - rightHS(ii,:);
     btkCropAcquisition(acq_newLS, rightHS(ii), numFrames);
     
     % Write the new acquisition
     filename = [trcFile_name(:,1:14), num2str(ii), '.trc'];
     btkWriteAcquisition(acq_newLS, filename);     
         
     end
     
     end
     
end