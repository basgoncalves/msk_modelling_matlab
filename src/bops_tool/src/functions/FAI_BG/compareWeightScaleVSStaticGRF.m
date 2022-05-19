function compareWeightScaleVSStaticGRF (Subjects)
fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    disp(['loading ' SubjectInfo.ID])
    F = load([Dir.sessionData fp Trials.Static{1} fp 'FPdata.mat']);
    
    cols = find(contains(F.FPdata.Labels,'Fz'));
    FPweight(ff,1) = abs(mean(sum(F.FPdata.RawData(:,cols),2),1));
    ScaleWeight(ff,1)= SubjectInfo.Weight*9.81;
    
end
DiffWeight = FPweight-ScaleWeight;

DataSet = [ScaleWeight,FPweight,DiffWeight];
Labels = Subjects;
VarNames = {'Scale' 'Force plate (static trial)' 'Difference'};

f=figure; fullsizefig; hold on; ax=gca; ax.Position = [0.05 0.1 0.8 0.8];
n = length(Labels);
bar(DataSet); xticks([1:n]);
xticklabels(Labels); xtickangle(0);
ylabel('weight (N)'); 
plot([0 n],[10 10],'--k','LineWidth',5)
lg = legend([VarNames '10N']); lg.Position =[0.85 0.6 0.1 0.1];
mmfn_inspect

T=array2table(DataSet); T.Properties.VariableNames=VarNames; T.Properties.RowNames = Labels;

cd(Dir.Results)
saveas(gcf,['mass_ScaleVSForceplate.jpeg']);
xlswrite(['mass_ScaleVSForceplate.xls'],T);

