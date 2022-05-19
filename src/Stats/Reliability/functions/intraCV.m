%% Goncalves,BM (2018)
%this script calculates the mean intra-individual CV for each condition
% DO NOT use this for the wholde data set. Instead, use an external loop that 
% runs through each of your conditions (e.g. Sitting vs Standing)
%
%
% % INPUT
%   rawdata = NxM matrix with N (rows) representing the number of participant
%   and M (columns) the number of trials per participant
%
%   CI = the confidence interval in percentage (default 95%)
%
% OUTPUT
%   intraCVindividual = intra-individual coefficient of variation (CV) as described in Knutson
%   et al (1994)
%   
%   intraCVmean = mean of all the intra-individual CV
%S
%   CI = the lower and upper CI
%   
%   pNorm = p-value for the CV shapiro-wilk normality test
%
%References:
%Knutson, LM, Soderberg, GL, Ballantyne, BT, and Clarke, WR. A study of
%various normalization procedures for within day electromyographic data. J
%Electromyogr Kinesiol 4: 47–59, 1994.
% 
% Field, A. Discovering Statistics Using SPSS (and sex and drugs and rock
% “n” roll). 3rd ed. SAGE Publications, Ltd, 2009.
%
% https://au.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval
%% Start Function
function [intraCVmean,intraCVindividual,intraCI,pNorm] = intraCV (rawdata, CI)

%calculate the mean squared error of each participant
[y,nTrials] = size (rawdata);


for sub=1:y                                         %loop through all the subjects to compare inter trials
    m = mean (rawdata(sub,1:nTrials));              %absolute mean for each participant
    mse = mean((rawdata(sub,1:nTrials)-m).^2);      %mean squared error across trials for each subject
    rawdata (sub,nTrials+1)= sqrt(mse)/m *100;      %intra-individual CV(%) for each subject
end
rawdata = rmmissing(rawdata);                                 % delete all the rows with NaN 
intraCVindividual = rawdata(:,nTrials+1);                     % intra-individual CV vector (for each participant)
interCV = std(rawdata(:,1:nTrials))./mean(rawdata(:,1:nTrials)).*100; 

rawdata(:,nTrials+1)=[];

%% calculates the Normality and CI for each group of measures
[H, pNorm, W] = swtest(intraCVindividual, 0.05); %shapiro-wilk test for intra-individual CV

% define CI
limits = [0.025 0.975]; %default CI limits (95%) for CV 
if exist ('CI','var')==1 
limits(1)= (1-(CI/100))/2; %lower limit CI
limits(2) = 1-(1-(CI/100))/2;% upper limit CI
end


SEM = std(intraCVindividual)/sqrt(length(intraCVindividual));     % Standard Error of the CV
ts = tinv(limits,length(intraCVindividual)-1);          % T-Score
intraCI = mean(intraCVindividual) + ts*SEM;                  % Confindence Intervals of the CV
intraCVmean = mean (intraCVindividual);                 % Mean intra-individual Coefficient of Variation (CV)


