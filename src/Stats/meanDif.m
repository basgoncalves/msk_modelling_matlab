% calc mean difference in percentage
%Type: 1(default) = paired; 2 = independent;
% ConvertToPercentage: 1(default) = true; 0 = false;
function [MD,LB,UB] = meanDif (D1,D2, Alpha,Type,ConvertToPercentage)

if ~exist('Alpha')||isempty(Alpha);  Alpha = 0.05; end

if ~exist('Type')||isempty(Type)
    Type = 1; 
elseif contains(Type,'2-sample') || contains(Type,'independent')
    Type = 2;

elseif contains(Type,'1-sample') || contains(Type,'paired')
    Type = 1;
end

if ~exist('ConvertToPercentage')||isempty(ConvertToPercentage)
    ConvertToPercentage = 1; 
end

mean1 = mean(D1,1);
mean2 = mean(D2,1);

n1 = size (mean1,2);
n2 = size (mean2,2);

if Type == 1
    if ConvertToPercentage == 1
        D_diff = (mean2 - mean1)./mean1*100;
    elseif ConvertToPercentage == 0
        D_diff = mean2 - mean1;
    end
    
    MD = mean(D_diff);
    df = n1-1;
    CIdiff = std(D_diff)/sqrt(n1)*tinv(1-Alpha/2,df);
    LB = MD-CIdiff;
    UB = MD+CIdiff;
    
elseif Type == 2      % https://sphweb.bumc.bu.edu/otlt/mph-modules/bs/bs704_confidence_intervals/bs704_confidence_intervals5.html
    
    MD = mean(mean2)-mean(mean1);
    
    std1 = std(mean1);
    std2 = std(mean2);
    
    df = n1+n2-2;
    t = tinv(1-Alpha/2,df);
    var1= (n1-1)*std1^2;
    var2= (n2-1)*std2^2;
    pooledSE = sqrt((var1 + var2) / df) * sqrt(1/n1+1/n2);
    
    CIdiff = pooledSE*tinv(1-Alpha/2,df);
    LB = MD-CIdiff;
    UB = MD+CIdiff;
    
end

