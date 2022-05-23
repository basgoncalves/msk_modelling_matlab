% check if muslce analysis exist

function [ExistStrength,ExistID,ExistMA] = checkMA (DirElaborated)

fp = filesep;
MA = [DirElaborated fp 'muscleAnalysis'];
[~,Subject] = fileparts(fileparts(DirElaborated));

%% Check Strength
files = dir([DirElaborated fp 'StrengthData']);

if length(files)<3
    ExistStrength = 0;
    disp(' ')
    fprintf('Strength data not done \n')

elseif contains('strenghtData.mat',{files.name}) && contains('Plot_Max_EMG-Isometrics.mat',{files.name})
    ExistStrength = 1;
    disp(' ')
    fprintf('Strength data analysis has been executed for %s \n', Subject)
    
end

%% Check ID
files = dir(strrep(MA,'muscleAnalysis','inverseKinematics'));

if length(files)<3
    ExistID = 0;
    disp(' ')
    fprintf('inverseKinematics not done \n')

    
elseif exist([files(3).folder fp files(3).name])== 7
    ExistID = 1;
    disp(' ')
    fprintf('inverseKinematics has been executed for %s \n', Subject)
    
end



%% Check ID
files = dir(strrep(MA,'muscleAnalysis','inverseDynamics'));

if length(files)<3
    ExistID = 0;
    disp(' ')
    fprintf('inverseDynamics not done \n')

    
elseif exist([files(3).folder fp files(3).name])== 7
    ExistID = 1;
    disp(' ')
    fprintf('inverseDynamics has been executed for %s \n', Subject)
    
end


%% Check MA
files = dir(MA);

if length(files)<3
    ExistMA = 0;
    disp(' ')
    fprintf('Muscle analysis not done \n')

elseif exist([files(3).folder fp files(3).name])== 7
    ExistMA = 1;
    disp(' ')
    fprintf('Muscle analysis has been executed for %s \n', Subject)
    
end

%% Check MA
files = dir(strrep(MA,'muscleAnalysis','residualReductionAnalysis'));

if length(files)<3
    ExistMA = 0;
    disp(' ')
    fprintf('residualReductionAnalysis not done \n')

elseif exist([files(3).folder fp files(3).name])== 7
    ExistMA = 1;
    disp(' ')
    fprintf('residualReductionAnalysis has been executed for %s \n', Subject)
    
end

%% Check CEINMS
DirCEINMS = [DirElaborated fp 'ceinms' fp 'execution' fp 'simulations'];
files = dir(DirCEINMS);

if length(files)<3
    
    disp(' ')
    fprintf('CEINMS not done \n')
    disp(' ')
    
elseif exist([files(3).folder fp files(3).name])== 7 %&& length(files)==length(dir(MA))
    
    disp(' ')
    fprintf('CEINMS simulations have been executed for %s \n', Subject)
    disp(' ')
    
end