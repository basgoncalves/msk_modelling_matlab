%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
% Confidende intervals for difference between two independent correlations 
%
%
%--------------------------------------------------------------------------
% REFERENCES
%   Zou,GY (2007) Toward Using Confidence Intervals to Compare Correlations
%   DOI: 10.1037/1082-989X.12.4.399

function [LCI,UCI] = CorrDiff_RM(r1,r2,CI1,CI2)

% based on Modified asymptotic method (fisher transformation)

l1 = CI1(1);
u1 = CI1(2);

% CI correlation 2

l2 = CI2(1);
u2 = CI2(2);

% Limits of agreememt
LCI = r1-r2-(sqrt(r1-l1)^2+(u2-r2)^2);
UCI = r1-r2+(sqrt(u1-r1)^2+(r2-l2)^2);




% Bootstraping for reproducibility - https://au.mathworks.com/help/stats/bootstrp.html
%[bootstat,bootsam] = bootstrp(1000,@ICC_boot,PairData(:,1),PairData(:,2));

