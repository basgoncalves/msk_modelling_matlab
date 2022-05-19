% Script to load c3d files and insert heel strike event. Then crop the
% trial based on the heel strike
clear;
clc;

%% Select one of the c3d files in the folder
[fname, pname] = uigetfile('*.c3d', 'Select c3d file');

% Set folder as that chosen above
c3dFile_folder = pname;
c3dFiles=dir([c3dFile_folder,'\*.c3d']);

% Make current folder same as above
cd(pname);

%% Loop through all of the trials
for t_trial = 1:length(c3dFiles)
     
     % Load the c3d file using btk
     c3dFile_name = c3dFiles(t_trial,1).name;
     acqLS = btkReadAcquisition([c3dFile_folder '\' c3dFile_name]);
     data = btk_loadc3d([c3dFile_folder '\' c3dFile_name]);
     
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
     
     %First ensure that the rightHS corresponds with first actual right HS
     %in trial
     addFrames = btkGetFirstFrame(acqLS);
     rightHS = rightHS + addFrames +3;
     
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
               filename = [c3dFile_name(:,1:14), num2str(ii), '.c3d'];
               btkWriteAcquisition(acq_newLS, filename);
          end
     end
     
     % Assign force to the feet and generate the .trc and .mot files
     for croppedTrials = 1:length(rightHS)-1
          %Load the new acquisition
          fileName = [fname(:,1:14), num2str(croppedTrials),'.c3d'];
          data1 = btk_loadc3d([pname, fileName], 5);
          %Choose force plate filter frequency
          data1.FilterFreq = 30;
          %Assign forces to a foot
          data1 = assign_forces(data1,{'RCAL','LCAL'},{'calcn_r','calcn_l'},[20, 0.25],data1.FilterFreq);
          %Create the .trc and .mot files
          dataFinal = btk_c3d2trc_treadmill(data1,'off');
     end
     cd ../
end
