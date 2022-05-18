function mergeEmgMain(pname, c3dFiles, txtFiles, physFolderName)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Loop through all trials
for trial = 1:length(txtFiles)
     
     % Define input file/s
     inputc3d = c3dFiles(trial,1).name(1:end-4);
     txtFile = txtFiles(trial,1).name(1:end-4);
     
     if isempty(txtFile)
          
          % If no text file exists
          disp('no txt files exist for this trial');
          
     else
          
          cd(pname);
          % Ensure processing only occurs when .txt file
          % corresponds with .c3d file.
          if strcmp(inputc3d(1:end-10), txtFile) == 0
               
               % Find the correct c3d file to match txt file
               t = struct2cell(c3dFiles)';
               index = regexpi(t(:,1), txtFile);
               inputc3d = c3dFiles((find(not(cellfun('isempty', index)))),1).name(1:end-14);
               
               % Because trial names have _Processed at the end
               newInputc3d = inputc3d;
               
               % Check to see if they are now the same
               if strcmp(newInputc3d, txtFile) == 0
                    disp(['Text file (', txtFile, ') still does not match c3d File (', inputc3d, ')']);
                    disp('Please ensure name of txt file is consistent with pre-defined structure');
                    break
               else
                    % Run EMG analysis to insert .txt file EMG into c3d
                    emgAsciiAnalysis([newInputc3d, '_Processed.c3d'], [txtFile, '.txt'],...
                         physFolderName, pname);
               end
          else
               % If they are the same just run processing
               emgAsciiAnalysis([inputc3d, '.c3d'], [txtFile, '.txt'],...
                    physFolderName, pname);
          end
     end
end
end

