function Plot_MuscleContributions_Individual_trial(muscle_JCF_file,JCF_file,contact_force_var,saveDir)

try muscle_contributions = load_sto_file(muscle_JCF_file);
catch e; disp(e.message); end

try joint_contact_forces = load_sto_file([JCF_file]);
catch e; disp(e.message); end

if ~exist(saveDir); mkdir(saveDir); end

[~,filename] = fileparts(muscle_JCF_file);
muscle = strrep(filename,'_InOnParentFrame_ReactionLoads','');

[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(3,0, 0.05, 0.1,[0.05 0.15],[0.03 0.25 0.94 0.55]);

directions = {'_fx' '_fy' '_fz'};
Title_names = {'(-)posterior | anterior (+)' '(-)inferior | superior (+)' '(-) lateral | medial (+)'};

for i = 1:length(directions)
    curr_direction = directions{i};
    Total_CF  = joint_contact_forces.([contact_force_var curr_direction]);
    Muscle_CF = muscle_contributions.([contact_force_var curr_direction]);
    axes(ha(i)); hold on
    area(Total_CF,'FaceColor', [0.8 0.8 0.8])
    plot(Muscle_CF,'Color',[0.70 0.28 0.27],'LineWidth',3)
    
    title(Title_names{i})
    yticklabels(round(yticks,0))
    
    xticks(0:25:100)
    xticklabels(xticks)
    if i == 1
        ylabel(['Muscle contribution (N)'])
    end
end

suptitle([muscle '_' contact_force_var])
lg = legend({'Total contact force' 'muscle contribution' 'Total HCF 2' 'muscle contribution 2'});
lg.Position = [0.9013    0.4911    0.0872    0.0649];
mmfn_inspect
saveas(gcf,[saveDir fp muscle '_' contact_force_var '.jpeg'])

