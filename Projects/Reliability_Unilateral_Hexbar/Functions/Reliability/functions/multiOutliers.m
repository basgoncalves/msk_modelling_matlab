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
Outliers ={};

for Col= 1: length (description)/2
    data = rmmissing(TestDiff (:,Col));                                       % delete NaN
    
    [H, pValueSW, W] = swtest(data);
    NormalityDiff (Col) = pValueSW;
    
    %check outliers
    [Q,IQR,outliersQ1, outliersQ3] = quartile(data);
    Outliers{1,Col} = description {Col};
    Outliers{2,Col} = round(Q);
    Outliers{3,Col} = round(outliersQ1);
    Outliers{4,Col} = round(outliersQ3);
    Outliers{5,Col} = length(outliersQ1)+length(outliersQ3);
    Outliers{6,Col} = NormalityDiff(Col);
    
    if isempty (outliersQ1)==0 || isempty (outliersQ3)==0                   % get the index of each outlier
        for ii = 1: length (outliersQ1)
            idx = find (data == outliersQ1(ii));
            FinalData(idx,Pairs(Col):Pairs(Col)+1) = 0;
        end
        
        for ii = 1: length (outliersQ3)
            idx = find (data == outliersQ3(ii));
            FinalData(idx,Pairs(Col):Pairs(Col)+1) = 0;
        end
        
    end
end
