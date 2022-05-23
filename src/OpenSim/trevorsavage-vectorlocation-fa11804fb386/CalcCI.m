function CI = CalcCI(SD, n)

% CI = +/- z * (SD/sqrt(n))

% where z = ...
% 99% 	2.576
% 98% 	2.326
% 95% 	1.96
% 90% 	1.645

%% Set the level of confidence
z = 1.96; % 95%, change this value to correspond with the above if higher/lower are required

%%
CI =  z * (SD/sqrt(n));