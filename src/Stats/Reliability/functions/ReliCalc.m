%% Description
% Goncalves, BM (2018)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this funtion calculates reliability pamaeters for two different trials
%
%----------------------------------------------------------------------
%----------------------------------------------------------------------
%   USES A LESS CONSERVATIVE MDC CALCULATION!!!! from Thorborg et al (2010)
%----------------------------------------------------------------------
%----------------------------------------------------------------------
%
% CALLBACK FUNCTIONS
%   ICC (Salarian, A. 2008)
%   intraCV (Goncalves, BM 2018)
%   BlandAltman (Ran Klein 2010)
%   swtest (Saïda 2014)
%
% INPUT
%   data = Nx2 double matrix.
%             N =  number of particiants (rows)
%             2 = number of trials per condition (columns)

%-------------------------------------------------------------------------
%OUTPUT
%   Reliability = cell arrary with ICC, CV, SEM, MDC, heteroscedasticity and Bias values
%
%--------------------------------------------------------------------------
%UPDATES 
%
% 30/1/2019 --> Include Shapiro-Wilk test and Non-parametric correlations 
% 25/03/2019 --> Include 95% CI for SEM (from Hopkins, 2005 - spreadsheet)

%% REFERENCES
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
%
% Atkinson, G., & Nevill, A. M. (1998). Statistical methods for assessing
% measurement error (reliability) in variables relevant to sports medicine.
% Sports Med, 26(4), 217-238

%% start function
function Reliability = ReliCalc (data,CI,Type)

if nargin == 1
    Alpha = 0.05;
    CI = 95;
else
    Alpha = 1-CI/100;
end

[~,Ntrials] = size (data);                                                % get the Number of participants (N) and number of trials (Ntrials)

if isempty (data)
   Reliability (1:29,1)= {0};
   return 
end

%% MEAN DATA
MeanData1 = mean(data(:,1));
SDData1 = std (data(:,1));
MeanData2 = mean(data(:,2));
SDData2 = std(data(:,2));


Mean1text = sprintf ('%.f (%.f)',MeanData1,SDData1);
Mean2text = sprintf ('%.f (%.f)',MeanData2,SDData2);

%% calculate ICC

if nargin < 3
    list = {'1-1','1-k','C-1',...
        'C-k','A-1','A-k'};
    PromptText = sprintf ...
        ('Select the Type of ICC that is more adequate for your data');
    [indx,~] = listdlg('PromptString',PromptText,...
        'ListString',list, 'ListSize', [300 150]);
    Type = list{indx};                                                             % determine the type of ICC to use based on McGraw et al. (1996)
end

[ICCmean, ICClb, ICCub] = ICC(data, Type, Alpha);                                  % Calculate ICC

ICCtext = sprintf ('%.2f (%.2f-%.2f)',ICCmean,ICClb,ICCub);
%% Calculate SEM

SDdif = std(data (:,2)- data(:,1));                                         % Standard deviation of the difference between each pair of trials (Test2 - Test1)
SEM = SDdif/sqrt(2);                                                        % standard error of measurement for each pair of trials
df = length(data)-1;                                                         % degrees of freedom

ChiInv = chi2inv(1-Alpha/2,df);                                               % Chi-square inverse cumulative distribution function
SEM_LB = sqrt(df*SEM^2/ChiInv);                                               % Lower border of 95% CI (Hopkins, 2005)

ChiInv = chi2inv(Alpha/2,df);
SEM_UB = sqrt(df*SEM^2/ChiInv);                                               % Upper border of 95% CI 


% SEM in percentage

GrandMean = mean ((data (:,2)+ data(:,1))/2);                                 % Grand Mean
SEMpercentage = SEM/ GrandMean *100;                                          % relative SEM in percentage of the mean values for the rawdata
SEMpercentage_LB = SEM_LB / GrandMean *100;
SEMpercentage_UB = SEM_UB / GrandMean *100;

SEMtext= sprintf ('%.f (%.f-%.f)',SEM, SEM_LB,SEM_UB);
SEMtextPercentage= sprintf ('%.f (%.f-%.f)',SEMpercentage, SEMpercentage_LB,SEMpercentage_UB);


%% Calculate MDC (90%)

MDC = SEM * 1.645 * sqrt(2);                                                  % absolute MDC. Weir (2005)
GrandMean = mean ((data (:,2)+ data(:,1))/2);                                 % Grand Mean
MDCpercentage = MDC/ GrandMean *100;                                          % relative MDC in percentage of the mean values for the rawdata

MDCtext = sprintf ('%.f (%.f)',MDC, MDCpercentage);

%% Calculate MDC (95%)

MDC95 = SEM * 1.96 * sqrt(2);                                                  % absolute MDC. Weir (2005)
GrandMean = mean ((data (:,2)+ data(:,1))/2);                                 % Grand Mean
MDC95percentage = MDC95/ GrandMean *100;                                          % relative MDC in percentage of the mean values for the rawdata

MDC95text = sprintf ('%.f (%.f)',MDC95, MDC95percentage);

%% Calculate intra-individual Coefficent of Variation

[intraCVmean,intraCVindividual,intraCI,pNorm] = intraCV (data, CI);
OverallCV = std (data(:,1:2))/mean (data (:,1:2))*100;

%% Heteroscedasticity - Atkinson & Nevill (1998)

indMean = (data (:,2)+ data(:,1))/2;                                % mean between-trials value for each individual
absDif = abs(data (:,2)- data(:,1));                                % absolute difference for indiviudal subjects
indMean = (data (:,2)+ data(:,1))/2;                                % mean between-trials value for each individual
[Rhetero,Pr] = corrcoef (absDif,indMean);                           % Pearson Correlation coefficient between absolute difference and individual mean
Pr = Pr(1,2);                                                       % get only one value from the 2x2 matrix above
Rhetero = Rhetero (1,2);


if Pr < 0.05                                                    % if p-value T-test < 0.05
    HeteroText = sprintf ('%.2f (%.2f)#',Rhetero,Pr);
else
    HeteroText = sprintf ('%.2f (%.2f)',Rhetero,Pr);
end

%% Paired T-test

[~,pTtest] = ttest(data (:,2),data (:,1));                                   % Calculate p-value for a paired t-test 

%% Calculate Bias (Bland-Altman analysis) - Atkinson & Nevill (1998)


    logdata = log(data);                                              % calculate the NATURAL logaritm of the data
    SDdiflog = std(rmmissing(logdata (:,2)-logdata (:,1)));           % Standard deviation for each pair of trials (LOGARITM) + delete all the rows with NaN 
    indDiflog = logdata (:,2)- logdata(:,1);                          % calculate individual differences between tests
    indDiflog = rmmissing(indDiflog);                                 % delete all the rows with NaN 
    BiasLog = exp(mean (indDiflog));                                     % Bias as the mean difference between tests using antilog transformation (Exponential)
    LoALog = exp(SDdiflog * 1.96);                                       % Limit of Agreement corrected with anti-log transformation
    uLoALog = BiasLog*LoALog;
    lLoALog = BiasLog/LoALog;
    
   
    

    SDdif = std(data (:,2)-data (:,1));                                 % Standard deviation for each pair of trials (Test2 - Test1)
    indDif = data (:,2)- data(:,1);                                     % Test 2 - Test 1
    Bias = mean (indDif);                                               % Bias as the mean difference between tests
    LoA = SDdif * 1.96;                                                 % Limit of Agreement
    uLoA = Bias + LoA;
    lLoA = Bias  - LoA;
    
    
    % Text 
    if pTtest < 0.05                                                    % if paired T-test < 0.05 
        BiasLogText = sprintf ('%.2f ×/÷ %.2f *',BiasLog,LoALog);           % add asterisk 
        BiasText = sprintf ('%.f ± %.f *',Bias,LoA);                        
    else
        BiasLogText = sprintf ('%.2f ×/÷ %.2f',BiasLog,LoALog);             
        BiasText = sprintf ('%.f ± %.f',Bias,LoA);
    end
%     [rpc, fig, stats] = BlandAltman(data (:,1), data (:,2));

%% Correlation Coefficient
[rPearson,pPearson] = corrcoef (data (:,1),data (:,2));

pPearson = pPearson(1,2);                                                       % get only one value from the 2x2 matrix above
rPearson = rPearson (1,2);

%% Normality test

[H, pValueSW1, W] = swtest(data (:,1));

[H, pValueSW2, W] = swtest(data (:,2));

pValueSW = min (pValueSW1, pValueSW2);

%% Spearman correlation coefficient 

[rSpear, pSpear] = corr (data (:,1),data (:,2),'Type','Spearman');

%% group data
Reliability = {};
i = 1;
Reliability{i,1}='N';
Reliability{i,2}=length(data);
i = i+1;
Reliability{i,1}='ICC';
Reliability{i,2}=ICCmean;
i = i+1;
Reliability{i,1}='ICC LB';
Reliability{i,2}=ICClb;
i = i+1;
Reliability{i,1}='ICC UB';
Reliability{i,2}=ICCub;
i = i+1;

% CV
Reliability{i,1}='CV';
Reliability{i,2}=intraCVmean;
i = i+1;
Reliability{i,1}='CV LB';
Reliability{i,2}=intraCI(1);
i = i+1;
Reliability{i,1}='CV UB';
Reliability{i,2}=intraCI(2);
i = i+1;
Reliability{i,1}='Overall CV(%)';
Reliability{i,2}= OverallCV;
i = i+1;

% SEM
Reliability{i,1}='SEM(N/Nm)';
Reliability{i,2}=SEM;
i = i+1;
Reliability{i,1}='SEM LB';
Reliability{i,2}=SEM_LB;
i = i+1;
Reliability{i,1}='SEM UB';
Reliability{i,2}=SEM_UB;
i = i+1;
Reliability{i,1}='SEM(%)';
Reliability{i,2}=SEMpercentage;
i = i+1;
Reliability{i,1}='SEM(%) LB';
Reliability{i,2}=SEMpercentage_LB;
i = i+1;
Reliability{i,1}='SEM(%) UB';
Reliability{i,2}=SEMpercentage_UB;
i = i+1;

%MDC
Reliability{i,1}='MDC 90';
Reliability{i,2}=MDC;
i = i+1;
Reliability{i,1}='MDC 90%';
Reliability{i,2}=MDCpercentage;
i = i+1;
Reliability{i,1}='MDC 95';
Reliability{i,2}=MDC95;
i = i+1;
Reliability{i,1}='MDC 95%';
Reliability{i,2}=MDC95percentage;
i = i+1;

% Heteroscedasticity
Reliability{i,1}='Heteroscedacity';
Reliability{i,2}=Rhetero;
i = i+1;
Reliability{i,1}='P-Hetero';
Reliability{i,2}=Pr;
i = i+1;

% Bias (LoA)
Reliability{i,1}='Bias';
Reliability{i,2}=Bias;
i = i+1;
Reliability{i,1}='LoA';
Reliability{i,2}=LoA;
i = i+1;
Reliability{i,1}='BiasLog';
Reliability{i,2}=BiasLog;
i = i+1;
Reliability{i,1}='LoALog';
Reliability{i,2}=LoALog;
i = i+1;
Reliability{i,1}='Paired T-test';
Reliability{i,2}=pTtest;
i = i+1;

% Correlations
Reliability{i,1}='Pearson R';
Reliability{i,2}=rPearson;
i = i+1;
Reliability{i,1}='Pearson R p-value';
Reliability{i,2}=pPearson;
i = i+1;
Reliability{i,1}='S-W normality';
Reliability{i,2}= pValueSW;
i = i+1;
Reliability{i,1}='Spearman Rank';
Reliability{i,2}= rSpear;
i = i+1;
Reliability{i,1}='Spearman Rank p-value';
Reliability{i,2}= pSpear;
i = i+1;

% text 

Reliability{i,1}='Mean 1(SD)';
Reliability{i,2}= Mean1text;
i = i+1;

Reliability{i,1}='Mean 2(SD)';
Reliability{i,2}= Mean2text;
i = i+1;

Reliability{i,1}='Bias ± LoA';
Reliability{i,2}= BiasText;
i = i+1;

Reliability{i,1}='Bias ×/÷ LoA';
Reliability{i,2}= BiasLogText;
i = i+1;

Reliability{i,1}='Heteroscedasticity (p)';
Reliability{i,2}= HeteroText;
i = i+1;


Reliability{i,1}='SEM(95CI)';
Reliability{i,2}= SEMtext;
i = i+1;


Reliability{i,1}='SEM%(95CI)';
Reliability{i,2}= SEMtextPercentage;
i = i+1;


Reliability{i,1}='MDC90(%)';
Reliability{i,2}= MDCtext;
i = i+1;

Reliability{i,1}='MDC95(%)';
Reliability{i,2}= MDC95text;
i = i+1;

Reliability{i,1}='ICC (95%CI)';
Reliability{i,2}= ICCtext;
i = i+1;

