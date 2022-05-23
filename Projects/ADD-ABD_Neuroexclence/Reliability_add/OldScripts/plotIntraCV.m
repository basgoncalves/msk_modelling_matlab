%% Description 
% Goncalves, BM (2018)
% this function plots all the intra individual CV with CI 
%
% 
% CALLBACK FUNCIONS
%   CVtable
%   orgCV 
%   intraCV
%
% INPUT 
%   rawdata = NxM double matrix.
%             N =  number of particiants (rows)
%             M = number of columns grouped by Ntrials per condition
%             example data (each column): 
% Var1_Cond1_trial | Var1_Cond1_trial2 | Var1_Cond2_trial | Var1_Cond2_tria2....  
%
%   Ntrials (not required) = number of trials per condition
%
%   Cond (not rquired)= 1xN cell array with N conditions associated with your data
%
%   varNames (not required) =  1xN cell array with N variables associated
%   with your data
%
%-------------------------------------------------------------------------
%OUTPUT
%   CV_data = a Nx2 cell Matrix; N = number of conditions; 2nd column = CV data for all 
%             CV data for each condition is a NxM table; N = number of variables; M = number of  
%             call the CV for each CONDITION using the example 'CV_data{n,2}.CV 
%             call the CV for each VARIABLE using 'CV_data{n,2}.CV(a)'
%
%   varNames = names of the VARIABLES determined in the function orgCV
%
%   cond = names of the CONDITIONS determined in the function orgCV
%
%--------------------------------------------------------------------------
% REFERENCES 
%
%Knutson, LM, Soderberg, GL, Ballantyne, BT, and Clarke, WR. A study of
%various normalization procedures for within day electromyographic data. J
%Electromyogr Kinesiol 4: 47–59, 1994.
% 
% Field, A. Discovering Statistics Using SPSS (and sex and drugs and rock
% “n” roll). 3rd ed. SAGE Publications, Ltd, 2009.
%
% https://au.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval
%% Start function
function [iCVmean,iCV,varNames,cond,graph] =  plotIntraCV (rawdata,Ntrials,Cond,varNames)

%% Get the CV and respective CI for each strength 
% variable (eg. Max and RFD). create a table with the intra-individual CV.  

if nargin == 1
[iCVmean,iCV,varNames,cond] = CVtable (rawdata);


end

CV=[];
[nCV,~] = size (iCVmean);                     % number of conditions (rows)
nVar = length(varNames);                      % the number of variables to plot

for i = 1: nCV
    iCVmean{i,2}                              
    CV(1:nVar,i)= iCVmean{i,2}.CV;            %checks the CV results from the table in the 2nd column 
                                              % of the cell matrix (see intro)  
    
    CV_description{1,i} = iCVmean{i,1};
end


lCV=[];                                       % lower confidence interval


for ii = 1:nCV
    lCV(1:nVar,ii)=iCVmean{ii,2}.lCV;
end

meanCV = CV';                                 % mean intra individual CV
rangeCV = (CV-lCV)';                          % range of the CV
figure
hold on
graph = bar(1:nVar,meanCV');

% For each set of bars, find the centers of the bars, and write error bars
pause(0.1);                                   %pause allows the figure to be created
for ib = 1:numel(graph)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = graph(ib).XData+graph(ib).XOffset;
    errorbar(xData,meanCV(ib,:),rangeCV(ib,:),'k.');
end

%% graph parameters
xticklabels(varNames)
xticks(1:nVar)
xlabel('Force variables')                                       % x-axis label
ylabel({'CV% with 95%CI'})                                      % y-axis label
set(get(gca,'ylabel'),'fontsize',12)                            %size x label 12
set(get(gca,'xlabel'),'fontsize',12)                            %size y label 12

set(gcf,'Position',[400 500 700 500])                           % resize the figure

set(gca,'position',[0.25 0.2 0.7 0.7])                          % resize/reposition the grpah 

set(get(gca,'ylabel'),'rotation',0)                             % set y label rotation 
set(get(gca,'ylabel'),'position',[-0.6 3])                      % set y label position [x_position y_position]
legend (cond);
title ('Mean Intra-individual CV for each postion and strength variable');
set(gca,'FontName', 'Times New Roman')


%change colors to gray
[~,x] = size (graph);
grayColors = [0.2 0.2 0.2;0.3 0.3 0.3;0.75 0.75 0.75;0.9 0.9 0.9]; %same values for each RGB element = gray
for c = 1:x
   g = grayColors (c,:); 
   graph(c).FaceColor = g; 
end

% save CV_add iCVmean iCV varNames cond graph


