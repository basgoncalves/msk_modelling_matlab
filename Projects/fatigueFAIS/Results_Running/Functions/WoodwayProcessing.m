%% Description - Basilio Goncalves (2019)
%
%Select folder that contains individual
% CALLBACK FUNTIONS
%   natsortfiles
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   TreadmillData = struct with mat data from the woodway treadmil
%   Resuts = max parameter for each file in DirWoodway
%--------------------------------------------------------------------------
function [TreadmillData,Results] = WoodwayProcessing (DirWoodway)

if nargin <1
    DirWoodway = uigetdir('','select the folder with .dat files form woodway treadmil');
end 

cd(DirWoodway)
%%
files =dir('*.dat');
TreadmillData= struct;
Results = struct;
FileNames = struct2cell(files)';
FileNames = natsortfiles(FileNames(:,1));
for ii = 1: length(files)
    % import data 
    filename = [files(ii).folder filesep FileNames{ii}];
    delimiterIn = ' ';
    headerlinesIn = 7;
	data = importdata(filename,delimiterIn,headerlinesIn);
        
    % split the titles in one char in multiple words
    Titles = strsplit(data.textdata{6,1}); 
    TrialName = erase(FileNames{ii},'.dat');
    TreadmillData.(TrialName) = data.data;
    
    idxTime = find(contains(Titles,'time'));
    
    % sample frequency = 1/time between two samples
    if size(data.data,1)<2
        sprintf('data for %s is empty',TrialName)
        continue
    else
    fs = 1/diff(data.data(2:3,idxTime));    
    end
    % max velocity
    idxVel = find(contains(Titles,'velocity'));
    Results.Velocity(ii)= max(movmean(data.data(:,idxVel),fs/2));
    
    %max acceleration
    acc = data.data(:,idxVel)./data.data(:,idxTime);
    Results.Acceleration(ii)= max(movmean(acc,fs/2));
    
    
    %max horizontal force
    idxHF = find(contains(Titles,'hforce'));
    Results.Hforce(ii)= max(movmean(data.data(:,idxHF),fs/2));
    
    % max vertical force
    idxVF = find(contains(Titles,'vforce'));
    Results.Vforce(ii)= max(movmean(data.data(:,idxVF(1)),fs/2));  
    
    % max work 
    idxW = find(contains(Titles,'work'));
    Results.Work(ii)= max(movmean(data.data(:,idxW),fs/2));
    
end

Results.VelocityPercentage = Results.Velocity/(max(Results.Velocity))*100;
Results.HforcePercentage = Results.Hforce/(max(Results.Hforce))*100;
Results.VforcePercentage = Results.Vforce/(max(Results.Vforce))*100;
Results.WorkPercentage = Results.Work/(max(Results.Work))*100;
Results.Labels = fields(TreadmillData);
TreadmillData.Labels =Titles;

save TreadmillData TreadmillData Results
