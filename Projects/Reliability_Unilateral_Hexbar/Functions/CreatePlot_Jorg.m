
function CreatePlot_Jorg(DataSet,FullYaxis,Horizontal)


if Horizontal == 0
    [ha, ~] = tight_subplotBG(2,1,0.05,0.12,0.15,[960    75   547   892]);
else
    [ha, ~] = tight_subplotBG(1,2,0.05,0.12,0.15,[280 200 1300 500]);    
end
Variables = {'MaxForce' 'MaxForce_BW'};
Ylb = {'Force (N)' 'Force (N/kg)'};
Sex = {'male' 'female'};
Leg = {'left' 'right'};
lg = {Sex {}};
for v = 1: length(Variables)
    Nmale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{1}),Variables{v}});
    Nfemale = length(DataSet{ismember(DataSet.Leg,Leg{1})& ismember(DataSet.Sex,Sex{2}),Variables{v}});
    Nmax = max([Nmale Nfemale]);
    D = struct;
    Ind = []; 
    M = []; lCI =[]; uCI=[];
    for S = 1:length(Sex)
        for L = 1:length(Leg)
            CurrentData = DataSet...
                {ismember(DataSet.Leg,Leg{L})& ismember(DataSet.Sex,Sex{S}),Variables{v}};
            CurrentData(end+1:Nmax) = NaN;
            D.([Sex{S} '_' Leg{L}]) = CurrentData;
            [M(end+1),lCI(end+1),uCI(end+1)] = ConfidenceInterval(CurrentData,0.05);

            rows = [size(Ind,1)+1:size(Ind,1)+Nmax];
            
            Ind(rows,1) = length(M);
            Ind(rows,2) = [CurrentData];
        end
    end
   
    CI = uCI-M;
    axes(ha(v))
    
    if Horizontal == 0
        Xt = {['' '' '' '']  fields(D)};
        PlotJM_Reliability(M,CI,Ylb{v},Xt{v},[],[],Ind,12,15)
        yt = get(gca, 'YTick');
        
        if FullYaxis == 1
            axis([xlim    0  ceil(max(yt)*1.2)])
            yticks(0:max(ylim)/5:max(ylim))
            yticklabels(round(yticks,0))
        end
        xt = [1.5 3.5];
        hold on
        plot(xt, [1 1]*max(yt)*1.1, '-k',  mean(xt), max(yt)*1.15, '*k')
        yticklabels(round(yticks,0))
        
    else
        Xt = {fields(D) ['' '' '' '']};
        PlotJM_Reliability_Horizontal(M,CI,Ylb{v},Xt{v},[],[],Ind,12,15)
        xt = get(gca, 'XTick');
        
        if FullYaxis == 1
            axis([0  ceil(max(xt)*1.2) ylim])
            xticks(0:max(xlim)/5:max(xlim))
        end
        yt = [1.5 3.5];
        hold on
        plot([1 1]*max(xt)*1.1,yt, '-k',  max(xt)*1.15,  mean(yt),'*k')
        xticklabels(round(xticks,0))
    end
     
end