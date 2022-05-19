function plot_d_AvVec(vecDist, lbl, dirPlot, frame)

fig = figure; hold on
for i = 1:length(vecDist)
    dvec     = vecDist(i).dmvec;
    gaitcyc  = [vecDist(i).metadata(1:end-1).dcop_gc].';
    stance   = [dvec.stance(1:end-1).mean].';
    loading  = [dvec.loading(1:end-1).mean].';
    midstn   = [dvec.midstance(1:end-1).mean].';
    latestn  = [dvec.latestance(1:end-1).mean].';
    preswing = [dvec.preswing(1:end-1).mean].';
    swing    = [dvec.swing(1:end-1).mean].';
    x = [loading midstn latestn preswing stance swing gaitcyc];
    boxplot(x);
end
%set(gca,'xtick',1:2:50)
set(gca,'xticklabel',{'Loading','Midstance','Late stance','Preswing','Stance','Swing','Gait cycle'})
ylabel([frame ' frame - vector distance from mean phase CoP (mm)'])
saveas(gcf,[dirPlot filesep 'HJCFvecVariance_' frame '_' lbl '.png']);
savefig(fig, [dirPlot filesep 'HJCFvecVariance_' frame '_' lbl '.fig']);