%% RedoSecondCalibration 
% Written by Basilio Goncalves (2021) https://www.researchgate.net/profile/Basilio_Goncalves

function RedoSecondCalibration(Dir)

fp = filesep;
disp('Reseting folders for second calibration...')
if exist([Dir.CEINMScalibration fp 'firstCalibrationFiles'])
    % delete all files that are not in the folder 'firstCalibrationFiles'
    files = dir(Dir.CEINMScalibration);
    for i=3:length(files)
       if ~contains(files(i).name,'firstCalibrationFiles')
           delete([Dir.CEINMScalibration fp files(i).name])
       end
    end
    
    % copy first calibration files to the main calibration directory
    files = dir([Dir.CEINMScalibration fp 'firstCalibrationFiles']);
    for i=3:length(files)
        movefile([Dir.CEINMScalibration fp 'firstCalibrationFiles' fp files(i).name],[Dir.CEINMScalibration])
    end
    delete([Dir.CEINMScalibration fp 'firstCalibrationFiles'])
end

%% executions
if exist([Dir.CEINMSsimulations fp 'FirstExecution'])
    % delete all files that are not in the folder 'FirstExecution'
    files = dir(Dir.CEINMSsimulations);
    for i=3:length(files)
        if ~contains(files(i).name,'FirstExecution')
            if files(i).isdir ==1
                rmdir([Dir.CEINMSsimulations fp files(i).name],'s')
            else
                delete([Dir.CEINMSsimulations fp files(i).name])
            end
        end
    end
    
    % copy first execution files to the FirstExecution directory
    files = dir([Dir.CEINMSsimulations fp 'FirstExecution']);
    for i=3:length(files)
        movefile([Dir.CEINMSsimulations fp 'FirstExecution' fp files(i).name],[Dir.CEINMSsimulations])
    end
    rmdir([Dir.CEINMSsimulations fp 'FirstExecution'])
end