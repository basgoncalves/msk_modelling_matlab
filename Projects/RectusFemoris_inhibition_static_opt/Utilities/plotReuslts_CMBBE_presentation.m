
function plotReuslts_CMBBE_presentation(savedir)

fp = filesep;
mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData'] ; % Base Directory to base results directory.
cd(tesdataDir)

if nargin < 1; savedir = ['C:\Git\Papers-Reviews\Conference_Abstracts\CMBBE_2023\figures']; end

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

muscles_of_to_plot  = {'recfem'};
muscle_titles       = {'recfem'};

legend_Iterations   = {'inhibition 1000','inhibition 500','inhibition 100','inhibition 10',['42' char(176) ' anteversion + no inhibition']};
penalties           = fields(muscleForces);
Plot_colors         = colorBG(7,length(penalties));  %colorBG(0,length(penalties));
Plot_colors_ref     = [0.5 0.5 0.5];
XTlabels            = [0:20:100];
%------------------------------------------ Plot settings (end) -----------------------%
%% plot recf fem AVA vs Normal
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,1,[0.05 0.05],[0.15 0.15],[0.1 0.15],0.6);

Plot_colors = colorBG('hot',length(penalties));  %colorBG(0,length(penalties));

axes(ha(1)); hold on
force_data = muscleForces.Pen_0.recfem;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(1,:));

force_data = muscleForces.Pen_1000.recfem ;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(5,:));

force_data = reference_model.muscleForces.Pen_0.recfem_l   ;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors_ref(1,:));

xlabel('Gait cycle (%)')
ylabel('Muscle force (N)')
title('Rectus Femoris Forces','Interpreter','none');

ax = gca;
lg = legend(ax.Children(2:2:end),{'42 AVA no inhibition','42 AVA max inhibition','reference AVA no inhibition'});
lg.Interpreter = "none";
lg.Position = [0.71 0.5 0.25 0.1];
tight_subplot_ticks(ha,LastRow,0)
mmfn_inspect

% remove background
for i = 1:length(muscles_of_to_plot)
    set(ha(i), 'Color',rgb2mat([0,107,140]), 'FontSize', 15, 'FontName', 'Arial','XColor', 'white', 'YColor', 'white', 'ZColor', 'white','FontWeight','bold');
    ha(i).YLabel.Color = [1,1,1];
    ha(i).Title.Color = [1,1,1];
    try ha(i).Legend.TextColor = [1,1,1]; catch; end
end
set(gcf, 'Color',rgb2mat([0,107,140]));  

saveas(gcf,[savedir fp 'RF_force_AVA_vs_Normal.tiff'])
%% plot hip and knee contact forces effects of inhibition vs AVA
%     [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(joints));
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(2,2,[0.05 0.05],[0.1 0.1],[0.08 0.02],[0.2 0.08 0.6 0.81]);

Plot_colors = colorBG('hot',length(penalties));  %colorBG(0,length(penalties));
count = 0;

for iJoint = [1,5]                                                                                              % only resultant hip and knee contact forces
    count = count +1;
    trap_JCF = [];
    for iPen = 1:length(penalties)                                                                              % plot time-varying contact forces
        axes(ha(count))

        JointName = joints{iJoint};
        force_data = contactForces.([penalties{iPen}]).(JointName);

        plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));
        if count == 1; title('Effects of inhibition','Interpreter','none'); end                                     % title only first row

        if any(count == FirstCol)
            lab = [strrep(JointName,'_resultant','') ' contact force (N)'];
            ylabel([upper(lab(1)) lab(2:end)])
        end
        if any(count == LastRow)
            xlabel('Gait cycle (%)')
        end
        ylim([0 6000])                                                                                              % ylim
        xlim([0 100])                                                                                               % xlim
        xticks(XTlabels)
        xticklabels(XTlabels)
        yaxisnice(6)
    end
    count = count +1;
    axes(ha(count)); hold on
    force_data = contactForces.([penalties{1}]).(JointName);                                                        % plot model with AVA and zero penalty
    plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(1,:));

    force_data = reference_model.contactForces.([penalties{1}]).(JointName);
    plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors_ref);                                          % plot reference model and zero penalty

    if count == 2; title('Effects of anteversion angle','Interpreter','none'); end                                  % title only first row

    ylim([0 6000])
    xlim([0 100])                                                                                                   % xlim
    xticks(XTlabels)
    xticklabels(XTlabels)
    yaxisnice(6)
    yticklabels('')
    if any(count == LastRow)
        xlabel('Gait cycle (%)')
    end
end
tight_subplot_ticks(ha,LastRow,0)
% appearance right plots
lg_right = legend(ha(count).Children([flip(4:3:end),2,3]),{'42° anteversion + no inhibition','12° anteversion + no inhibition','SD'});
lg_right.Position = [0.81 0.82 0.17 0.005];
lg_right.FontSize = 20;

% appearance lrft plots
ha = flip(get(gcf,'Children'));
lg = legend(ha(1).Children([end,flip(2:2:end-1),1]),[flip(legend_Iterations),'SD']);
lg.Position = [0.35 0.82 0.17 0.005];
lg.Interpreter = "none";
lg.FontSize = 20;

mmfn_CMBBE

% remove background
for i = 1:4
    set(ha(i), 'Color',rgb2mat([0,107,140]), 'FontSize', 14, 'FontName', 'Arial','XColor', 'white', 'YColor', 'white', 'ZColor', 'white');
    ha(i).YLabel.Color = [1,1,1];
    ha(i).Title.Color = [1,1,1];
    try ha(i).Legend.TextColor = [1,1,1]; catch; end
end
set(gcf, 'Color',rgb2mat([0,107,140]))

axes(ha(1))
ylabel('Knee contact force (N)')

axes(ha(2))
ylabel('Hip contact force (N)')


print(gcf,[savedir fp 'JCF_results_' l '_no_impulse.png'],'-dpng','-r1200')
f = gcf;
saveas(f,[savedir fp 'JCF_results_' l '_no_impulse.jpeg'])
saveas(gcf,[savedir fp 'JCF_results_' l '_no_impulse.tiff'])
savefig(gcf,[savedir fp 'JCF_results_' l '_no_impulse.fig'])
close all


%% plot knee contact forces AVA and inhibition in same
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,1,[0.05 0.05],[0.15 0.15],[0.15 0.15],[0.2 0.08 0.6 0.81]);

Plot_colors = colorBG('hot',length(penalties));  %colorBG(0,length(penalties));
count = 0;
axes(ha(1)); hold on
force_data = contactForces.Pen_0.knee_resultant;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(1,:));

force_data = contactForces.Pen_1000.knee_resultant;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(5,:));

force_data = reference_model.contactForces.Pen_0.knee_resultant;
plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors_ref(1,:));

xlabel('Gait cycle (%)')
ylabel('Knee contact forces (N)')
xlim([0 100])

ax = gca;
lg = legend(ax.Children(2:2:end),{'42 AVA no inhibition','42 AVA max inhibition','reference AVA no inhibition'});
lg.Interpreter = "none";
lg.Position = [0.71 0.5 0.25 0.1];
lg.FontSize = 20;
tight_subplot_ticks(ha,LastRow,0)
mmfn_inspect

% remove background
for i = 1:length(muscles_of_to_plot)
    set(ha(i), 'Color',rgb2mat([0,107,140]), 'FontSize', 15, 'FontName', 'Arial','XColor', 'white', 'YColor', 'white', 'ZColor', 'white','FontWeight','bold');
    ha(i).YLabel.Color = [1,1,1];
    ha(i).Title.Color = [1,1,1];
    try ha(i).Legend.TextColor = [1,1,1]; catch; end
end
set(gcf, 'Color',rgb2mat([0,107,140]));  