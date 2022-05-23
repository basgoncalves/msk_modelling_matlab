%% Description
% Goncalves, BM (2018)
%   1. Calculates the maximum Torque for each trial
%   2. Converts Torque from Biodex moment arms to Rig Moment Arms
%   3. Plots the Maximum Torque for each condition (same file name only
%   with diffeent number
%   4. Plots the indiviudal torque values
%   5. Saves all trials
%
%-------------------------------------------------------------------------
%INPUT
%   subjectDir = 
%
%-------------------------------------------------------------------------
%OUTPUT
%   TorqueDataAll = struct with the torque values for each subject for each
%   condition
%
%
%--------------------------------------------------------------------------

function convertToCSV (subjectDir)

cd(subjectDir);

indivData = dir;

% get the code of the subject
lastDash = strfind(indivData(1).folder,'\');                                    % find all the backslashes in the name of the folder
lastDash = lastDash (end);                                                  % get the last backslash, prior to the folder name
subject = indivData(1).folder (lastDash+1:end);

if contains(subject,'day1')
    day = 0;
elseif contains(subject,'day2')
    day = 1;
end
% filter settings
fs = 2000;                   % sample frequency
Fnyq = fs/2;
PB = 6;                     % passband frequency

cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
indivData = dir;
indivData (1:2)=[];                         % delete the two first file that are artifact
CSV =[];
for i = 1: length (indivData)                               % run trhough all the files
    
     
    Underscore = strfind(indivData(i).name,'_');                                    % find all the underscore in the name of the folder
    if exist (indivData(i).name,'dir')==7 && isempty (Underscore)==0                % if it is a folder AND the name contains underscore
        Underscore = Underscore (1);                                                    % get the first underscore, prior to the folder name
    elseif exist (indivData(i).name,'dir')==7 && isempty (Underscore)           % if it is a folder and UNDESCORE is EMPTY
        Underscore = 2;                                                                 % use the whole name of the folder
    else                                                                %if not
        continue                                                         
    end
     fileName = sprintf...
        ('%s\\%s\\AnalogData.mat',...
        indivData(i).folder, indivData(i).name);                     %find the mat file called AnalogData in each trial folder
    
    load(fileName);  
     %% get the index of Rig and Biodex
    for ii = 1: length (AnalogData.Labels)                   % loop thorugh the labels of the mat file
        if contains (AnalogData.Labels{ii},'Torque')          % find Torque = Biodex
            idBiodex = ii;
        elseif contains (AnalogData.Labels{ii},'Force')       % find Force = Rig
            idRig = ii;
        end
    end
 
    %% Filter force data  
    if startsWith(indivData(i).name,'B_')                        % if biodex trials
        ForceDataRaw =AnalogData.RawData(:,idBiodex);  
        [b,a] = butter(2,PB*1.25/Fnyq,'low');
        ForceDataFiltered = filtfilt(b,a,ForceDataRaw);                  % low pass filter        
        ForceDataFiltered(1:5,:)=[];                                     % delete first 5 frames that are artifact from LowPass filter
        ForceDataFiltered(end-5:end,:)=[];                               % delete last 5 frames that are artifact from LowPass filter
    elseif startsWith(indivData(i).name,'R_')                       % if rig trials
        ForceDataRaw = AnalogData.RawData(:,idRig);        
        [b,a] = butter(2,PB*1.25/Fnyq,'low');
        ForceDataFiltered = filtfilt(b,a,ForceDataRaw);                  % low pass filter
        ForceDataFiltered(1:5,:)=[];                                     % delete first 5 frames that are artifact from LowPass filter
        ForceDataFiltered(end-5:end,:)=[];                               % delete last 5 frames that are artifact from LowPass filter
    else
       continue
    end
    
    %% Flip data verticaly if needed
    ForceDataFlipped = 0-ForceDataFiltered(:,1);                            % flip data vertically
    if max(ForceDataFlipped) > max (ForceDataFiltered)                      % if the max value of the flipped data is greater than the max of the initial filtered data
        ForceDataFiltered = ForceDataFlipped;                               % use the flipped data (because the data was
    end   
    CSV(1:length(ForceDataFiltered),end+1)=ForceDataFiltered;
end




