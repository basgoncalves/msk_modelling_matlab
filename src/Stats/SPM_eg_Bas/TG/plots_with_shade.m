clc; clear; close all;
load('D:\FASHIoN\FollowUp\All_Data.mat') % All data and means
addpath('D:\FASHIoN');
Motions = fields(IK);  % Load IK motions
Treat = fields(WalkMeans);
time = fields(WalkMeans.(Treat{1}));



%% Create figure 1: trunk and pelvis angles
pelvis = {'pelvis_tilt','pelvis_list','pelvis_rotation'};
trunk = {'lumbar_extension', 'lumbar_bending', 'lumbar_rotation'};
F1_motions = [pelvis trunk];
% Plot titles
titles = [];
for mm = 1:length(F1_motions)
    titles{mm} = strrep(F1_motions{mm}, '_', ' ');
    Mot_titles{mm} = regexprep(titles{mm},'(\<[a-z])','${upper($1)}');
end
figure
tiledlayout(2,3, 'TileSpacing', 'compact')
for a = 1:length(F1_motions)
    ff = 1;
    % Plot
    nexttile
    for t=1:length(Treat)
        for tt=1:length(time)
            plotShadedSD(WalkMeans.(Treat{t}).(time{tt}).IK.(F1_motions{a}),WalkMeans.(Treat{t}).(time{tt}).IK_SD.(F1_motions{a}))
            y = WalkMeans.(Treat{t}).(time{tt}).IK.(F1_motions{a});
        end
    end
    ax = gca;
    
    % Change colours
    cMat = {[0.2588, 0.6549, 0.9608],[0.2588, 0.6549, 0.9608],[0.9412, 0.1333, 0.1843],[0.9412, 0.1333, 0.1843]};
    Lst = {'-',':','-',':'};
    count = 0;
    for c = 2:2:8
        count = count+1;
        ax.Children(c).Color = cMat{count};
        ax.Children(c).LineStyle = Lst{count};
    end
    xlim([1 100])
    ylim([-20 20])
    yline(0)
    
    mmfn
    if a == 1
        ylabel('(-) Anterior | Posterior (+)');
        ylh = get(gca, 'ylabel');
        set(gca,'Xticklabel',[]);
        title('Sagittal');
    elseif a == 2
        set(gca,'Xticklabel',[]);
        ylabel('(-) Rise | Drop (+)');
        title('Frontal');
    elseif a ==3
        set(gca,'Xticklabel',[]);
        ylabel('(-) External | Internal (+)');
        title('Transverse')

    elseif a == 4
        ylabel('(-) Anterior | Posterior (+)');
        ylh = get(gca, 'ylabel');
    elseif a == 5
        ylabel('(-) Unaffected | Affected (+)');
    elseif a == 6
        ylabel('(-) Internal | External (+)');
    end
    
    % interaction A
    for k = 1:size(PatchArea.(['IK_' F1_motions{a}]),2)
        x = PatchArea.(['IK_' F1_motions{a}]){3,k}';
        if isempty(x)
            continue
        end
        AddShade(ax,x,y, [0.6 0.2 0.4]) % purple - factor 1: treatment
    end
    
    % interaction B
    for k = 1:size(PatchArea.(['IK_' F1_motions{a}]),2)
        x = PatchArea.(['IK_' F1_motions{a}]){2,k}';
         if isempty(x)
            continue
        end
        AddShade(ax,x,y,[0.0 0.8 0.6]) % green - factor 2: time
    end
    
    
    % interaction AB
    for k = 1:size(PatchArea.(['IK_' F1_motions{a}]),2)
        x = PatchArea.(['IK_' F1_motions{a}]){1,k}';
         if isempty(x)
            continue
        end
        AddShade(ax,x,y,[1.0 1.0 0.1]) % yellow - interaction between treatment and time
    end

end
lg = legend
    legend(ax.Children([4,6,8,10,3]),'Baseline PHT','Follow-up PHT','Baseline ARTH','Follow-up ARTH','Standard deviation');
                legend ('boxoff');
        set(lg,'color','white','Location', 'bestoutside');
mmfn