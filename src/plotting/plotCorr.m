% %% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% create a scatter plot and a line of best fit with a shaded area as CI 
%
%INPUT  
%   x = x axis values
%   y = y axis values
%   n = polynomial degree (Default = 1)
%   Alpha = alpha level betwen 0 and 1(Default = 0.05)
%   Color = color of the plots (Default = black)
%   MakerSize = size of the individual markers (Default = 10)
%-------------------------------------------------------------------------
%OUTPUT
%   rsquared = cell matrix maximum Force value
%   pvalue = cell matrix maximum Force value
%   p1 = handle of the plot 
%
%% plotCorr
function [rsquared,pvalue, p1,rlo,rup] = plotCorr (x,y,n,Alpha,Color, MakerSize)

if nargin > 2
    [x,y] = create_test_data;
    figure;
end

if  nargin < 3 || isempty(n)
    n = 1;
end
if nargin < 4 || isempty(Alpha)
    Alpha= 0.05;
end

if  nargin < 5 || isempty(Color)
    Color= 'k';
end

if  nargin < 6 || isempty(MarkerSize)
    MakerSize= 10;
end

% delete nan
IDXnan = any(isnan([x y]),2); 
x(IDXnan)=[];
y(IDXnan)=[];


% calculate polynomial and line that best fit 
[p,S,mu] = polyfit(x,y,n); 
[y_fit,delta] = polyval(p,x,S,mu);

% calculate rsquared and p-value
[c, pvalue,rlo,rup] = corrcoef(x,y);
rsquared = c(1,2)^2;
pvalue = pvalue(1,2);
rlo = rlo(1,2);
rup = rup(1,2);

% calculate t-statistic 
t = tinv(1-Alpha/2,S.df);
 
% calculate confidence interval
uB = y_fit+ t*delta;
lB = y_fit- t*delta;

% sort data 
p = sortrows([x y y_fit uB lB],1);                                
x= p(:,1)';
y= p(:,2)';
y_fit= p(:,3)';
uB= p(:,4)';
lB= p(:,5)';

% plot individuals data points
hold on;
p1 = plot(x,y,'o','MarkerSize',MakerSize,'MarkerFaceColor',Color,'MarkerEdgeColor','none');

% plot mean trendline
p1(end+1) = plot(x,y_fit,'Color',Color,'LineWidth',2);              

% plot shaded confidence limits
X=[x,fliplr(x)]; % create continuous x value row vector for plotting
Y=[lB fliplr(uB)]; % create y values for out and then back (Remove NaN)
f1 = fill(X,Y,'r');
alpha 0.2  % transparency                                                          
set(f1,'FaceColor', Color,'EdgeColor','none')


%-----------------------------------------------------------------------------------------------------------------%
function [x,y] = create_test_data()

rng('default');  % Set the random number generator seed for reproducibility

% Parameters
n = 100;  % Number of data points
num_outliers = 3;  % Number of outliers
outlier_range = [-10, 10];  % Range of values for the outliers

x = randn(n, 1);

% Generate Y vector with correlation coefficient of 0.9
y = 0.9 * x + sqrt(1 - 0.9^2) * randn(n, 1);

% Introduce outliers
outlier_indices = randperm(n, num_outliers);  % Randomly select outlier indices
y(outlier_indices) = outlier_range(1) + (outlier_range(2) - outlier_range(1)) * rand(num_outliers, 1);
