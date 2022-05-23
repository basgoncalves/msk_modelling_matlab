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
%   data = NxM double matrix.
%             N =  number of particiants (rows)
%             M = number of trials per condition (columns)

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
function Reliability = ReliCalc_plus (data,CI,Type)

if nargin == 1
    Alpha = 0.05;
    CI = 95;
else
    Alpha = 1-CI/100;
end

[~,Ntrials] = size (data);                                                % get the Number of participants (N) and number of trials (Ntrials)

pairs = nchoosek(1:Ntrials,2)';                         % Binomial coefficient or all combinations.
[~,Npairs]= size(pairs);

if isempty (data)
   Reliability (1:29,1)= {0};
   return 
end

%% MEAN DATA
for p = 1:Ntrials
    MeanData(p) = mean(rmmissing(data(:,p)));
    SDData(p) = std (rmmissing(data(:,p)));
    
    Meantext{p} = sprintf ('%.1f (%.1f)',MeanData(p),SDData(p));
end

%% calculate ICC 
% ICC total = average of ICCs for each pair of trials
for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);                                              % delete all the rows with NaN
        
    if nargin < 3
        list = {'1-1','1-k','C-1',...
            'C-k','A-1','A-k'};
        ListFull = {'1-1 (one way random, single measure',...
            '1-k (one way random, average measures)',...
            'C-1 (two way mixed, single measure ',...
            'C-k (two way mixed, average measues)',...
            'A-1 (two way random, single measure)',...
            'A-k (two way random, average measures)'};
        PromptText = sprintf ...
            ('Select the Type of ICC that is more adequate for your data');
        [indx,~] = listdlg('PromptString',PromptText,...
            'ListString',ListFull, 'ListSize', [300 150]);
        Type = list{indx};                                                             % determine the type of ICC to use based on McGraw et al. (1996)
    end
    [ICCmean(p), ICClb(p), ICCub(p)] = ICC(PairData, Type, Alpha);                                  % Calculate ICC
    
end


ICCtext = sprintf ('%.2f (%.2f-%.2f)',mean(ICCmean),mean(ICClb),mean(ICCub));

%% Calculate SEM

for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);
    
    
SDdif = std(PairData (:,2)- PairData(:,1));                                         % Standard deviation of the difference between each pair of trials (Test2 - Test1)
SEM(p) = SDdif/sqrt(2);                                                        % standard error of measurement for each pair of trials
df = length(PairData)-1;                                                         % degrees of freedom

ChiInv = chi2inv(1-Alpha/2,df);                                               % Chi-square inverse cumulative distribution function
SEM_LB(p) = sqrt(df*SEM(p)^2/ChiInv);                                               % Lower border of 95% CI (Hopkins, 2005)

ChiInv = chi2inv(Alpha/2,df);
SEM_UB(p) = sqrt(df*SEM(p)^2/ChiInv);                                               % Upper border of 95% CI 

end

SEM = mean(SEM);
SEM_LB = mean(SEM_LB);
SEM_UB = mean(SEM_UB);
% SEM in percentage

GrandMean = mean (mean(rmmissing(data)));                                          % Grand Mean
SEMpercentage = mean(SEM)/ GrandMean *100;                                          % relative SEM in percentage of the mean values for the rawdata
SEMpercentage_LB = mean(SEM_LB) / GrandMean *100;
SEMpercentage_UB = mean(SEM_UB) / GrandMean *100;

SEMtext= sprintf ('%.f (%.f)',mean(SEM), SEMpercentage);
SEMtextCI= sprintf ('%.f-%.f(%.f-%.f)',mean(SEM_LB),mean(SEM_UB), SEMpercentage_LB,SEMpercentage_UB);

%% Calculate MDC (90%)

MDC = SEM * 1.645 * sqrt(2);                                                  % absolute MDC. Weir (2005)
GrandMean = mean (mean(rmmissing(data)));                                 % Grand Mean
MDCpercentage = MDC/ GrandMean *100;                                          % relative MDC in percentage of the mean values for the rawdata

MDCtext = sprintf ('%.f (%.f)',MDC, MDCpercentage);

%% Calculate MDC (95%)

MDC95 = SEM * 1.96 * sqrt(2);                                                  % absolute MDC. Weir (2005)
GrandMean = mean (mean(rmmissing(data)));                                 % Grand Mean
MDC95percentage = MDC95/ GrandMean *100;                                          % relative MDC in percentage of the mean values for the rawdata

MDC95text = sprintf ('%.f (%.f)',MDC95, MDC95percentage);

%% Calculate intra-individual Coefficent of Variation

[intraCVmean,intraCVindividual,intraCI,pNorm] = intraCV (data, CI);
OverallCV = std (rmmissing(data))/mean (rmmissing(data))*100;

%% Heteroscedasticity - Atkinson & Nevill (1998)


for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);

indMean = (PairData (:,2)+ PairData(:,1))/2;                                % mean between-trials value for each individual
absDif = abs(PairData (:,2)- PairData(:,1));                                % absolute difference for indiviudal subjects
indMean = (PairData (:,2)+ PairData(:,1))/2;                                % mean between-trials value for each individual
[R,P] = corrcoef (absDif,indMean);                                   % Pearson Correlation coefficient between absolute difference and individual mean
Phetero(p) = P(1,2);                                                            % get only one value from the 2x2 matrix above
Rhetero(p) = R(1,2);

end

if Phetero < 0.05                                                                % if p-value T-test < 0.05
    HeteroText = sprintf ('%.2f (%.2f)#',Rhetero,Phetero);
else
    HeteroText = sprintf ('%.2f (%.2f)',Rhetero,Phetero);
end

%% Paired T-test or one way anova

if Ntrials == 2
    [~,pValueT] = ttest(data (:,2),data (:,1));                                   % Calculate p-value for a paired t-test
    
else
    [~,~,stats] = anova1(data,[],'off');
    if stats.df == 0
        pValueT = NaN;
    else
        [comparison,~,~,~] = multcompare(stats,'ctype','bonferroni','display','off');                %   Column 6 is the p-value for each individual comparison.
        pValueT = comparison(:,6)';
    end
end

%% Calculate Bias (Bland-Altman analysis) - Atkinson & Nevill (1998)

for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);
    
    logdata = log(PairData);                                              % calculate the NATURAL logaritm of the data
    SDdiflog = std(rmmissing(logdata (:,2)-logdata (:,1)));           % Standard deviation for each pair of trials (LOGARITM) + delete all the rows with NaN
    indDiflog = logdata (:,2)- logdata(:,1);                          % calculate individual differences between tests
    indDiflog = rmmissing(indDiflog);                                 % delete all the rows with NaN
    BiasLog(p) = exp(mean (indDiflog));                                     % Bias as the mean difference between tests using antilog transformation (Exponential)
    LoALog(p) = exp(SDdiflog * 1.96);                                       % Limit of Agreement corrected with anti-log transformation
    uLoALog(p) = BiasLog(p)*LoALog(p);
    lLoALog(p) = BiasLog(p)/LoALog(p);
    
    
    SDdif = std(rmmissing(PairData (:,2)-PairData (:,1)));                                 % Standard deviation for each pair of trials (Test2 - Test1)
    indDif = rmmissing(PairData (:,2)- PairData(:,1));                                     % Test 2 - Test 1
    Bias(p) = mean (indDif);                                               % Bias as the mean difference between tests
    LoA(p) = SDdif * 1.96;                                                 % Limit of Agreement
    uLoA(p) = Bias(p) + LoA(p);
    lLoA(p) = Bias(p)  - LoA(p);
    %     [rpc, fig, stats] = BlandAltman(PairData (:,1), PairData (:,2));
end

BiasLogText='';
BiasText='';

% Text
for p = 1:Npairs
    if Phetero(p) < 0.05                                                    % if paired T-test < 0.05
        BiasLogText = ([BiasLogText,(sprintf('%.2f×/÷%.2f* ',BiasLog(p),LoALog(p)))]);           % add asterisk
        BiasText = ([BiasText,(sprintf ('%.f±%.f* ',Bias(p),LoA(p)))]);
    else
        BiasLogText = ([BiasLogText,(sprintf('%.2f×/÷%.2f ',BiasLog(p),LoALog(p)))]);           % add asterisk
        BiasText = ([BiasText,(sprintf ('%.f±%.f ',Bias(p),LoA(p)))]);
    end
end

%% Correlation Coefficient

for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);
    
    [R,P] = corrcoef (PairData (:,1),PairData (:,2));
    
    pPearson(p) = P(1,2);                                                      % get only one value from the 2x2 matrix above
    rPearson(p) = R(1,2);
end

%% Normality test
for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);
    if isempty(PairData)
        pValueSW(p) = NaN;
    else
        [H, pValueN, W] = swtest(data (:,p));
        pValueSW(p) = pValueN;
    end
end

%% Spearman correlation coefficient
for p = 1:Npairs
    PairData = data (:,pairs(:,p));
    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);
    if isempty(PairData)
        rSpear(p)= NaN;
        pSpear(p) = NaN;
    else
        [R,P] = corr (PairData (:,1),PairData (:,2),'Type','Spearman');
        rSpear(p)= R;
        pSpear(p) = P;
    end
end

%% group data
Reliability = {};
i = 1;
Reliability{i,1}='N';
Reliability{i,2}=length(rmmissing(data));
i = i+1;
Reliability{i,1}='ICC';
Reliability{i,2}=mean(ICCmean);
i = i+1;
Reliability{i,1}='ICC LB';
Reliability{i,2}=mean(ICClb);
i = i+1;
Reliability{i,1}='ICC UB';
Reliability{i,2}=mean(ICCub);
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
Reliability{i,1}='SEM(raw units)';
Reliability{i,2}=mean(SEM);
i = i+1;
Reliability{i,1}='SEM LB';
Reliability{i,2}=mean(SEM_LB);
i = i+1;
Reliability{i,1}='SEM UB';
Reliability{i,2}=mean(SEM_UB);
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
Reliability{i,1}='MDC 90(raw units)';
Reliability{i,2}=MDC;
i = i+1;
Reliability{i,1}='MDC 90%';
Reliability{i,2}=MDCpercentage;
i = i+1;
Reliability{i,1}='MDC 95(raw units)';
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
Reliability{i,2}=Phetero;
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
Reliability{i,2}=pValueT;
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


Reliability{i,1}='Bias ± LoA';
Reliability{i,2}= BiasText;
i = i+1;

Reliability{i,1}='Bias ×/÷ LoA';
Reliability{i,2}= BiasLogText;
i = i+1;

Reliability{i,1}='Heteroscedasticity (p)';
Reliability{i,2}= HeteroText;
i = i+1;


Reliability{i,1}='SEM(%)';
Reliability{i,2}= SEMtext;
i = i+1;


Reliability{i,1}='SEM CI(%)';
Reliability{i,2}= SEMtextCI;
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

for M = 1:Ntrials
Reliability{i,1}= sprintf('Mean %.f(SD)',M);
Reliability{i,2}= Meantext{M};
i = i+1;
end

