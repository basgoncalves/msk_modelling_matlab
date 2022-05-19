% calc mean difference 

function [MD,LB,UB,PercDif] = meanDif (D1,D2, Alpha)

if ~exist('CI')||isempty(Alpha)
    Alpha = 0.05;
end   

idx = find(isnan(D1));% delete NaN
idx = [idx; find(isnan(D2))];
idx = unique(idx);
D1(idx) = NaN;
D2(idx) = NaN;

N = size (D1,1);

PercDif = (D2-D1)./D1*100;

MD = nanmean(PercDif);
CIdiff = nanstd(PercDif)/sqrt(N)*tinv(1-Alpha/2,N-1);
LB = MD-CIdiff;
UB = MD+CIdiff;
% 
% sprintf('Mean1 = %.1f±%.1f',mean(D1),std(D1))
% sprintf('Mean2 = %.1f±%.1f',mean(D2),std(D2))
% sprintf ('MD = %.1f (%.1f-%.1f)',MD,LB,UB)