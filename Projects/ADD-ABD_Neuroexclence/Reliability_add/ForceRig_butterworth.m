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

function TorqueDataAll = ForceRig_butterworth (subjectDir)

%% find the folder of the subject to analyse IF not specified

if nargin <1
subjectDir = uigetdir('','Select subject folder');
end

%% get Files in the subject folder and subject code
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

%% Check if ElaboratedData folder exists
if exist ('ElaboratedData','dir')~=7
    sprintf('%s Data not converted to MAT',subject)
    TorqueDataAll = 0;
    return
end

% % if exist ('outputData.mat','file')==2
% % load ('outputData.mat')
% % cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
% % else
%     

cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
indivData = dir;
indivData (1:2)=[];                         % delete the two first file that are artifact


% %end

%% filter settings
fs = 2000;                   % sample frequency
Fnyq = fs/2;
PB = 6;                     % passband frequency

%% Add anthropometric data

if isempty(find(strcmp({indivData.name}, 'AntropData.mat')==1,1))==1                %find if the file AtntropData does not exists in the current folder
    
    PROMPT = sprintf('anthopometric measures for subject %s', subject);
    
    RigPadThickness = 0.02;            % Half the thickness in METERS
    BiodexPadThickness = 0.0825;         % Half the thickness in METERS
    
    Weight = inputdlg('Weight in KG',PROMPT,1);                                 % WEIGHT
    Weight = str2double (Weight{1});                                            %convert to double
    
    Height = inputdlg('Height in METERS',PROMPT,1);                             % HEIGHT
    Height = str2double (Height{1});                                            %convert to double
    
    LowerLimbLength = inputdlg('Lower Limb Length in METERS',PROMPT,1);         % LOWER LIMB
    LowerLimbLength = str2double (LowerLimbLength{1});                          %convert to double
    
    ThighLength = inputdlg('Thigh Length in METERS',PROMPT,1);                  % THIGH LENGTH
    ThighLength = str2double (ThighLength{1});                                  %convert to double
    
    LowerLegLength = inputdlg('Enter Lower Leg Length in METERS',PROMPT,1);     % LOWER LEG
    LowerLegLength = str2double (LowerLegLength{1});                            %convert to double
    
    % lever arms Rig
    uiwait(msgbox('Input data for RIG lever arms'));                            % pop-up message
    
    GT2KneeRig = inputdlg...
        ('G.Throcanter to RIG knee pad in METERS',PROMPT,1);                    % GT to KNEE PAD
    GT2KneeRig = str2double (GT2KneeRig{1});                                    %convert to double
    GT2KneeRig = GT2KneeRig + RigPadThickness;
    
    Patella2AnkleRig = inputdlg...
        ('Patella to RIG ankle pad in METERS',PROMPT,1);                        % PATELLA to ANKLE
    Patella2AnkleRig = str2double (Patella2AnkleRig{1});                        %convert to double
    Patella2AnkleRig = Patella2AnkleRig + RigPadThickness;
    
    GT2AnkleRig = inputdlg...
        ('G.Throcanter to RIG ankle pad in METERS',PROMPT,1);                  % GT to ANKLE
    GT2AnkleRig = str2double (GT2AnkleRig{1});                                 %convert to double
    GT2AnkleRig = GT2AnkleRig + RigPadThickness;
    
    
    % lever arm Biodex
    uiwait(msgbox('Input data for BIODEX lever arms'));                         % pop-up message
    
    GT2KneeBiodex = inputdlg...
        ('G.Throcanter to BIODEX knee pad in METERS',PROMPT,1);                 % GT to KNEE PAD
    GT2KneeBiodex = str2double (GT2KneeBiodex{1});                              %convert to double
    GT2KneeBiodex = GT2KneeBiodex + BiodexPadThickness;
    
    Patella2AnkleBiodex = inputdlg...
        ('Patella to BIODEX ankle pad in METERS',PROMPT,1);                     % PATELLA to ANKLE
    Patella2AnkleBiodex = str2double (Patella2AnkleBiodex{1});                  %convert to double
    Patella2AnkleBiodex = Patella2AnkleBiodex + BiodexPadThickness;
    
    save AntropData Height Weight LowerLimbLength ThighLength ...
        LowerLegLength GT2KneeRig Patella2AnkleRig ...
        GT2AnkleRig GT2KneeBiodex Patella2AnkleBiodex;
    
else                                                                        % if it does exist Load it
    load ('AntropData.mat')
    
end

%% delete names that are not folders
deletedFiles = 0;

for i = 1: length (indivData)                               % run trhough all the files
    
    n = i-deletedFiles;                                 % use variable to account for deleted files
    contNum = 0;                                        % LOGICAL to check if contains number
    Underscore = strfind(indivData(n).name,'_');                                    % find all the underscore in the name of the folder
    
    if exist (indivData(n).name,'dir')==7 && isempty (Underscore)==0                % if it is a folder AND the name contains underscore
        
        Underscore = Underscore (1);                                                    % get the first underscore, prior to the folder name
        
    elseif exist (indivData(n).name,'dir')==7 && isempty (Underscore)           % if it is a folder and UNDESCORE is EMPTY
        
        Underscore = 2;                                                                 % use the whole name of the folder
        
    else                                                                %if not
        indivData(n)= [];                                                           % delete file
        deletedFiles = deletedFiles +1;
        continue                                                                % continue to next loop
    end
    
    %% delete subject code from name of the trials (eg. 013_B_1 => B_1)
    
    if isempty(str2num(indivData(n).name (1:Underscore-1)))~= 1                     % check if first part of the name is a number (referent to the number of the subject) _ COMPLETE THIS PART
        indivData(n).trial = indivData(n).name (Underscore+1:end);                      % write the number -> remove the number and add it to trial column
    else
        indivData(n).trial = indivData(n).name;                                         % if it is not number -> write full name
    end
    %% delete the last name from the trial name
    
    numbers = '0123456789';
    
    for N = 1 : length (numbers)
        
        if contains (indivData(n).trial,numbers(N))==1                                   % if Trial name contains a number
            idxNum = strfind(indivData(n).trial,numbers(N));                              % find the index of the number in the name
            
            indivData(n).trial = indivData(n).trial (1:idxNum-2);
            
        end
        
    end
    
    if strcmp (indivData(n).trial,'Biode')
        indivData(n).trial = 'Biodex';
    end
    
end
clear i Underscore n

%% Find the max for each trial and create the labels
% indTorqueBiodex = [];                                       % Torque Biodex for individual trials
% indForceRig = [];
% indForceViconBiodex = [];
% indLabelsBiodex ={};
% indLabelsRig={};
% indLabelsViconBiodex={};
% countRig =1;
% countBiodex =1;
% countViconBiodex=1;
% RawDataBiodex = [];
% RawDataRig = [];
% RawDataViconBiodex = [];

LoadBar = waitbar(0,'Please wait...');

for i = 1:length (indivData)
    
    waitbar(i/length (indivData),LoadBar,'Please wait...');
    %% load each trial
    fileName = sprintf...
        ('%s\\%s\\AnalogData.mat',...
        indivData(i).folder, indivData(i).name);                     %find the mat file called AnalogData in each trial folder
    
    load(fileName);                                          % load mat file
    
    %% get the index of Rig and Biodex
    for ii = 1: length (AnalogData.Labels)                   % loop thorugh the labels of the mat file
        if contains (AnalogData.Labels{ii},'Torque')          % find Torque = Biodex
            idBiodex = ii;
        elseif contains (AnalogData.Labels{ii},'Force')       % find Force = Rig
            idRig = ii;
        end
    end
 
    %% Filter force data
    ForceDataRaw =[];
    ForceDataFiltered=[];
    
    if isempty (AnalogData.RawData)                                  % if there is no data in the RawData field move to next iteration 
         ForceDataRaw = 0;
         ForceDataFiltered = 0;
        
    elseif startsWith(indivData(i).trial,'B_')                        % if biodex trials
        ForceDataRaw =AnalogData.RawData(:,idBiodex);
        
        
        [b,a] = butter(2,PB*1.25/Fnyq,'low');
        ForceDataFiltered = filtfilt(b,a,ForceDataRaw);                  % low pass filter
        
        ForceDataFiltered(1:5,:)=[];                                     % delete first 5 frames that are artifact from LowPass filter
        ForceDataFiltered(end-5:end,:)=[];                               % delete last 5 frames that are artifact from LowPass filter
        
            
    elseif startsWith(indivData(i).trial,'R_')                       % if rig trials
        ForceDataRaw = AnalogData.RawData(:,idRig);
        
        [b,a] = butter(2,PB*1.25/Fnyq,'low');
        ForceDataFiltered = filtfilt(b,a,ForceDataRaw);                  % low pass filter
        
        ForceDataFiltered(1:5,:)=[];                                     % delete first 5 frames that are artifact from LowPass filter
        ForceDataFiltered(end-5:end,:)=[];                               % delete last 5 frames that are artifact from LowPass filter

    elseif contains (indivData(i).trial,'Biodex')                    % if Vicon/biodex
        ForceDataRaw = AnalogData.RawData(:,idBiodex);
        
        [b,a] = butter(2,PB*1.25/Fnyq,'low');
        ForceDataFiltered = filtfilt(b,a,ForceDataRaw);                  % low pass filter
        
        ForceDataFiltered(1:5,:)=[];                                     % delete first 5 frames that are artifact from LowPass filter
        ForceDataFiltered(end-5:end,:)=[];                               % delete last 5 frames that are artifact from LowPass filter
    else
        ForceDataRaw = 0;
        ForceDataFiltered = 0;
    end
    
    %% Flip data verticaly if needed
    ForceDataFlipped = 0-ForceDataFiltered(:,1);                            % flip data vertically
    
    
    if max(ForceDataFlipped) > max (ForceDataFiltered)                      % if the max value of the flipped data is greater than the max of the initial filtered data
        ForceDataFiltered = ForceDataFlipped;                               % use the flipped data (because the data was
    end   
    %% Plot and save data graph for each subject
    
%     H = figure ();
%     plot (ForceDataFiltered);
%     
%     Title = sprintf ('day%d %s', day+1,indivData(i).name);                    % create title for the graph
%     
%     title (Title,'Interpret','None');
%     Nsamples = length (ForceDataFiltered);                                 % number of samples
%     time = round(Nsamples/fs,2);                                           % time in sec = Number of samples / sample frequency
%     
%     xticks(0:Nsamples/5:Nsamples);                                         % devide the length of X axis in 5 equal parts (https://au.mathworks.com/help/matlab/creating_plots/change-tick-marks-and-tick-labels-of-graph-1.html)
%     xticklabels(0:time/5:time);                                            % rename the X labels with the time in sec 
%     xlabel ('Time (s)');
%     ylabel ('Force / Torque (N or Nm)');
%        
%     [pathstr,~,~]  = fileparts(fileName);                                % get the folder where the current Analog File is
%     cd (pathstr);
%     
%     savefig (H,'ForceData');                                             % save the force curve figure in the same folder
%     close
%     
    %% calculate peak force for individual trials and store data as Rig, Biodex or ViconBiodex
    
    peakForce = max (movmean(ForceDataFiltered,fs));                   % peak force as the max 1s moving average
    indivData(i).peakForce = peakForce;
    %% calculate baseline force
    baselineForce = min (movmean(ForceDataFiltered,fs));                   % peak force as the max 1s moving average
    indivData(i).baselineForce = baselineForce;
end
close(LoadBar)
clear i AnalogData ForceData countRig countBiodex

%% get the Moment Arm for each trial and convert Rig to Torque
for nTrial = 1: length (indivData)
    
    
    if contains (indivData(nTrial).trial,'B_AB') || ...
            contains (indivData(nTrial).trial,'B_AD')                           %if it is the Biodex ABD, ADD, 
        
        indivData(nTrial).MomArm = GT2KneeBiodex;                                                % get Moment arm          
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        
    elseif contains (indivData(nTrial).trial,'R_AB') || ...                     %if it is the Rig ABD, ADD, EABER, EER or EAB trial
            contains (indivData(nTrial).trial,'R_AD')
                    
        indivData(nTrial).MomArm = GT2AnkleRig;                                                  % get Moment arm 
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        indivData(nTrial).peakTorque = indivData(nTrial).peakTorque * indivData(nTrial).MomArm;    % conert to torque
        
    elseif  contains (indivData(nTrial).trial,'R_EAB')||...
            contains (indivData(nTrial).trial,'R_EER')||...
            contains (indivData(nTrial).trial,'R_EABER')
      indivData(nTrial).MomArm = 1;                                                  % get Moment arm 
      indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
      indivData(nTrial).peakTorque = indivData(nTrial).peakTorque * indivData(nTrial).MomArm;    % conert to torque
            
    elseif contains (indivData(nTrial).trial,'B_ER') || ...
            contains (indivData(nTrial).trial,'B_IR')                           %if it is the Biodex ER or IR trial
        
        indivData(nTrial).MomArm = Patella2AnkleBiodex;                                           %  get Moment arm 
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        
    elseif contains (indivData(nTrial).trial,'R_ER') || ...
            contains (indivData(nTrial).trial,'R_IR')                           %if it is the Rig ER or IR trial
        
        indivData(nTrial).MomArm = Patella2AnkleRig;                                              %  get Moment arm
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce * indivData(nTrial).MomArm;     % conert to torque

    elseif contains (indivData(nTrial).trial,'B_F') || ...
            contains (indivData(nTrial).trial,'B_E')                            %if it is the Flexion or Extension trial
        
        indivData(nTrial).MomArm = GT2KneeBiodex;                                                %   get Moment arm 
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        
    elseif contains (indivData(nTrial).trial,'R_F')                             %if it is the Rig Flexion trial
        
        indivData(nTrial).MomArm = GT2KneeRig;                                                   %   get Moment arm
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce;
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce * indivData(nTrial).MomArm;    % conert to torque
        
    elseif contains (indivData(nTrial).trial,'R_E')                             %if it is the Rig Extesniso trial
        
        indivData(nTrial).MomArm = GT2AnkleRig;                                                  %   get Moment arm
        AngleForce = 30;
        Rad = AngleForce*pi/180; 
        indivData(nTrial).peakTorque = indivData(nTrial).peakForce / cos (Rad);                     % account for the angle of force production (30 deg with horizontal)
        indivData(nTrial).peakTorque =  indivData(nTrial).peakTorque  * indivData(nTrial).MomArm;   % conert to torque
    end
end

clear nTrial

%% Find the column number for each field 

FieldsData = fields (indivData);                                                % get the first row names (fields) 

for ii = 1 : length (FieldsData) 
    if contains (FieldsData{ii}, 'name'), idxName = ii;
    elseif contains (FieldsData{ii}, 'peakTorque'), idxpeakTorque = ii;
    elseif contains (FieldsData{ii}, 'baselineForce'), idxbaselineForce = ii;
    elseif contains (FieldsData{ii}, 'MomArm'), idxMomArm = ii;
    elseif contains (FieldsData{ii}, 'trial'), idxTrial = ii;
    end
end

%% Max, Mean and mean baseline for each position 
FilesCell = struct2cell (indivData)';

nameBiodex = sprintf ('%s', indivData(1).trial);                            % name of the first Biodex trial
lastTrial = 1;                                                              % mark the last selected trial (start with one)

for ii = 1 :length (FilesCell)                                              % loop through all the trials
    
    if ii==length (FilesCell)  &&  strcmp (FilesCell{ii,idxTrial}, nameBiodex)==0         % if it's the last trial AND DIFFERENT name as before
        indivData(ii-1).MeanTrial = mean ([FilesCell{lastTrial:ii-1,idxpeakTorque}]);
        indivData(ii-1).MaxTrial = max([FilesCell{lastTrial:ii-1,idxpeakTorque}]);                 % Get the Mean and MAX of the trials with same name 
        indivData(ii-1).MeanBaseline = mean([FilesCell{lastTrial:ii-1,idxbaselineForce}]);            % mean of baseline for each trial
        lastTrial = ii;
        indivData(ii).MeanTrial = mean ([FilesCell{lastTrial:ii,idxpeakTorque}]);
        indivData(ii).MaxTrial = max([FilesCell{lastTrial:ii,idxpeakTorque}]);                     % Get Mean and MAX of the LAST trial
        indivData(ii).MeanBaseline = mean([FilesCell{lastTrial:ii,idxbaselineForce}]);                % mean of baseline for each trial
        
    elseif ii==length (FilesCell)  &&  strcmp (FilesCell{ii,idxTrial}, nameBiodex)==1     % if it's the last trial AND SAME name as before
        indivData(ii).MeanTrial = mean ([FilesCell{lastTrial:ii,idxpeakTorque}]);
        indivData(ii).MaxTrial = max([FilesCell{lastTrial:ii,idxpeakTorque}]);                     % Get the Mean and MAX of the trials with same name 
        indivData(ii).MeanBaseline = mean([FilesCell{lastTrial:ii,idxbaselineForce}]);                % mean of baseline for each trial
        
    elseif strcmp (FilesCell{ii,idxTrial}, nameBiodex)==0                                   % if the current and previous trials DO NOT have same name
        
        indivData(ii-1).MeanTrial = mean ([FilesCell{lastTrial:ii-1,idxpeakTorque}]);
        indivData(ii-1).MaxTrial = max([FilesCell{lastTrial:ii-1,idxpeakTorque}]);                  % select the trials with same name (between the last selected and the one before the name has gone different)
        indivData(ii-1).MeanBaseline = mean([FilesCell{lastTrial:ii-1,idxbaselineForce}]);             % mean of baseline for each trial
        lastTrial = ii;
               
    end
    
    
    nameBiodex = sprintf ('%s', indivData(ii).trial);
    
end

%% Find the column number for each field 

FieldsData = fields (indivData);

for ii = 1 : length (fields (indivData))
    if contains (FieldsData{ii}, 'MaxTrial'), idxMaxTrial = ii;
    elseif contains (FieldsData{ii}, 'MeanTrial'), idxMeanTrial = ii;
    elseif contains (FieldsData{ii}, 'MeanBaseline'), idxMeanBaseline = ii;    
    end
end

%% convert max trials to cell
MaxTrials = struct2cell (indivData)';                                           % convert structure to cell 
deletedTrials=0;
for i = 1: length (MaxTrials)
   if isempty(MaxTrials{i-deletedTrials,end})                                % check if Max trial row is empty 
    MaxTrials(i-deletedTrials,:)=[];
    deletedTrials = deletedTrials+1;
   end
end


MaxTrials (:,1)=(MaxTrials (:,idxTrial));       % trial names (Columns 1)
MaxTrials (:,2)=(MaxTrials (:,idxMomArm));      % moment arm (Column 2)
MaxTrials (:,3)=(MaxTrials (:,idxMeanTrial));      % Mean Trial (Column 3)
MaxTrials (:,4)=(MaxTrials (:,idxMaxTrial));      % Max Trial (Column 4)
MaxTrials (:,5)=(MaxTrials (:,idxMeanBaseline));      % Baseline (Column 5)
MaxTrials (:,6:end)= [];

MaxTrials = MaxTrials';                         % data for each trial 

MaxTrialsLabels={};
MaxTrialsLabels(1,1)={'trial'};                        % labels
MaxTrialsLabels(2,1)={'MomArm'};
MaxTrialsLabels(3,1)={'MeanTrial'};
MaxTrialsLabels(4,1)={'MaxTrial'};
MaxTrialsLabels(5,1)={'Baseline'};

%% save individual force values
cd (subjectDir);

save outputDataNoOffset indivData MaxTrials MaxTrialsLabels

%% Create final data cell and Remove offset of extension 

% cd to main folder 
idDash = strfind(subjectDir,'\');
MainFolder = subjectDir(1:idDash(end)-1);                                   % main folder = one folder above subject folder
cd(MainFolder)

FinalData = {'B_AB' 'B_AD' 'B_E' 'B_F' 'B_IR' 'B_ER' ...
    'R_AB' 'R_AD' 'R_E' 'R_F' 'R_IR' 'R_ER' ...
    'R_EABER' 'R_EAB' 'R_EER'};                                             % vector combining labels for all the conditions


% get the weight of the leg in Extension
for i = 1:length(MaxTrials)                                                 % loop through all the Max trials
    
    if contains (MaxTrials{1,i},'B_Eweight', 'IgnoreCase', true)            % when gets to B_Eweight
    idWeight = i;  
    elseif contains (MaxTrials{1,i},'B_E_weight', 'IgnoreCase', true)              % when gets to B_E
    idWeight = i;
    elseif contains (MaxTrials{1,i},'B_E', 'IgnoreCase', true)              % when gets to B_E
    idE = i;
    
    end   
end

if exist('idWeight')
MaxTrials{5,idE} = -MaxTrials{3,idWeight};                                   % baseline B_E = Mean of B_Eweight
end


for i = 1:length(MaxTrials)                                                 % loop through all the Max trials
    idx = find(strcmp(FinalData(1,:),MaxTrials{1,i}));                         % find an index of the "Labels" that matches the name of the trial 
    if isempty (idx)==0                                                     % if it exists  --> write the trial under the respective label 
    FinalData {2,idx} = MaxTrials{2,i};                                        % MomArm
    FinalData {3,idx} = MaxTrials{3,i};                                        % MeanTrial 
    FinalData {4,idx} = MaxTrials{4,i};                                        % MaxTrial 
    FinalData {5,idx} = MaxTrials{5,i};                                        % MeanBaseline 
    end
end

%% Make all empty cell =  Zero

tf = cellfun('isempty',FinalData); % true for empty cells
FinalData(tf) = {0};               % replace by a cell with a zero

%% create row vectors for each Data set
DataTorqueNoOffset = cell2mat (FinalData(4,:));                                  % max torque data minus the offset

DataTorqueOffset = cell2mat (FinalData(4,:)) -cell2mat (FinalData(5,:));         % max torque data minus the offset
DataMean =  cell2mat (FinalData(3,:))-cell2mat (FinalData(5,:));                 % mean torque data
DataBWnormalized =  DataTorqueOffset/Weight;                                     % Data normalized to Body weigth = TorqueData / BW
DataNewtons =  DataTorqueNoOffset ./ cell2mat (FinalData(2,:));                  % Data in Newtons = TorqueData / MomentArm

idUnderscore = strfind(subject,'_');
subject = subject(1:idUnderscore(end)-1);                                   % subject = subject without the "_day1" (example)

if (exist(fullfile(cd, 'TorqueDataAll.mat'), 'file') == 2)~= 0             % find if TorqueDataAll.mat exists
    load TorqueDataAll
else
    TorqueDataAll= struct;
end


if isfield (TorqueDataAll,'Subjects')==0                                    % if the TorqueDataAll is empty
    TorqueDataAll.Subjects = {subject};
    TorqueDataAll.Labels = FinalData(1,:);
    TorqueDataAll.DataTorque = zeros(1,2*length (FinalData));
    TorqueDataAll.DataMean = zeros(1,2*length (FinalData));
    TorqueDataAll.DataBWnormalized = zeros(1,2*length (FinalData));
    TorqueDataAll.DataNewtons = zeros(1,2*length (FinalData));
end

[subjectRow,~] = size (TorqueDataAll.Subjects);                             % number of Subjects in TorqueAll dataset

for  i = 1:subjectRow                                                       % loop through all the Subjects
    if contains(TorqueDataAll.Subjects{i},subject)                          % if the current subject name exists
        subjectRow = i;                                                              % get the index of that file
        break                                                                        % stop the loop
        
    elseif subjectRow==i                                                    % if it get to the end of the loop = current name DOES NOT exist
        subjectRow = subjectRow+1;                                                   % add one new subject
        TorqueDataAll.Subjects{subjectRow,1} = subject;                              % add the code of the subject to the subject variable
        TorqueDataAll.DataNoOffset(subjectRow,1:end) = zeros;
        TorqueDataAll.DataTorque(subjectRow,1:end) = zeros;
        TorqueDataAll.DataMean (subjectRow,1:end) = zeros;
        TorqueDataAll.DataBWnormalized (subjectRow,1:end) = zeros;
        TorqueDataAll.DataNewtons(subjectRow,1:end) = zeros;
    end
end


if TorqueDataAll.DataTorque(subjectRow,1+day)~= 0                                 % if the cell for this day (col) and subject is NOT empty (~=0)
    
    Question =  questdlg(sprintf('do you want to overwrite data for subject %s?',subject));
    
    if contains (Question, 'No')
        return                                                              % If answer is no, end function
    end
    
end

%% Add subject data to the group data
BegginingofLoop = 1;
EndofLoop =  2*length (FinalData);
a = 1;

for i = BegginingofLoop: 2: EndofLoop                                        %loop from
    finalcolumn = i+day;                                                     % col = 0 for day 1 || col = 1 for day 2
    TorqueDataAll.DataNoOffset(subjectRow,finalcolumn)= DataTorqueNoOffset(a); 
    TorqueDataAll.DataTorque(subjectRow,finalcolumn)= DataTorqueOffset(a);               
    TorqueDataAll.DataMean(subjectRow,finalcolumn)= DataMean(a);
    TorqueDataAll.DataBWnormalized(subjectRow,finalcolumn)= DataBWnormalized(a);
    TorqueDataAll.DataNewtons(subjectRow,finalcolumn)= DataNewtons(a);
    
    a = a+1;
end

%% save All Data
save TorqueDataAll TorqueDataAll

sprintf('TorqueDataAll saved for %s',subject)


