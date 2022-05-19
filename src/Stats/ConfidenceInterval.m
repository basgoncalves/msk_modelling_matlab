function [M,lCI,uCI,CI] = ConfidenceInterval (Y,A)


if nargin < 2 || isempty(A)
    A = 0.05;
end

Y(isnan(Y)) = [];
N = length(Y);
if N <2; M = mean(Y);lCI=NaN;uCI=NaN;CI=NaN;return;end

[H, ~, ~] = swtest(Y, 0.05); % normality of the difference

if H == 0       % if data is normal
    M = mean(Y);
    t = tinv(1-A/2,N);
    lCI = M - std(Y)/sqrt(N)*t;
    uCI = M + std(Y)/sqrt(N)*t;
    CI = abs(uCI- M);
elseif H == 1  % if data is non-normal
    % https://www.youtube.com/watch?v=4qkqM3VNmaQ
    % https://academic.oup.com/jat/article/39/2/113/762036
    bootstat = bootstrp(2000,@mean,Y);
    %     figure;histogram(bootstat(:,1));
    M = mean(bootstat);
    bootstat = sort(bootstat);
    lCI = bootstat(floor(A/2*2000));
    uCI = bootstat(ceil((1-A/2)*2000));
    CI = abs(uCI- M);
end
% https://au.mathworks.com/help/stats/prob.normaldistribution.random.html#f1131670_sep_shared-pd
% rng('default') % restart "random"
% pd = makedist('normal',0,1); %creTE A DISTRIBUTION
% r = random(pd,10000,1);
% figure;histogram(r(:,1));