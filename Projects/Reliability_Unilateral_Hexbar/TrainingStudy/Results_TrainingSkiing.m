%% results Training J McPhail (Basilio Goncalves, 2021)
clc; clear; close all;
fp = filesep;
tmp = matlab.desktop.editor.getActive; pwd=fileparts(tmp.Filename);
SaveDir = [pwd]; 
CD='';while ~contains(CD,'DataProcessing-master'); [pwd,CD]=fileparts(pwd);end
pwd=[pwd fp CD];cd(pwd); addpath(genpath(pwd));
cd(SaveDir);
DataSet = readtable([SaveDir fp 'freeski_intervention_pre_and_post_results.csv']);

VarNames = DataSet.Properties.VariableNames;  
PreIdx = find(contains(VarNames,'pre'));        
PostIdx = find(contains(VarNames,'post'));
Ylbs = {'height (m)' 'height (m)' 'time (s)' 'a.u.' 'Force (N)' 'Force (N)'};
Titles = {'Countermovement jump' 'Drop jump (height)' 'Drop jump (contact time)' 'Drop jump (reactive strength index)' 'Unilateral hex bar MVIC (left leg)' 'Unilateral hex bar MVIC (right leg)'};

N = length(DataSet.(VarNames{PreIdx(1)}));
Ncomparisons = length(PreIdx);
A = 0.05;
M=[];CI=[]; H=[];MD=[];lCI=[];uCI=[];Npvalue=[];MDPercent=[];
IndivData=[];IndivData(1:N,1)=1;IndivData(N+1:N*2,1)=2;

[ha, pos,FirstCol, LastRow] = tight_subplotBG(Ncomparisons,0,0.08,0.05,0.08,[380 310 1100 600]);
for v= 1:Ncomparisons 
    Pre = DataSet.(VarNames{PreIdx(v)});
    Post = DataSet.(VarNames{PostIdx(v)});
    [M(v,1),lCI(v,1),uCI(v,1)]=ConfidenceInterval(Pre);
    [M(v,2),lCI(v,2),uCI(v,2)]=ConfidenceInterval(Post);
    IndivData(1:N,v+1)=Pre;
    IndivData(N+1:N*2,v+1)=Post;
    
    [MDPercent(v),LB(v),UB(v)]=meanDif(Pre,Post,A); % medn diff percentage
    [H(v),P(v),Npvalue(v),MD(v),MDuCI(v),MDlCI(v)] = compar2groups(Pre,Post,A,1);
%     P(v) = P(v)*Ncomparisons;
    axes(ha(v)); hold on; xlim([0 3]);
    for r=1:length(Pre)
        plot([1 2],[Pre(r) Post(r)],'Color',[0.5 0.5 0.5],'Marker','o','LineStyle','--'); 
    end
    plot([1 2],M(v,:),'Color',[0 0 0],'Marker','^','MarkerFaceColor',[0 0 0],'LineWidth',2); 
    if H(v)==1
        yt = get(gca, 'YTick');
        xt = [1 2]; 
        plot(xt, [1 1]*max(yt)*1.1, '-k',  mean(xt), max(yt)*1.15, '*k')
    end
    
    xticks([1 2]);
    if any(v==LastRow);  xticklabels({'Pre' 'Post'});
    else; xticklabels({'' ''}); end
    
    yticklabels(yticks) 
    ylabel(Ylbs{v})
    
    title(Titles{v});
    trialName = strrep(VarNames{PreIdx(v)},'pre_','');
%     mmfn_Joni('',Ylbs{v})
%     saveas(gca,[SaveDir fp trialName '.jpeg' ])
end
mmfn_Joni
saveas(gca,[SaveDir fp 'Results.jpeg' ])

figure; radarplot_RSFAI(abs(MDPercent))

Pre={}; for v=1:Ncomparisons;Pre{v}=sprintf('%.2f(%.2f to %.2f)',M(v,1),lCI(v,1),uCI(v,1));end
Post={}; for v=1:Ncomparisons;Post{v}=sprintf('%.2f(%.2f to %.2f)',M(v,2),lCI(v,2),uCI(v,2));end
Pvalue={}; for v=1:Ncomparisons;Pvalue{v}=sprintf('%.3f',P(v));end
MeanDiff={}; for v=1:Ncomparisons;MeanDiff{v}=sprintf('%.2f(%.2f to %.2f)',MD(v),MDlCI(v),MDuCI(v)) ;end
FirstCol = [strrep(VarNames(PreIdx),'pre_','')]';
Headings = {' ' 'Pre' 'Post' 'Mean Difference' 'P-value'};
table2word(Headings,[FirstCol Pre' Post' MeanDiff' Pvalue'],'Table.docx','Means and CI')

close all
