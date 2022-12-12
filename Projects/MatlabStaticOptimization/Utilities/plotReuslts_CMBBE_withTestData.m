

function plotReuslts_CMBBE_withTestData(savedir)

fp = filesep;

mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData'] ; % Base Directory to base results directory.

if nargin < 1
    savedir = [tesdataDir fp 'figures'];
end

if ~isfolder(savedir)
    mkdir(savedir)
end

legs = {'l' 'r'};
for iLeg = 1:2
    l = lower(legs{iLeg});

    if contains(l,'l'); leg = 'left';
    else; leg = 'right';
    end

    load(['results_' l '.mat'])
    %% plot external biomech
    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(2,3);
    kinematics_color = [0.5 0.5 0.1];

    % plot kinematics
    axes(ha(1))
    plotShadedSD(mean(ik.hip_flexion,2),std(ik.hip_flexion,0,2),kinematics_color);
    ylabel('joint angle (deg)')

    axes(ha(2))
    plotShadedSD(mean(ik.knee_angle,2),std(ik.knee_angle,0,2),kinematics_color);

    axes(ha(3))
    plotShadedSD(mean(ik.ankle_angle,2),std(ik.ankle_angle,0,2),kinematics_color);

    % plot moments
    first_moments_plot = 4;
    axes(ha(first_moments_plot))
    plotShadedSD(mean(id.hip_flexion,2),std(id.hip_flexion,0,2),kinematics_color);
    ylabel('joint moment (Nm)')
    xlabel('Gait cycle(%)')

    axes(ha(first_moments_plot+1))
    plotShadedSD(mean(id.knee_angle,2),std(id.knee_angle,0,2),kinematics_color);
    xlabel('Gait cycle(%)')

    axes(ha(first_moments_plot+2))
    plotShadedSD(mean(id.ankle_angle,2),std(id.ankle_angle,0,2),kinematics_color);
    xlabel('Gait cycle(%)')

    tight_subplot_ticks(ha,LastRow,0)
    mmfn_inspect
    saveas(gcf,[savedir fp 'ExtBiomech_results_' l '.tiff'])
    close all
    %% plot muscle forces
   
    last_plot_not_muscle = 0;
    penalties = fields(muscleForces); 
    Plot_colors = colorBG(0,length(penalties));

    muscles_of_to_plot = {'recfem' 'ilio_psoas' 'tfl' 'sart' 'glmax_all' 'glmed_all' 'glmin_all' 'adductors' 'vasti' 'hamstrings' 'gastroc' 'soleus' };
    muscle_titles = {'recfem' 'ilio_psoas' 'tfl' 'sart' 'glmax' 'glmed' 'glmin' 'adductors' 'vasti' 'hamstrings' 'gastroc' 'soleus' };
    legend_Iterations = {'normal recfem function' 'inhibition 10' 'inhibition 100' 'inhibition 500' 'inhibition 1000'};

    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(muscles_of_to_plot),0,[0.01 0.02],[],[0.03 0.08]);
    trap_MF = [];

    for iMuscle = 1:length(muscles_of_to_plot)                                                                      % loop through muscles
        for iPen = 1:length(penalties)                                                                              % loop through penalties
            axes(ha(last_plot_not_muscle+iMuscle))

            MuscleName = muscles_of_to_plot{iMuscle};
            force_data = muscleForces.([penalties{iPen}]).(MuscleName);
            
            if contains(MuscleName,'recfem')
                trap_MF(end+1, :) = trap.muscleForces.([penalties{iPen}]).([MuscleName '_' l]);
            end

            plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));                              % plot mean and SD

            if any(iMuscle == FirstCol)
                ylabel('Muscle force (N)')                                                                          % ylabels
            else
                yticks('')                                                                                          % yticks
            end
            if any(iMuscle == LastRow)
                xlabel('Gait cycle(%)')                                                                             % xlabels
            end
        end
        ylim([0 3500])                                                                                              % ylim
        t = title(muscle_titles{iMuscle},'Interpreter','none');                                                     % title
        t.Position(2) = t.Position(2) *0.92;
    end
    ax = gca;
    lg = legend(ax.Children(2:2:end),legend_Iterations);
    lg.Interpreter = "none";
    lg.Position = [ 0.9070    0.4620    0.0867    0.0952];
    tight_subplot_ticks(ha,LastRow,0)
    suptitle(['Muscle forces ' leg ],'FontName',get(gca,'FontName'))
    mmfn_inspect
 
    saveas(gcf,[savedir fp 'MuscleForces_results_' l '.tiff'])

    %% plot contact forces
%     [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(joints));
    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(2,2,[],[0.15 0.1],[0.1 0.1],[0.2 0.08 0.6 0.81]);

    Plot_colors = colorBG(0,length(penalties));
    count = 0;
   
    for iJoint = [1,5]%1:length(joints)
        count = count +1;
        trap_JCF = [];
        for iPen = 1:length(penalties)
            axes(ha(count))

            JointName = joints{iJoint};
            force_data = contactForces.([penalties{iPen}]).(JointName);
            
            trap_JCF(end+1,:) = trap.contactForces.([penalties{iPen}]).(JointName);

            plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));
            title(JointName,'Interpreter','none')
            if any(count == FirstCol)
                ylabel('Contact force (N)')
            end
            if any(count == LastRow)
                xlabel('Gait cycle(%)')
            end
            ylim([0 5500])                                                                                          % ylim
        end
        count = count +1;
        axes(ha(count)); hold on
        % loop throguh rows(different weights)
        for irow = 1:size(trap_MF,1)
            %             [rsquared(irow),pvalue(irow), ~,rlo(irow),rup(irow)] = plotCorr (trap_MF(irow,:),trap_JCF(irow,:),1,0.05,Plot_colors(irow,:),5);
%             x = mean(trap_MF(irow,:),2); 
%             y = mean(trap_JCF(irow,:),2);
%             plot(x, y,'.','MarkerFaceColor',Plot_colors(irow,:),'MarkerSize',20)
%             errorbar(x, y, std(trap_JCF(irow,:),0,2),'Color',Plot_colors(irow,:),'LineStyle','none')
%             errorbar(x, y, std(trap_MF(irow,:),0,2),'horizontal','Color',Plot_colors(irow,:),'LineStyle','none')
        end
        plot(mean(trap_MF,2), mean(trap_JCF,2),'.','MarkerSize',20)
        errorbar(mean(trap_MF,2),mean(trap_JCF,2), std(trap_JCF,0,2),'Color',[0 0 0],'LineStyle','none')
        errorbar(mean(trap_MF,2),mean(trap_JCF,2), std(trap_MF,0,2),'horizontal','Color',[0 0 0],'LineStyle','none')
        [r, pvalue,rlo,rup] = corrcoef(mean(trap_MF,2),mean(trap_JCF,2));
        t = text(0.9, 0.9,['r = ' num2str(round(r(1,2),4))],'Units','normalized','Position',[.7925 0.7093 0]);
        ylim([0 3000])
        ylabel('Contact force (AUC)')
        if any(count == LastRow)
            xlabel('Muscle force (AUC)')
        end
    end

    % appearance
    ax = ha(1);
    lg = legend(ax.Children(2:2:end),legend_Iterations);
    lg.Position = [0.3 0.78 0.21 0.05];
    lg.Interpreter = "none";
    tight_subplot_ticks(ha,LastRow,0)
    suptitle(['Joint contact forces ' leg ],'FontName',get(gca,'FontName'))
    mmfn_inspect

    saveas(gcf,[savedir fp 'JCF_results_' l '.tiff'])
    close all

    %% plot correaltaion RF muscle force and JCF
    
    

end