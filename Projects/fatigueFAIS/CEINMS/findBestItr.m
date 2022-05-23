%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% find best iteration CEINMS
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   SimulationsDir = [char] directory of the your ceinms simulations for
%   one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% CompareCEINMSIterations
function [B,row,sumErr] = findBestItr(Dir,trialName,SubjectInfo)
tic
fp = filesep;

%% organise folders and directories

ExeDir = Dir.CEINMSsimulations;
cd(ExeDir)

% find the iterations from CEINMS (use if doing multiple comparions, eg:
% change Gamma values)
files = dir(ExeDir);
files(1:2) = [];
% delete names that are not folders
row = find(~[files.isdir]);
files(row) = [];
% remove directories not containing the trialName
row =[];
for ii = 1:length(files)
    if ~ contains(files(ii).name,trialName)
        row(end+1) = ii;
    end
end

files(row) = [];
BetaIterations = natsortfiles({files.name}');

B = {'dir','iteration','mean RMSE mom','mean RMSE EMG','RMSE mom (%range)','RMSE EMG (%range)'};
sumErr =[];
for k = 1:length(BetaIterations)
    results_directory = [ExeDir fp BetaIterations{k}];
    if ~exist([results_directory fp 'RMSE.mat'])
        BestItr =RMSEmomVSemg(Dir,results_directory,SubjectInfo);
    else
        load([results_directory fp 'RMSE.mat'])
    end
    
%     if ~exist(['BestItr']) || BestItr{2,2} ==0 ||  BestItr{2,3} == 0 || size(BestItr,2)<5
    if ~exist(['BestItr']) || BestItr{2,2} ==0 || size(BestItr,2)<5
       BestItr =  RMSEmomVSemg(Dir,results_directory,SubjectInfo);
       close all
    end
    B{k+1,1}= [results_directory fp BestItr{2,1}];
    B(k+1,2:6)= BestItr(2,:);
    sumErr(k,:) = BestItr{2,2}  + BestItr{2,3};
    clear BestItr
end
[sumErr,row] = min(sumErr);
row = row+1; % row of the mest iteration
% RMSE_mom = RMSE_mom./max(RMSE_mom);



