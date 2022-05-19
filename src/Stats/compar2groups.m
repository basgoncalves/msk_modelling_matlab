% Basilio Goncalves
% Y1&Y2 = column vector for the two groups to compare
% alpha = significance level (default = 0.05)
% type = paired (1=default) or independent (2)

function [H,P,Npvalue,MD,uCI,lCI] = compar2groups(Y1,Y2,A,TYPE)


if nargin < 3 || isempty(A)
    A = 0.05;
end

if nargin < 4  || isempty(TYPE)
    TYPE = 1;
end


if TYPE == 1 % paired Ttest
    [H, Npvalue, W] = swtest(Y2-Y1, 0.05); % normality of the difference
    
    if H == 0       % paired Ttest
        [H,P,CI,STATS] = ttest(Y1,Y2,'alpha',A);
    elseif H == 1  % Wilcoxon signed-rank test (Mann-Whitney U test)
        [P,H,STATS] = ranksum(Y1,Y2,'alpha',A);
    end
    [MD,lCI,uCI] = ConfidenceInterval (Y2-Y1,A);
elseif TYPE == 2 % independent Ttest
    
    [H1, Npvalue(1), W] = swtest(Y1, 0.05); % normality for group 1
    [H2, Npvalue(2), W] = swtest(Y1, 0.05); % normality for group 2
    
    if H1 == 0 && H2 == 0  % independent Ttest
        [H,P,CI,STATS] = ttest2(Y2,Y1,'alpha',A);
    else % Wilcoxon signed-rank test (Mann-Whitney U test)
        [P,H,STATS] = ranksum(Y2,Y1,'alpha',A);
        [~,~,CI,~] = ttest2(Y1,Y2,'alpha',A);
    end
       
    fprintf('mean difference for independent samples = difference in the means\n')
    MD = nanmean(Y2) - nanmean(Y1);
    lCI = CI(1); 
    uCI= CI(2);
end




