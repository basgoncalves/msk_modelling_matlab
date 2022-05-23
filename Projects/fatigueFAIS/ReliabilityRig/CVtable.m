%% Description 
% Goncalves, BM (2018)
% this function plots all the intra individual CV with CI 
%
% this function compiles all the CV and respective CI for each strength 
% variable (eg. Max and RFD) in a table using the intraCV function.  

% CALLBACK FUNCTIONS
%   orgCV 
%   intraCV

%INPUT 
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
%
%OUTPUT
%   CV_data = a Nx2 cell Matrix; N = number of conditions; 2nd column = CV data for all 
%             CV data for each condition is a NxM table; N = number of variables; M = number of  
%             call the CV for each CONDITION using the example 'CV_data{n,2}.CV 
%             call the CV for each VARIABLE using 'CV_data{n,2}.CV(a)'
%
%   varNames = names of the VARIABLES determined in the function orgCV
%
%   cond = names of the CONDITIONS determined in the function orgCV


%% Start Function  
function [iCV_mean,iCV,varNames,cond] = CVtable (data,Ntrials, Cond,varNames)

% organize data from the Raw matrix

if nargin ==1
[cond, varNames,force] = orgCV (data); 

elseif nargin ==2 
[cond, varNames,force] = orgCV (data,Ntrials);

elseif nargin ==3
[cond, varNames,force] = orgCV (data,Ntrials,Cond);
    
elseif nargin ==4
[cond, varNames,force] = orgCV (data,Ntrials,Cond,VarNames);

end


iCV_mean = cond;                                             %create output cell data with each condition in the first column 
iCV = cond;
[Ncond,~] = size(force);                                 % number of conditions (rows)

for i= 1: Ncond                                              % loop through each condition
    
condition = force{i,2};                                  % 2xM cell matrix; M = number of variables in condition; 2nd row = data for each condition   
conditionName = force{i,1};
[~,nVar] = size (condition);                                 % number of variables (columns) in each cell matrix 

CV =[];
lCV=[];
uCV=[];

% calculate the individual CV for each variable (Fmax, RFDmax...)
for ii= 1:nVar
    [CVm,indCV,CI,pNorm] = intraCV (condition{2,ii},95);    %calculate the intra-individual CV 
    CV(ii,1) = CVm;
    iCVtemp(:,ii) = indCV;                                  
    lCV(ii,1) = CI(1);
    uCV(ii,1) =  CI(2);
    p(ii,1)= pNorm; 
end
iCV {i,2}=iCVtemp; 
iCV_mean{i,2} =  table(varNames,CV,lCV,uCV,p);
end





