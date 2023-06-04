
function run_exmple_SPM

fp = filesep;
tmp = matlab.desktop.editor.getActive;
pwd = fileparts(tmp.Filename); 
cd(pwd);
addpath(genpath(pwd));


[PatchArea,SP,IndFiG] = AnovaSPM;

ApplyBonfCorrection = 1;
[XpositionSignificant,AxesSPM,CompareLabels,Pval,MD,lCI,uCI] = TtestSPM(ApplyBonfCorrection);
%-----------------------------------------------------------------------------------------------------------------%
function [PatchArea,SP,IndFiG] = AnovaSPM

load('exampleData_AnovaSPM.mat')
Y = [];
A = [];
B = [];
SUBJ = [];
% find common subjects in Groups
for k = 1:length(ind)
    idx = find(~contains(Groups{k,2},Groups2{k,2}))';
    Groups{k,2}(idx) = [];
    ind{k}(:,idx) = []; 
end

% find common subjects in Groups2
for k = 1:length(ind)
    idx = find(~contains(Groups2{k,2},Groups{k,2}))';
    Groups2{k,2}(idx) = [];
    ind2{k}(:,idx) = []; 
end

% add data ind (pre)
for k = 1:length(ind)
    FirstCol = size(Y,2)+1;
    LastCol= FirstCol + size(ind{k},2)-1;
    Y(:,FirstCol:LastCol) = ind{k};
    A(:,FirstCol:LastCol) = k-1; % add 0,1 or 2 depending on the group (FAIS,CAM,CON)
    B(:,FirstCol:LastCol) = 0; % add 0 = first nested factor
    SUBJ(:,FirstCol:LastCol) = str2num(cell2mat(Groups{k,2}))'; % add subjects
end

% add data ind2 (post)
for k = 1:length(ind2)
    FirstCol = size(Y,2)+1;
    LastCol= FirstCol + size(ind2{k},2)-1;
    Y(:,FirstCol:LastCol) = ind2{k};
    A(:,FirstCol:LastCol) = k-1;
    B(:,FirstCol:LastCol) = 1; % add 1 = second nested factor
    SUBJ(:,FirstCol:LastCol) = str2num(cell2mat(Groups2{k,2}))'; % add subjects
end

Y=Y';
    
%% SPM
spmlist   = spm1d.stats.anova2onerm(Y, A, B, SUBJ);
spmilist  = spmlist.inference(0.05);
spmilist.plot('plot_threshold_label',false, 'plot_p_values',true, 'autoset_ylim',false);
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

%-----------------------------------------------------------------------------------------------------------------%
function [XpositionSignificant,AxesSPM,CompareLabels,Pval,MD,lCI,uCI]= TtestSPM(ApplyBonfCorrection)

fp = filesep;
load('exampleData_ttestSPM.mat')

% combinations of all the Groups comparisons possible
comb = nchoosek([1:length(GroupNames)],2); 
Alpha = 0.05;
if ApplyBonfCorrection
    Alpha = Alpha/size(comb,1);
end

% deleteNaNs
for i=1:length(GroupNames);check=any(isnan(indData{i}));indData{i}(:,check)=[];end

X ={};CompareLabels={}; MD =[]; lCI =[]; uCI =[]; Pval=[];
AxesSPM = tight_subplotBG(size(comb,1),0);
for c = 1:size(comb,1)
    
    Dataset1 = indData{comb(c,1)}; 
    Dataset2 = indData{comb(c,2)};
    spmi   = spm1d.stats.ttest2(Dataset1',Dataset2');
    spmi  = spmi.inference(Alpha);
    axes(AxesSPM(c))

    % SPM plot with p-values and t-values threshold
    spmi.plot; spmi.plot_p_values; spmi.plot_threshold_label;  
    
    CompareLabels{c}=[GroupNames{comb(c,1)} ' - ' GroupNames{comb(c,2)} ' (p< ' num2str(Alpha) ')'];
    title(['comb' num2str(c) ' = ' CompareLabels{c}])
    
   % L = Fig{c}.Children(1).Children; ShadeIdx=[]; PValueIdx=[];
    L = AxesSPM(c).Children; ShadeIdx=[]; PValueIdx=[];
    for kk = 1:  length(L)             

        %  find indexes of patches (signficand shaded areas)   
        if contains(class(L(kk)),'Patch'); ShadeIdx(end+1) = kk; end      

        %  find indexes of tesxt with 'P = ' 
        if contains(class(L(kk)),'Text') && contains(L(kk).String,'p '); PValueIdx(end+1) = kk; end      
    end
    
    % mean and CI across whole curve
    [MD(c,1),lCI(c,1),uCI(c,1)] = meanDif_arrary (Dataset1,Dataset2, Alpha,2,0); 
    X{c,1} = {};
    Pval(c,1) = spmi.p_set;

    %  loop through all significant areas and
    for kk = 1:length(ShadeIdx)             
        S = ShadeIdx(kk);
        P = PValueIdx(kk);
        Xvalues = round([L(S).XData],0);
        Xvalues(Xvalues==0)=[];
        col = kk+1;
        X{c,col} = Xvalues;

        % mean and CI for the area of each patch
        [MD(c,col),lCI(c,col),uCI(c,col)] = meanDif_arrary (Dataset1(Xvalues,:),Dataset2(Xvalues,:),Alpha,2,0); 

        % remove text and conver p-value to number
        try
            Pval(c,col) = str2num(strrep(L(P).String,'p = ',''));   
        catch 
            Pval(c,col) = str2num(strrep(L(P).String,'p < ','')); 
        end
    end
end

XpositionSignificant = X;

