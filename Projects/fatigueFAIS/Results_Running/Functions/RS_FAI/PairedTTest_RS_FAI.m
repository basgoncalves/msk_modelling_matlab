% run post hoc paired tttest
% run "splitDataInGroups_TimeVariant.m" before to get the ind data 

% The inputs are as follows:
% Y = data; A = First Factor (i.e., treatment group_; B = nested factor
% (i.e., time point); SUBJ = subject ID


function [F1,A1]= PairedTTest_RS_FAI(ind,ind2,Subj,Subj2)

fp = filesep;

% find common subjects in Subj
for k = 1:length(ind)
    idx = find(~contains(Subj{k,2},Subj2{k,2}))';
    Subj{k,2}(idx) = [];
    ind{k}(:,idx) = []; 
end

% find common subjects in Subj2
for k = 1:length(ind)
    idx = find(~contains(Subj2{k,2},Subj{k,2}))';
    Subj2{k,2}(idx) = [];
    ind2{k}(:,idx) = []; 
end

% calculate alpha 
alpha = 0.05;
nTests = length(ind);
p_critical = spm1d.util.p_critical_bonf(alpha, nTests);

MainFig = figure;
comb = combntns([1:3],2);
tt = {'CON (Pre vs Post)','FAIS (Pre vs Post)','CAM  (Pre vs Post)'};
% run tests
for k = 1: length(ind2)
f = figure;
Y1 = ind{1,k}';
Y2 = ind2{1,k}';
t   = spm1d.stats.ttest_paired(Y1,Y2);
t  = t.inference(p_critical);
t.plot();
title(tt{k})
f.CurrentAxes.FontSize = 40;
mergeFigures (f, MainFig,[1,3],k)
close (f)
end

fullscreenFig(0.8,0.8)

PA ={};
F1= gcf;
for ii = 1:length(F1.Children)
    L = F1.Children(ii).Children;
    %     y = ;% the ve
    for kk = 1: length(L)
        PA{ii,kk} ={};
        if contains(class(L(kk)),'Patch')
            PA{ii,kk} = round([L(kk).XData],0);
        end
    end
end
A1 = PA;
