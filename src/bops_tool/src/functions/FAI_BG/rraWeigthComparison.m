function rraWeigthComparison(Subjects)
fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    disp(['loading ' SubjectInfo.ID])
    TrialList = Trials.CEINMS;
    for t = 1:length(TrialList)
        [osimFiles] = getosimfilesFAI(Dir,TrialList{t}); % also creates the directories
        [m(t),NR,OR,residuallabels] = LoadResultsRRALog([osimFiles.RRA fp 'out.log']);
    end
    
    if any(m==0); error(''); end
    massAdjustments(ff,1)=nanmean(m);
    
end

DataSet = [massAdjustments];
Labels = Subjects;
VarNames = {'total mass adjsutments'};

f=figure; fullsizefig; hold on; ax=gca; ax.Position = [0.05 0.1 0.8 0.8];
n = length(Labels);
bar(DataSet); xticks([1:n]);
xticklabels(Labels); xtickangle(0);
ylabel('weight (kg)'); 
plot([0 n],[10 10],'--k','LineWidth',5)
plot([0 n],[-10 -10],'--k','LineWidth',5)
lg = legend([VarNames]); lg.Position =[0.85 0.6 0.1 0.1];
mmfn_inspect

T=array2table(DataSet); T.Properties.VariableNames=VarNames; T.Properties.RowNames = Labels;

cd(Dir.Results)
saveas(gcf,['mass_ScaleVSForceplate.jpeg']);
xlswrite(['mass_ScaleVSForceplate.xls'],T);

