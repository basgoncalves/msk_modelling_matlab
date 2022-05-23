% Anova Spatiotemporal
% run individual anova for each  [p,t] = ANOVAIsomStrengthFAI_PerTask(TorqueData,Groups,Conditions)
%
% see: https://au.mathworks.com/help/stats/anovan.html
% Data: columns = signgle indidependent variable (compination of all
% factors)
function [p,t,PostHoc] = ANOVASpatioTemporal(Data,F1,F2)


[Nrow,Ncol] = size(Data);
t = struct;
p =[];

y = [];
g1 = {};
g2 = {};
for c = 1:Ncol % loop throught each col (each condition "Conditions")
    
    LastRow = length(y);
    % torque data
    y(LastRow+1:LastRow+Nrow,1) =  Data(:,c);
    
    g1(LastRow+1:LastRow+Nrow) = F1(c); % factor 1
    g2(LastRow+1:LastRow+Nrow) = F2(c); % factor 2
end

% run anova
[p,t,stats,~] = anovan(y,{g1 g2},'model','interaction');

[PostHoc,means,h,gnames] = multcompare(stats,'ctype','bonferroni');
