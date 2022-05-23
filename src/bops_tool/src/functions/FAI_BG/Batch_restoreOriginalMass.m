function Batch_restoreOriginalMass(Subjects)
fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    disp(['adjusting mass ' SubjectInfo.ID])
    
    if exist(Dir.OSIM_LO_HANS_originalMass)
        disp('model already exists')
        continue
    else
        [mass_original_model,mass_model_to_adjust,mass_out_model,body_names] = restoreOriginalMass(Dir.OSIM_LinearScaled,Dir.OSIM_LO_HANS, Dir.OSIM_LO_HANS_originalMass);
    end
    DataSet = [mass_original_model,mass_model_to_adjust,mass_out_model];
    Labels = body_names;
    VarNames = {'original masses' 'rra model' 'restored model'};
    
    f=figure; fullsizefig; hold on;
    ax=gca; ax.Position = [0.05 0.1 0.8 0.8];
    n = length(Labels);
    bar(DataSet); xticks([1:n]);
    xticklabels(Labels); xtickangle(0);
    ylabel('mass (kg)');
    lg = legend([VarNames]); lg.Position =[0.85 0.6 0.1 0.1];
    mmfn_inspect
    
    cd(Dir.Results_RRA)
    saveas(gcf,['mass_restored.jpeg']);
    close all
end
