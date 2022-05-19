function replaceAnalogLabels(pname)
%Replace analog EMG labels so they are consistent with CEINMS
%   Inpout working directory with c3d files and change the labels in the
%   sessionData files generated from MOtoNMS so that they are consistent with CEINMS.

     % Navigate to sessionData folder and select AnalogDataLabels file
     cd([strrep(pname, 'InputData', 'ElaboratedData'), filesep, 'sessionData'])
     matFileName = 'AnalogDataLabels.mat';
     load(matFileName);
     
     % Create cell array with new channel names and file names
     newNames = {'TA', 'Channel2', 'MG', 'LG', 'Channel5', 'BF', 'VM', 'VL',...
          'RF', 'Sol', 'MH'};
     
     % Load names of trials to change channel names
     load('trialsName.mat');
     
     % Replace analog labels in sessionData first
     AnalogDataLabels(1:11) = newNames(1:11);
     save('AnalogDataLabels.mat', 'AnalogDataLabels');
     
     % Then individual trials
     for files = 1:length(trialsName)
          cd(trialsName{files});  
          % Only run this if analogData exists
          if exist('AnalogData.mat', 'var')
               load('AnalogData.mat')
               AnalogData.Labels(1:11) = newNames(1:11);
               % Save file
               save('AnalogData.mat', 'AnalogData');
          end
          cd ..
     end

end

