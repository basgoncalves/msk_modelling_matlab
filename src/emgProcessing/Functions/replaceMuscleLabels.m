function  replaceMuscleLabels(acq, nameIndex)
%Replace channel names with muscle labels consistent with CEINMS. Only
%input is the acquisition loaded using btk

% Create structure with new channel names. Channels skipped because they
% were dodgy have full channel names
newNames = {'TA', 'Channel2', 'MG', 'LG', 'Channel5', 'BF', 'VM', 'VL',...
     'RF', 'Sol', 'MH'};

% Run through loop and change channel names
     btkSetAnalogLabel(acq, nameIndex, newNames{nameIndex-12});   
     
% Check to see if analog labels were updated
% [analogs, analogsInfo] = btkGetAnalogs(acq);

end

