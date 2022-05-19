% Calculate Effect size after Mann-Whitney  in SPSS
% from Tomczak&Tomczak (2014) 
% http://www.wbc.poznan.pl/Content/325867/5_Trends_Vol21_2014_ no1_20.pdf
%
% Z = Zscore from M-W test
% N = Total number of data points 

function [ES] = ES_Mann_Whitney (Z,N)

% Eta squared 
ES = Z^2/N;

