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

function [LCI,UCI] = CorrDiff_BG(r1,r2,N,Alpha)

% based on Modified asymptotic method (fisher transformation)

% CI correlation 1 
z = norminv(1-Alpha/2); 

l = 1/2*log((1+r1)/(1-r1))-z*(1/(sqrt(N-3)));
u = 1/2*log((1+r1)/(1-r1))+z*(sqrt(1/(N-3)));

l1 = (exp(2*l)-1)/(exp(2*l)+1);
u1 = (exp(2*u)-1)/(exp(2*u)+1) ;

% CI correlation 2
l = 1/2*log((1+r2)/(1-r1))-z*(1/(sqrt(N-3)));
u = 1/2*log((1+r1)/(1-r1))+z*(sqrt(1/(N-3)));

l2 = (exp(2*l)-1)/(exp(2*l)+1);
u2 = (exp(2*u)-1)/(exp(2*u)+1) ;

% Limits of agreememt
LCI = r1-r2-(sqrt(r1-l1)^2+(u2-r2)^2);
UCI = r1-r2+(sqrt(u1-r1)^2+(r2-l2)^2);




% Bootstraping for reproducibility - https://au.mathworks.com/help/stats/bootstrp.html
%[bootstat,bootsam] = bootstrp(1000,@ICC_boot,PairData(:,1),PairData(:,2));

