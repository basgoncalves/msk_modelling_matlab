% OGdata = [NxM] double


function [CleanData,Outliers] = rmoutliers(OGdata)

CleanData = OGdata;
Outliers = [];
for ii = 1: size(CleanData,2)
    [Q,IQR,outliersQ1, outliersQ3] =  quartile(CleanData(:,ii));
    x1 = length(outliersQ1);
    x2 = length(outliersQ3);
    if ~isempty(outliersQ1)
        [idx,~] = find(CleanData(:,ii)==outliersQ1');
        idx = unique(idx);
        CleanData(idx,ii) =NaN;
        Outliers(1:x1,ii) = idx;
    end
    
   
    if ~isempty(outliersQ3)
        [idx,~] = find(CleanData(:,ii)==outliersQ3');
        idx = unique(idx);
        CleanData(idx,ii) =NaN;
        Outliers(x1+1:x1+x2,ii) = idx;
    end
end