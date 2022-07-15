function Plot_MuscleContributions_Per_Muscle(n)

if nargin < 1
    n = 0;                                                                                                           % n = the index to be use to select color (see colorBG)
end

Dir = getdirFAI;                                                                                                    % get project directories and data
cd(Dir.Results_JCFFAI)
load([Dir.Results_JCFFAI fp 'Paper4results.mat']);

CEINMSData = clearBadData_JCFFAI(CEINMSData,'MeanRunStraight');                                                     % delete some participants data because it's definitely not good

savedir = ([Dir.Results_JCFFAI]);
if ~exist(savedir); mkdir(savedir); end

[muscleGroups,muscleGroupsNames] = get_muscle_groups;                                                               % muscle group names (12 groups)
N_muscleGroups = length(muscleGroupsNames);

muscleNames = fields(CEINMSData.MuscleContributions_ap);                                                            % find muscle names
n_musc = length(muscleNames);

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

force_directions = {'MuscleContributions_ap' 'MuscleContributions_vert' 'MuscleContributions_ml'};
Title_names = {'(-)posterior | anterior (+)' '(-)inferior | superior (+)' '(-) lateral | medial (+)'};
Ylims = {[-8 8],[-1 9],[-3 3]};
Yticks = {[-8 0 8],[0 4 8],[-3 0 3]};


BW = CEINMSData.participantsWeight;
totalHCF = [];
totalHCF(:,1) = nanmean(CEINMSData.ContactForces.hip_x.MeanRunStraight./BW,2);                                      % gather the mean of HCF values normalised to BW
totalHCF(:,2) = nanmean(CEINMSData.ContactForces.hip_y.MeanRunStraight./BW,2);
totalHCF(:,3) = nanmean(CEINMSData.ContactForces.hip_z.MeanRunStraight./BW,2);


[ha, ~,FirstCol,LastRow,~] = tight_subplotBG(N_muscleGroups,3,[0.02 0.03], [0.05 0.05], [0.15 0.06],[0.25 0.045 0.5 0.955]);                   %  N_muscleGroups x 3 (3 directions)
index_plot = 0;

for imusc_group = 1:N_muscleGroups
    curr_muscleGroup = muscleGroupsNames{imusc_group};
    muscles_to_group = muscleGroups.(curr_muscleGroup);
    
    
    for iforce = 1:length(force_directions)
        curr_force = force_directions{iforce};
        musc_cont = [];
        for imusc = 1:n_musc
            curr_musc = muscleNames{imusc};
            if ~any(contains(muscles_to_group,curr_musc))
                continue
            end
            musc_cont(:,end+1) = nanmean(CEINMSData.(curr_force).(curr_musc).MeanRunStraight./BW,2);                % muscle contributions per muscle (normalised to BW)
        end
        musc_cont_per_group = sum(musc_cont,2);
        
        index_plot = index_plot + 1;
        axes(ha(index_plot));hold on;
        area(totalHCF(:,iforce),'FaceColor',[0.8 0.8 0.8],'EdgeColor','none')
        
        p = plot(musc_cont_per_group,'LineWidth',2);
        p.Color = Colors(imusc_group,:);
        ha(index_plot).FontSize = 14;                                                                               % define FontSize
        xlim([0 100])
        ylim(Ylims{iforce})
        yaxisnice(3)
        yticklabels(Yticks{iforce})
        if any(index_plot==FirstCol)
            ylb = ylabel(curr_muscleGroup);
            ylb.Rotation = 0;
            ylb.HorizontalAlignment = 'Right';
        end
        
        if any(index_plot==LastRow)
            xticklabels(xticks)
            xlabel('% gait cycle')
        end
                
        if  any(index_plot==[1,2,3])
            title(Title_names{iforce})
        end
    end
end

mmfn
saveas(gcf,[savedir fp ['Contributions_HCF_Per_Muscle.jpeg']])

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


