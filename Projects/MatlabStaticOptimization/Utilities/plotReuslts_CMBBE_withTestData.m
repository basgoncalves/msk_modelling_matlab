

function plotReuslts_CMBBE_withTestData(savedir)

fp = filesep;
mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData'] ; % Base Directory to base results directory.
cd(tesdataDir)

if nargin < 1; savedir = [tesdataDir fp 'figures']; end

if ~isfolder(savedir); mkdir(savedir); end

AVA = {'AVA_p30','AVA_p0'};
leg = 'l';
l = lower(leg);
if contains(l,'l'); leg = 'left'; else; leg = 'right'; end

load(['results_' l '_' AVA{1} '.mat'])
reference_model = load(['results_' l '_'  AVA{2} '.mat']);  

%------------------------------------------ Plot settings -----------------------------%
muscles_of_to_plot  = {'recfem','ilio_psoas','tfl','sart','glmax_all','glmed_all','glmin_all','adductors','vasti','hamstrings','gastroc','soleus' };
muscle_titles       = {'recfem','ilio_psoas','tfl','sart','glmax','glmed','glmin','adductors','vasti','hamstrings','gastroc','soleus' };
legend_Iterations   = {'inhibition 1000','inhibition 500','inhibition 100','inhibition 10',['48' char(176) ' anteversion + no inhibition']};
penalties           = fields(muscleForces);
Plot_colors         = colorBG(0,length(penalties));
Plot_colors_ref     = [0.5 0.5 0.5];
%------------------------------------------ Plot settings (end) -----------------------%

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
xlabel('Gait cycle (%)')

axes(ha(first_moments_plot+1))
plotShadedSD(mean(id.knee_angle,2),std(id.knee_angle,0,2),kinematics_color);
xlabel('Gait cycle (%)')

axes(ha(first_moments_plot+2))
plotShadedSD(mean(id.ankle_angle,2),std(id.ankle_angle,0,2),kinematics_color);
xlabel('Gait cycle (%)')

tight_subplot_ticks(ha,LastRow,0)
mmfn_CMBBE
saveas(gcf,[savedir fp 'ExtBiomech_results_' l '.tiff'])
close all
%% plot muscle forces
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(muscles_of_to_plot),0,[0.01 0.02],[],[0.03 0.08]);
trap_MF = [];

for iMuscle = 1:length(muscles_of_to_plot)                                                                          % loop through muscles
    for iPen = 1:length(penalties)                                                                                  % loop through penalties
        axes(ha(iMuscle))

        MuscleName = muscles_of_to_plot{iMuscle};
        force_data = muscleForces.([penalties{iPen}]).(MuscleName);

        if contains(MuscleName,'recfem')
            trap_MF(end+1, :) = trap.muscleForces.([penalties{iPen}]).([MuscleName '_' l]);
        end

        plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));                                  % plot mean and SD

        if any(iMuscle == FirstCol)
            ylabel('Muscle force (N)')                                                                              % ylabels
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
mmfn_CMBBE

saveas(gcf,[savedir fp 'MuscleForces_results_' l '.tiff'])

%% plot contact forces
%     [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(joints));
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(2,2,[0.2 0.1],[0.15 0.1],[0.1 0.1],[0.2 0.08 0.6 0.81]);

Plot_colors = colorBG(0,length(penalties));
count = 0;

for iJoint = [1,5]                                                                                              % only resultant hip and knee contact forces
    count = count +1;
    trap_JCF = [];
    for iPen = 1:length(penalties)                                                                              % plot time-varying contact forces
        axes(ha(count))

        JointName = joints{iJoint};
        force_data = contactForces.([penalties{iPen}]).(JointName);

        trap_JCF(end+1,:) = trap.contactForces.([penalties{iPen}]).(JointName);

        plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));
        title(strrep(JointName,'_',' ') ,'Interpreter','none')
        if any(count == FirstCol)
            ylabel('Contact force (N)')
        end
        if any(count == LastRow)
            xlabel('Gait cycle (%)')
        end
        ylim([0 5500])                                                                                          % ylim
    end
    count = count +1;
    axes(ha(count)); hold on

    rsquared = []; pvalue = [];
    for irow = 1:size(trap_MF,1)                                                                                % loop throguh rows(different inhibitions) and plot the are under the curve (impulse)
        x = trap_MF(irow,:);
        y = trap_JCF(irow,:);
        [r,p] = corrcoef(x,y);                                                                                  % calcuclate pearson coefficient and square it
        rsquared(irow) = r(1,2)^2;
        pvalue(irow) = p(1,2);
        plot(mean(x), mean(y),'.','MarkerSize',35,'Color', Plot_colors(irow,:))                                 % plot
        errorbar(mean(x,2),mean(y,2), std(y,0,2),'Color',[0 0 0],'LineStyle','none')
        errorbar(mean(x,2),mean(y,2), std(x,0,2),'horizontal','Color',[0 0 0],'LineStyle','none')
    end
    r = mean(rsquared);                                                                                         % mean rsquared
    [r, pvalue,rlo,rup] = corrcoef(mean(trap_MF,2),mean(trap_JCF,2));
    r = r(1,2)^2;                                                                                               % rsquared of the mean values

    t = text(0.9, 0.9,['r^2 = ' num2str(round(r,4))],'Units','normalized','Position',[.7925 0.7093 0]);
  
    ylim([0 3000])
    ylabel('Contact force impulse (N*s)')
    if any(count == LastRow)
        xlabel('Muscle force impulse (N*s)')
    end
end
tight_subplot_ticks(ha,LastRow,0)
% appearance scatter plots
lg_sactter = legend(ha(count).Children([flip(4:3:end),2,3]),[flip(legend_Iterations),'SD muscle force impulse','SD contact force impulse']);
lg_sactter.Position = [0.7408    0.45    0.1769    0.1157];
                               
ha = flip(get(gcf,'Children'));                                                     % plot reference values from no anteversion model (only no inhibition results)

axes(ha(3))
force_data = reference_model.contactForces.([penalties{1}]).(joints{5});
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors_ref);              % knee

axes(ha(1))
force_data = reference_model.contactForces.([penalties{1}]).(joints{1});
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors_ref);              % hip

% appearance line plots
lg = legend(ha(1).Children([2,1,end,flip(4:2:end-1)]),[['18' char(176) ' anteversion'],'SD',flip(legend_Iterations)]);
lg.Position = [0.3141    0.45    0.2100    0.1343];
lg.Interpreter = "none";
mmfn_CMBBE
suptitle(['Effects of femoral anteversion and rectus femoris inhibition on hip and knee contact forces' ],'FontName',get(gca,'FontName'),'FontSize',16)


saveas(gcf,[savedir fp 'JCF_results_' l '.tiff'])
savefig(gcf,[savedir fp 'JCF_results_' l '.fig'])
close all

%% Calculate mean differences 
warning off
first_peak_x = [1:30];
second_peak_x = [30:101];
peak_CF = table; 
peak_CF.condition(1)    = {'reference model'};
peak_CF.first_peak_hip(1)   = mean(max(reference_model.contactForces.Pen_0.hip_resultant(first_peak_x,:)));
peak_CF.second_peak_hip(1)  = mean(max(reference_model.contactForces.Pen_0.hip_resultant(second_peak_x,:)));
peak_CF.first_peak_knee(1)  = mean(max(reference_model.contactForces.Pen_0.knee_resultant(first_peak_x,:)));
peak_CF.second_peak_knee(1) = mean(max(reference_model.contactForces.Pen_0.knee_resultant(second_peak_x,:)));

for iPen = 1:length(penalties)                                                                              

    force_data_hip = contactForces.([penalties{iPen}]).(joints{1});
    force_data_knee = contactForces.([penalties{iPen}]).(joints{5});
 
    peak_CF.condition(iPen+1)           = [penalties(iPen)];
    peak_CF.first_peak_hip(iPen+1)      = mean(max(force_data_hip(first_peak_x,:)));
    peak_CF.second_peak_hip(iPen+1)     = mean(max(force_data_hip(second_peak_x,:)));
    peak_CF.first_peak_knee(iPen+1)     = mean(max(force_data_knee(first_peak_x,:)));
    peak_CF.second_peak_knee(iPen+1)    = mean(max(force_data_knee(second_peak_x,:)));
    
    %relative to referenc model
    row = length(penalties)+iPen+1;
    peak_CF.condition(row)           = {[penalties{iPen} '_relative']};
    peak_CF.first_peak_hip(row)      = peak_CF.first_peak_hip(iPen+1)/peak_CF.first_peak_hip(1)*100;
    peak_CF.second_peak_hip(row)     = peak_CF.second_peak_hip(iPen+1)/peak_CF.second_peak_hip(1)*100;
    peak_CF.first_peak_knee(row)     = peak_CF.first_peak_knee(iPen+1)/peak_CF.first_peak_knee(1)*100;
    peak_CF.second_peak_knee(row)    = peak_CF.second_peak_knee(iPen+1)/peak_CF.second_peak_knee(1)*100;

    %relative to no inhibition model with increased AVA
    row_no_inhibition = 2;
    row = 2*length(penalties)+iPen+1;
    peak_CF.condition(row)           = {[penalties{iPen} '_relative_to_no_inhibition']};
    peak_CF.first_peak_hip(row)      = peak_CF.first_peak_hip(iPen+1)/peak_CF.first_peak_hip(row_no_inhibition)*100;
    peak_CF.second_peak_hip(row)     = peak_CF.second_peak_hip(iPen+1)/peak_CF.second_peak_hip(row_no_inhibition)*100;
    peak_CF.first_peak_knee(row)     = peak_CF.first_peak_knee(iPen+1)/peak_CF.first_peak_knee(row_no_inhibition)*100;
    peak_CF.second_peak_knee(row)    = peak_CF.second_peak_knee(iPen+1)/peak_CF.second_peak_knee(row_no_inhibition)*100;

end


writetable(peak_CF,[savedir fp 'peakCF.csv'])