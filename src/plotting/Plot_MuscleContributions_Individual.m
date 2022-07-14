function Plot_MuscleContributions_Individual

Dir = getdirFAI;

load([Dir.Results_Cont2HCF fp 'results.mat']);
load([Dir.Results_JCFFAI fp 'CEINMSdata.mat']);

savedir = ([Dir.Results_Cont2HCF fp 'IndividualData']);
if ~exist(savedir); mkdir(savedir); end

muscleNames = fields(contributions2HCF.Fx);
n_musc = length(muscleNames);

for isubj = 1%:length(Subjects)
    
    curr_subj = Subjects{isubj};
    subj_cols = find(contains(trialType,curr_subj));
    
    force_names = {'Fx' 'Fy' 'Fz' 'Fresultant'};
    
    disp(curr_subj)
    
    for iF = 1:length(force_names)
        [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(n_musc,0, 0.02, 0.05, 0.05,0.95);
        for imusc = 1:n_musc
            curr_musc = muscleNames{imusc};
            curr_force = force_names{iF};
            
            sumHCF_subject = CEINMSData.participants;                                                               
            sumHCF_subject_col = find(contains(sumHCF_subject,curr_subj));
            sumHCF_hip_var = ['hip_' strrep(curr_force,'F','')];
            
            sumHCF = [];
            sumHCF(:,1) = CEINMSData.ContactForces.(sumHCF_hip_var).RunStraight1(:,sumHCF_subject_col);             % select sum of HCF (per component) - Run 1
            sumHCF(:,2) = CEINMSData.ContactForces.(sumHCF_hip_var).RunStraight2(:,sumHCF_subject_col);             % ... Run 2
            
            if contains(curr_force,'resultant')
                
                HCFx = contributions2HCF.Fx.(curr_musc)(:,subj_cols);
                HCFy = contributions2HCF.Fy.(curr_musc)(:,subj_cols);
                HCFz = contributions2HCF.Fz.(curr_musc)(:,subj_cols);
                HCFres = sum3Dvector(HCFx,HCFy,HCFz);
                
                musc_cont_HCF = HCFres;
            else
                musc_cont_HCF = contributions2HCF.(curr_force).(curr_musc)(:,subj_cols);
            end
            
            axes(ha(imusc)); hold on
            plot(sumHCF)
            plot(musc_cont_HCF)
            title(curr_musc)   
            yaxisnice(4)
            yticklabels(round(yticks,0))
            
            if ~any(LastRow == imusc)
               xticks('') 
            else
               xticks(0:25:100)  
               xticklabels(xticks)
            end
            
            if any(FirstCol == imusc)
               ylabel(['Muscle contribution (%)']) 
            end
            
        end
        
        lg = legend({'Total HCF 1' 'muscle contribution 1' 'Total HCF 2' 'muscle contribution 2'});
        lg.Position = [0.80432 0.098511 0.048588 0.043648];
        mmfn_inspect
        suptitle(curr_force)
        saveas(gcf,[savedir fp [curr_force '_' curr_subj '.jpeg']])
        close all
    end
end


disp('plotting complete')
