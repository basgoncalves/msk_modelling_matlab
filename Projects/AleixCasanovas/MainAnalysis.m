% Alexi Casanovas 2021
% Statistical analysis thesis data

close all; clear; clc;

addpath(genpath('E:\MATLAB'));                  % add current folder and sub folders to path
path = matlab.desktop.editor.getActiveFilename; % path of the current script
path = fileparts (path);
cd(path)

filename = 'E:\DataFolder\Aleix\thesis results (back up).xlsx';
[~, ~, rawData] = xlsread(filename,'RResults');
Headings = rawData(1,4:end);
Data = cell2mat(rawData(2:end,4:end));

% mean of the 5 best Reaction times Pre
cols ={};
cols{1} = find(contains(Headings(1,:),'PreR1_RT'));
cols{2} = find(contains(Headings(1,:),'PostR1_RT'));
cols{3} = find(contains(Headings(1,:),'PreR2_RT'));
cols{4} = find(contains(Headings(1,:),'PostR2_RT'));
RTheadings = {'RT_PreR1' 'RT_PostR1' 'RT_PreR2' 'RT_PostR2'};
RT = [];
for r = 1:size(Data,1)
    RT(r,1) = mean(maxk(Data(r,cols{1}),5));
    RT(r,2) = mean(maxk(Data(r,cols{2}),5));  
    RT(r,3) = mean(maxk(Data(r,cols{3}),5));  
    RT(r,4) = mean(maxk(Data(r,cols{4}),5));  
end

% mean of  Lap times (remove any laps more than 5% of the mean)
cols ={};
cols{1} = find(contains(Headings(1,:),'R1_lap'));
cols{2} = find(contains(Headings(1,:),'R2_lap'));
LapTimeheadings = {'LapTime_R1' 'LapTime_R2'};
LapTime = [];
for r = 1:size(Data,1)
    % pre
    D = Data(r,cols{1}); D(D==0)=NaN;
    Limit = nanmean(D)*1.05;
    LapTime(r,1) = mean(D(D<Limit));
    % post
    D = Data(r,cols{2}); D(D==0)=NaN;
    Limit = nanmean(D)*1.05;
    LapTime(r,2) = nanmean(D(D<Limit));
end

% mean of HR
cols ={};
cols{1} = find(contains(Headings(1,:),'HR_R1'));
cols{2} = find(contains(Headings(1,:),'HR_R2'));
HRheadings = {'HR_R1' 'HR_R2'};
HR = [];
for r = 1:size(Data,1)
    % pre
    HR(r,1) = nanmean(Data(r,cols{1}));
    % post
    HR(r,2) = nanmean(Data(r,cols{2}));
end


%% Create CSV for R

S = {};
S(:,1:3) = rawData(:,1:3);
cols = find(contains(rawData(1,:),{'MBT'}));
S(:,end+1:end+4) = rawData(:,cols);

cols = find(contains(rawData(1,:),{'UBP'}));
S(:,end+1:end+length(cols)) = rawData(:,cols);

cols = find(contains(rawData(1,:),{'CMJm'}));
S(:,end+1:end+length(cols)) = rawData(:,cols);

cols = find(contains(rawData(1,:),{'BL'}));
S(:,end+1:end+length(cols)) = rawData(:,cols);

cols = find(contains(rawData(1,:),{'HG'}));
S(:,end+1:end+length(cols)) = rawData(:,cols);

cols = find(contains(rawData(1,:),{'CK'}));
S(:,end+1:end+length(cols)) = rawData(:,cols);

cols = size(S,2)+1:size(S,2)+4;
S(1,cols) = RTheadings;
S(2:end,cols) = num2cell(RT);

%LapTime
cols = size(S,2)+1:size(S,2)+2;
S(1,cols) = LapTimeheadings;
S(2:end,cols) = num2cell(LapTime);

% Heart rate
cols = size(S,2)+1:size(S,2)+2;
S(1,cols) = HRheadings;
S(2:end,cols) = num2cell(HR);






