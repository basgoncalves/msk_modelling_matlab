%% Description 
% Goncalves, BM (2018)
% this function plots all the intra individual CV with CI 
%
% simple script to organize data into different cell matrices
% converts a data series (double) in Nx2 a cell matrix
%
% INPUT
%   data = NxM double matrix.
%          N =  number of particiants (rows)
%          M = number of columns grouped by Ntrials per condition
%          example data (each column): 
%          Var1_Cond1_trial | Var1_Cond1_trial2 | Var1_Cond2_trial | Var1_Cond2_tria2....  
%
%   Ntrials (not required) = number of trials per condition
%
%   Cond (not rquired)= 1xN cell array with N conditions associated with your data
%
%   varNames (not required) =  1xN cell array with N variables associated
%   with your data

%% Start function
function [Cond, varNames,out] = orgCV (data,Ntrials,Cond,varNames)

%% Defines number of trails (nCol), variables
% Change variables names ans conditons acordint to your own data
if nargin == 1
    Ntrials = 2;                                            % default number of trials per condition
end

[~,lenData] = size (data);                                  % number of columns (trials*conditions*variables)

%names of the conditions (change acocrdingly)
if nargin <= 2
    
    Cond = {'Condition 1'};
    nCon = length (Cond);                                       % define only one conditions
else
    
    nCon = length (Cond);                                       % number of conditions
end

%names of the variable in each condition (change accordingly)
if nargin <= 3
    for n = 1:Ntrials:lenData                                           % loop through every column jumping every Ntrials
        NameVar = sprintf ('var%d', n);                                 % create a random name for a variable
        varNames{n} = NameVar;
        nVar = length (varNames);                                       %number of variables
        
    end
    
else
    nVar = length (varNames);                                       %number of variables
end

if nCon*nVar*Ntrials ~= lenData                                        % number of conditions * number of variables * number of trials
    fprintf ('ERROR : number of columns does not match the number of varibles \n \n Change lines 23 and 27 in the script \n \n')
    clear out cond varNames
    return
end

%%
out = Cond;                                                           % final output data

count = 1;                                                            % uses to add a row for each new condition in the final variable

for col = 1:Ntrials:(nCon*Ntrials-1)                                  % go throught each condition (jump Ntrials columns for each condition)
    a=1;
    for i= col:Ntrials*nCon:lenData                                      % loop through each variable 
        temp_data {1,a} = varNames{a};                                   % 1st row = names of each variable
        temp_data {2,a} = data(:,i:i+Ntrials-1);                         % 2nd row = force data
        a=a+1;
    end
    out{count,2}= temp_data;                                       %add data to final variable
    count =count+1;                                             %move to next condition
end

