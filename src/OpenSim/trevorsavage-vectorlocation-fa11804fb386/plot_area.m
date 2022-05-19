function plot_area(vecDist, lbl, dirPlot, frame)

fig = figure; hold on
for i = 1:length(vecDist)
    vecA     = vecDist(i).metadata;
    gaitcyc  = [vecA.AEgc]'; % sum([vecA.gaitcyc(1:end-1).mean].', 2);
    stance   = [vecA.AEst]'; % sum([vecA.stance(1:end-1).mean].', 2);
    loading  = [vecA.AEld]'; % sum([vecA.loading(1:end-1).mean].', 2);
    midstn   = [vecA.AEms]'; % sum([vecA.midstance(1:end-1).mean].', 2);
    latestn  = [vecA.AEls]'; % sum([vecA.latestance(1:end-1).mean].', 2);
    preswing = [vecA.AEps]'; % sum([vecA.preswing(1:end-1).mean].', 2);
    swing    = [vecA.AEsw]'; % sum([vecA.swing(1:end-1).mean].', 2);
    x = [loading midstn latestn preswing stance swing gaitcyc];
    boxplot(x);
end
%set(gca,'xtick',1:2:50)
ylim([-10 320]);
set(gca,'xticklabel',{'Loading','Midstance','Late stance','Preswing','Stance','Swing','Gait cycle'})
ylabel([frame ' frame - area from CoP to force vector(mm)'])
saveas(gcf,[dirPlot filesep 'HCFvecArea[Euclidian]_' frame '_' lbl '.png']);
savefig(fig, [dirPlot filesep 'HCFvecArea[Euclidian]_' frame '_' lbl '.fig']);
title('Euclidean method');
hold off;
 
fig = figure; hold on
for i = 1:length(vecDist)
    vecA     = vecDist(i).metadata;
    gaitcyc  = [vecA.ABdgc]'; % sum([vecA.gaitcyc(1:end-1).mean].', 2);
    stance   = [vecA.ABdst]'; % sum([vecA.stance(1:end-1).mean].', 2);
    loading  = [vecA.ABdld]'; % sum([vecA.loading(1:end-1).mean].', 2);
    midstn   = [vecA.ABdms]'; % sum([vecA.midstance(1:end-1).mean].', 2);
    latestn  = [vecA.ABdls]'; % sum([vecA.latestance(1:end-1).mean].', 2);
    preswing = [vecA.ABdps]'; % sum([vecA.preswing(1:end-1).mean].', 2);
    swing    = [vecA.ABdsw]'; % sum([vecA.swing(1:end-1).mean].', 2);
    x = [loading midstn latestn preswing stance swing gaitcyc];
    boxplot(x);
end

%set(gca,'xtick',1:2:50)
ylim([-10 320]);
set(gca,'xticklabel',{'Loading','Midstance','Late stance','Preswing','Stance','Swing','Gait cycle'})
ylabel([frame ' frame - area from CoP to force vector(mm)'])
saveas(gcf,[dirPlot filesep 'HCFvecArea[Boundary]_' frame '_' lbl '.png']);
savefig(fig, [dirPlot filesep 'HCFvecArea[Boundary]_' frame '_' lbl '.fig']);
title('Boundary method');
hold off;