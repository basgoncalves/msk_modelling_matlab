%% Description
% Goncalves, BM (2019)
%   Test Normality and identify outliers for multiple tasks
%
%
%-------------------------------------------------------------------------
%OUTPUT
%   TotalData = struct with the torque values for each subject for each
%   condition
%   description = Name of each columns of TotalData
%   TestDiff = difference between each pair of trials (output from
%   multiTestDif)
%% 
function [FinalData,Outliers] = multiOutliers (TotalData,description,TestDiff)
FinalData = TotalData;
Pairs = 1:2:length (description);
Outliers ={'Trials' 'Mean and quirtile limits' 'OutliersQ1' 'OuliersQ3' 'Number of outliers'...
    'Normality after removing outliers'}';
Col = 0;
for c = 1: 2: length (description)
    Col = Col+1;
    if nargin>2
        data = rmmissing(TestDiff (:,Col));                                       % delete NaN
    else
        [~,~,~,data] = meanDif(TotalData(:,c),TotalData(:,c+1));
         data = rmmissing(data);  
    end
    %check outliers
    [Q,IQR,outliersQ1, outliersQ3] = quartile(data);
    
    if isempty (outliersQ1)==0 || isempty (outliersQ3)==0                   % get the index of each outlier
        for ii = 1: length (outliersQ1)
            idx = find (data == outliersQ1(ii));
            FinalData(idx,Pairs(Col):Pairs(Col)+1) = NaN;
            data(idx) = []; 
        end
        
        for ii = 1: length (outliersQ3)
            idx = find (data == outliersQ3(ii));
            FinalData(idx,Pairs(Col):Pairs(Col)+1) = NaN;
            data(idx) = []; 
        end
        
    end
    
    [H, pValueSW, W] = swtest(data);
    NormalityDiff (Col) = pValueSW;
    
    Outliers{1,Col+1} = description {c};
    Outliers{2,Col+1} = round(Q);
    Outliers{3,Col+1} = round(outliersQ1);
    Outliers{4,Col+1} = round(outliersQ3);
    Outliers{5,Col+1} = length(outliersQ1)+length(outliersQ3);
    Outliers{6,Col+1} = NormalityDiff(Col);
    
    
end
