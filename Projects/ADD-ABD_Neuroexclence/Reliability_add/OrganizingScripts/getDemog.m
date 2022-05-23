%% Description
% Goncalves, BM (2019)
%   1. Group the anthropometrics for all the subjects
%
%
%-------------------------------------------------------------------------
%OUTPUT
%   TorqueDataAll = struct with the torque values for each subject for each
%   condition
%
%%
function demographics = getDemog


MainFolder = uigetdir('','Select the folder that contains all participants');
cd(MainFolder);
Files = dir;
Files (1:2) =[];


%% loop through all the subject folders
for n = 1 : length (Files)
    %% get the code of the subject and the directory of its folder
    cd(MainFolder);
    subject = Files(n).name;                                  % get the subject's code
    
    if isfolder (subject)~=1                                    % if it is not a folder
        continue                                                % move to the next loop iteration
    end
    subjectDir = sprintf('%s\\%s', MainFolder, subject);
    
    %% Subject data
    
    cd(subjectDir);
    
    indivData = dir;
    
    % get the code of the subject
    lastDash = strfind(indivData(1).folder,'\');                                    % find all the backslashes in the name of the folder
    lastDash = lastDash (end);                                                  % get the last backslash, prior to the folder name
    subject = indivData(1).folder (lastDash+1:end);
    
    %% Check if ElaboratedData folder exists
    if exist ('ElaboratedData','dir')~=7
        sprintf('%s Data not converted to MAT',subject)
        continue
    end
    
    % % if exist ('outputData.mat','file')==2
    % % load ('outputData.mat')
    % % cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
    % % else
    %
    
    cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
    indivData = dir;
    indivData (1:2)=[];                         % delete the two first file that are artifact
    %% load and store atropmetric data
    Data = load ('AntropData.mat');
    Data = orderfields(Data);
    demographics.Labels = fields(Data)';
    Data = struct2array(Data);
    
    if contains(subject,'day1')
        col = 0;
        for ii = 1:2:length(demographics.Labels)*2
            Data = [Data(1:ii),0, Data(ii+1:end)];
        end
    elseif contains(subject,'day2')
        col = 1;
        Data = [0,Data(1:end)];
        for ii = 2:2:length(demographics.Labels)*2
            Data = [Data(1:ii), 0,Data(ii+1:end)];
        end
    end
    
    idUnderscore = strfind(subject,'_');
    subject = subject(1:idUnderscore(end)-1);
    
    if isfield (demographics,'Subjects')==0
        demographics.Subjects = {subject};
    end
    [subjectRow,~] = size (demographics.Subjects);                             % number of Subjects
    
    for  i = 1:subjectRow                                                       % loop through all the Subjects
        if contains(demographics.Subjects{i},subject)                          % if the current subject name exists
            subjectRow = i;                                                              % get the index of that file
            break                                                                        % stop the loop
            
        elseif i== subjectRow
            subjectRow = subjectRow+1;
            demographics.Subjects{subjectRow,1} = {subject};
        end
    end
    
    
    for ii = 1:2:length(demographics.Labels)*2
        demographics.Data(subjectRow,ii+col) = Data(ii+col);
    end
    
end

%% add a space between every N cell amd add "-2" or "-1" after the name
A=demographics.Labels;

N = 2;
nCol = size(A,N);

for ii = 1:N:nCol*2
    A = {A{1:ii}, sprintf('%s-2',A{ii}), A{ii+1:end}};
end

for ii = 1:N:nCol*2
    A{ii} =char({sprintf('%s-1',A{ii})});             % convert from cell to char each of the cells
end


demographics.LabelsAll = A;
