function Plot_MuscleContributions_Stacked(n)

Dir = getdirFAI;
cd(Dir.Results_JCFFAI)
load([Dir.Results_JCFFAI fp 'Paper4results.mat']);

savedir = ([Dir.Results_JCFFAI]);
if ~exist(savedir); mkdir(savedir); end

muscleGroups = struct;

muscleGroups.Iliopsoas     = {['iliacus'],['psoas']};
muscleGroups.RecFem        = {['recfem']};
muscleGroups.TFL           = {['tfl']};

muscleGroups.Hamstrings    = {['bflh'],['bfsh'],['semimem'],['semiten']};
muscleGroups.Gmax          = {['glmax1'],['glmax2'],['glmax3']};
muscleGroups.Gmed          = {['glmed1'],['glmed2'],['glmed3']};
muscleGroups.Gmin          = {['glmin1'],['glmin2'],['glmin3']};

muscleGroups.Adductors     = {['addbrev'],['addlong'],['addmagDist'],['addmagIsch'],['addmagMid'],['addmagProx'],['grac']};

muscleGroups.Vasti         = {['vasint'],['vaslat'],['vasmed']};

muscleGroups.Gastroc       = {['gaslat'],['gasmed']};
muscleGroups.Soleus        = {['soleus']};

muscleGroups.Tibilais      = {['tibant']};

muscleGroupsNames  = fields(muscleGroups);

muscleNames = fields(CEINMSData.MuscleContributions_ap);
n_musc = length(muscleNames);

CEINMSData.MuscleContributions_ap

force_directions = {'MuscleContributions_ap' 'MuscleContributions_vert' 'MuscleContributions_ml' 'MuscleContributions_resultant'};
title_names = {'Antero-posterior' 'Vertical' 'Medio-lateral' 'Resultant'};
N_muscleGroups = length(muscleGroupsNames);

if nargin < 1
   n = 0; 
end

Colors = colorBG(n,N_muscleGroups);

indiv_colors = rgb2mat([123,165,145;202,36,44;245,128,53;251,212,92;128,127,127;226,144,119]);                      % color pallet https://www.pinterest.com.au/pin/510103095296824881/

Colors = [indiv_colors(1,:); indiv_colors(1,:); indiv_colors(1,:); ...
          indiv_colors(2,:); indiv_colors(2,:); indiv_colors(2,:); indiv_colors(2,:); ...
          indiv_colors(3,:);...
          indiv_colors(4,:);...
          indiv_colors(5,:);indiv_colors(5,:);...
          indiv_colors(6,:)];
 
FaceAlpha = [0.8,0.6,0.4,0.8,0.6,0.4,0.2,0.8,0.8,0.8,0.6,0.8]; 
Colors = flip(Colors);
FaceAlpha = flip(FaceAlpha);

[ha, ~,FirstCol,LastRow,~] = tight_subplotBG(1,4,[0.05 0.05], 0.05, [0.05 0.1],[0.0177 0.4185 0.9417 0.4037]);

for iforce = 1:length(force_directions)
    curr_force = force_directions{iforce};
    musc_cont_per_group = [];
    
    for imusc_group = 1:N_muscleGroups
        curr_muscleGroup = muscleGroupsNames{imusc_group};
        muscles_to_group = muscleGroups.(curr_muscleGroup);
        musc_cont = [];
        for imusc = 1:n_musc
            curr_musc = muscleNames{imusc};
            if ~any(contains(muscles_to_group,curr_musc))
                continue
            end
            musc_cont(:,end+1) = nanmean(CEINMSData.(curr_force).(curr_musc).MeanRunStraight,2);
        end
        musc_cont_per_group(:,end+1) = mean(musc_cont,2);
    end
        
    axes(ha(iforce));hold on;
    area(musc_cont_per_group,'DisplayName','musc_cont_per_group')
    
    xlim([0 100])
    for imusc_group = 1:N_muscleGroups
        ha(iforce).Children(imusc_group).FaceColor = Colors(imusc_group,:);
        ha(iforce).Children(imusc_group).FaceAlpha = FaceAlpha(imusc_group);
    end
  
    
    title(title_names{iforce})
    if any(iforce==FirstCol) && ~any(iforce==LastRow)
        ylabel('Contribution to HCF (N)')
    elseif ~any(iforce==FirstCol) && any(iforce==LastRow)
        xlabel('% gait cycle')
    elseif any(iforce==FirstCol) && any(iforce==LastRow)
        xlabel('% gait cycle')
        ylabel('Contribution to HCF (N)')
    end
end

lg = legend([muscleGroupsNames]);
lg.Position = [0.92 0.43 0.05 0.25];
tight_subplot_ticks (ha,LastRow,0)
mmfn
saveas(gcf,[savedir fp ['Contributions_HCF_' num2str(n) '.jpeg']])

disp('plotting complete')

function mmfn(xlb,ylb)

set(gcf,'Color',[1 1 1]);
grid off
fig=gcf;
N =  length(fig.Children);
for ii = 1:N
    set(fig.Children(ii),'box', 'off')
    if contains(class(fig.Children(ii)),'Axes')
        fig.Children(ii).FontName = 'Times New Roman';
        fig.Children(ii).Title.FontWeight = 'Normal';
    end
end

if nargin>0
    xlabel(xlb)
end

if nargin>1
    ylabel(ylb)
end


