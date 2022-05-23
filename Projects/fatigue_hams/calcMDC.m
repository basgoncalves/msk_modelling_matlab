% 
%% Description
% Goncalves, BM (2018)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this funtion calculates the Minimal detectable Change at  
%
% 
% CALLBACK FUNCIONS
%   ICC (Salarian, A. 2008)
%   intraCV (Goncalves, BM 2018)
%
% INPUT 
%   rawdata = Nx2 double matrix.
%             N =  number of particiants (rows)
%             2 = number of columns grouped by Ntrials per condition
%             example data (each column): 
% Var1_Cond1_trial | Var1_Cond1_trial2 | Var1_Cond2_trial | Var1_Cond2_tria2....  
%
%   Ntrials (not required) = number of trials per condition
%
%   Cond (not rquired)= 1xN cell array with N conditions associated with your data
%
%   varNames (not required) =  1xN cell array with N variables associated
%   with your data
%
%-------------------------------------------------------------------------
%OUTPUT
%   Reliability = cell arrary with ICC, SEM and MDC values
%
%--------------------------------------------------------------------------
% REFERENCES 
%
% Weir, J. P. (2005). Quantifying Test-Rest Reliability Using the
% Intraclass Correlation Coefficient and the SEM. 
% J Str Cond Res, 19(1), 231–240.
% 
% Koo, T. K., & Li, M. Y. (2016). A Guideline of Selecting and 
% Reporting Intraclass Correlation Coefficients for Reliability Research. 
% Journal of Chiropractic Medicine, 15(2), 155–163.
%
% Field, A. Discovering Statistics Using SPSS (and sex and drugs and rock
% “n” roll). 
% 3rd ed. SAGE Publications, Ltd, 2009.
%
% https://au.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval
%% start function
function Reliability = calcMDC (data,CI,Type)

if nargin == 1
Alpha = 0.05;
else 
Alpha = 1-CI/100;
end

[N,Ntrials] = size (data);                                                % get the Number of participants (N) and number of trials (Ntrials) 


Zscore = tinv(1-Alpha,N-1);                                               % calculate the critical T 
close; close;                                                                % close the 2 figures output of the anova function


%% calculate ICC

if nargin ==2 
list = {'1-1','1-k','C-1',...                   
'C-k','A-1','A-k'};
PromptText = sprintf ...
    ('Select the Type of ICC that is more adequate for your data');
[indx,~] = listdlg('PromptString',PromptText,...
    'ListString',list, 'ListSize', [300 150]);
Type = list{indx};                                                             % determine the type of ICC to use based on McGraw et al. (1996)
end

[ICCout, LB, UB] = ICC(data, Type, Alpha);                                     % Calculate ICC 


%% Calculate SEM

SDdif = [];
for t = 1: Ntrials-1
   SDdif (t) = std(data (:,t+1)-data (:,t));                                 % Standard deviation for each pair of trials
   SEM(t) = SDdif / sqrt(2);                                                 % standard error of measurement for each pair of trials 
end
SEM = mean (SEM);                                                            % avreage of the SEM for different trials 

%% Calculate MDC 

MDC = SEM * Zscore * sqrt(2);                                                % absolute MDC. Weir (2005)
MeanData = mean (mean (data,1));                                             % mean of the mean for each column 
MDCpercentage = MDC/ MeanData *100;                                          % relative MDC in percentage of the mean values for the rawdata

%% Calculate intra-individual Coefficent of Variation

[intraCVmean,intraCVindividual,intraCI,pNorm] = intraCV (data, CI);


%% group data
Reliability = {};
i = 1;
Reliability{i,1}='ICC';
i = i+1;
Reliability{i,1}='ICC LB';
i = i+1;
Reliability{i,1}='ICC UB';
i = i+1;
Reliability{i,1}='CV';
i = i+1;
Reliability{i,1}='CV LB';
i = i+1;
Reliability{i,1}='CV UB';
i = i+1;
Reliability{i,1}='SEM';
i = i+1;
Reliability{i,1}='MDC';
i = i+1;
Reliability{i,1}='MDC%';

i=1;
Reliability{i,2}=ICCout;
i = i+1;
Reliability{i,2}=LB;
i = i+1;
Reliability{i,2}=UB;
i = i+1;
Reliability{i,2}=intraCVmean;
i = i+1;
Reliability{i,2}=intraCI(1);
i = i+1;
Reliability{i,2}=intraCI(2);
i = i+1;
Reliability{i,2}=SEM;
i = i+1;
Reliability{i,2}=MDC;
i = i+1;
Reliability{i,2}=MDCpercentage;
i = i+1;