%% Description Goncalves, BM (2019)
%   Plot Bland-Altman

%% MEAN difference in percentage

    PairData(PairData==0) = NaN;                                                 %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    PairData = rmmissing(PairData);                                              % delete all the rows with NaN
    
    MeanData = mean(PairData,2);                                                % mean between trials
    TestDiff = (PairData (:,2)- PairData(:,1))./ PairData(:,1) * 100;           % between trial difference in percentage 
    MeanDiff = mean(TestDiff); 
    SDDiff = std(TestDiff); 
    
    uLoA = MeanDiff+(1.96*SDDiff);
    lLoA =  MeanDiff-(1.96*SDDiff);
  
    
    