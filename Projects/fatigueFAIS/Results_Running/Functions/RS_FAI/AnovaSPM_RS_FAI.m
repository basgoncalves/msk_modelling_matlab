% run two-way anova SPM
% run "splitDataInGroups_TimeVariant.m" before to get the ind data 

% The inputs are as follows:
% Y = data; A = First Factor (i.e., treatment group_; B = nested factor
% (i.e., time point); SUBJ = subject ID


function [PatchArea,F,IndFiG]= AnovaSPM_RS_FAI(ind,ind2,Subj,Subj2)

fp = filesep;

Y = [];
A = [];
B = [];
SUBJ = [];
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

% add data ind (pre)
for k = 1:length(ind)
    FirstCol = size(Y,2)+1;
    LastCol= FirstCol + size(ind{k},2)-1;
    Y(:,FirstCol:LastCol) = ind{k};
    A(:,FirstCol:LastCol) = k-1; % add 0,1 or 2 depending on the group (FAIS,CAM,CON)
    B(:,FirstCol:LastCol) = 0; % add 0 = first nested factor
    SUBJ(:,FirstCol:LastCol) = str2num(cell2mat(Subj{k,2}))'; % add subjects
end

% add data ind2 (post)
for k = 1:length(ind2)
    FirstCol = size(Y,2)+1;
    LastCol= FirstCol + size(ind2{k},2)-1;
    Y(:,FirstCol:LastCol) = ind2{k};
    A(:,FirstCol:LastCol) = k-1;
    B(:,FirstCol:LastCol) = 1; % add 1 = second nested factor
    SUBJ(:,FirstCol:LastCol) = str2num(cell2mat(Subj2{k,2}))'; % add subjects
end

Y=Y';
    
%% SPM
%(1) Conduct SPM analysis:
spmlist   = spm1d.stats.anova2onerm(Y, A, B, SUBJ);
spmilist  = spmlist.inference(0.05);
% disp_summ(spmilist);
% close all
% spmilist.plot();
spmilist.plot('plot_threshold_label',false, 'plot_p_values',false, 'autoset_ylim',false);
F = gcf;

PA ={};
for ii = 1:length(F.Children)
    L = F.Children(ii).Children;
    %     y = ;% the ve
    for kk = 1: length(L)
        PA{ii,kk} ={};
        if contains(class(L(kk)),'Patch')
            PA{ii,kk} = round([L(kk).XData],0);
        end
    end
end
PatchArea = PA;

% create individual figures
hAx = findobj(gcf,'type', 'axes');
 for iAx = 1:length(hAx)
    IndFiG(iAx) = figure;
    hNew = copyobj(hAx(iAx),  IndFiG(iAx));
    % Change the axes position so it fills whole figure
    set(hNew, 'pos', [0.12 0.12 0.8 0.8])
    yt = yticks;
    yticks(yt(1:2:end))
 end
