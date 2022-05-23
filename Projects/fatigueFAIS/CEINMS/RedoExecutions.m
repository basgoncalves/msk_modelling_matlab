%% RedoSecondCalibration 
% Written by Basilio Goncalves (2021) https://www.researchgate.net/profile/Basilio_Goncalves

function RedoExecutions(Dir)

fp = filesep;
disp('Reseting CEINMS simulations folder ...')

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

