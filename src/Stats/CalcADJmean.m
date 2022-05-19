% adjusted means 
% https://documentation.statsoft.com/STATISTICAHelp.aspx?path=Glossary/GlossaryTwo/A/AdjustedMeans
% ADJmean = GroupMean-RegressionCoefficient*(meanCovariate_group -
% grandMeanCovariate


function [M, ADJmean] = CalcADJmean(Data,Covariate)
ADJmean=[];
M=[];
for ii = 1:size(Data,2)
    A = Data(:,ii);
    [r,p] = corrcoef(Covariate,A);
    
    ADJmean(ii) = mean(A)-r(2)*mean(Covariate);
    M(ii) = mean(A);
end