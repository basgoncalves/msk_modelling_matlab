function plot_peak_EMG

Dirs = getDirs;
load(Dirs.results)

emg.normal = emg.warmup_;

task = {'avoid','normal','increase'};
muscle_task = {'gastro','soleus','rf','semimem','tfl'};
muscle_emg  = {'latgas','soleus','recfem','medham','tfl'};

task_muscle = [task{1} '_' muscle_task{1} '_'];
subjects = fields(emg.(task_muscle));
colors = colorBG(0,length(subjects));

%% absolute values
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,length(muscle_emg),0.05,0.1, 0.08,[0.15 0.3 0.7 0.5]);

for m = 1:length(muscle_emg)
    axes(ha(m)); hold on
    
    for s = 1:length(subjects)
        for t = 1:length(task)

            try
                task_muscle = [task{t} '_' muscle_task{m} '_'];
                mean_emg = mean(emg.(task_muscle).(subjects{s}).(muscle_emg{m}),2);
                peak_emg = max(mean_emg)*100;
            catch
                try
                    task_muscle = [task{t}];
                    mean_emg = mean(emg.(task_muscle).(subjects{s}).(muscle_emg{m}),2);
                    peak_emg = max(mean_emg)*100;
                catch
                    peak_emg = NaN;
                end
            end
            if isempty(peak_emg) || peak_emg > 100
                peak_emg = NaN;
            end
            
            plot_scatter_text(t,peak_emg,{num2str(s)},colors(s,:))
            
    
        end
    end
end
axes(ha(1))
ylabel('peak emg activity (% cmj)')
tight_subplot_ticks(ha,0,1)

for m = 1:length(muscle_emg)
    axes(ha(m)); hold on
    xlim([0 4])
    xticks([1 2 3])
    xticklabels(task)
    title(muscle_emg{m})
    ylim([0 25])
end


mmfn

saveFilePath = [fileparts(Dirs.results) fp 'peak_muscle_activity.png']; 
print(gcf,saveFilePath,'-dpng','-r300')

%% differences

[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,length(muscle_emg),0.05,0.1, 0.08,[0.15 0.3 0.7 0.5]);

task = {'avoid','increase'};

for m = 1:length(muscle_emg)
    axes(ha(m)); hold on
    ylim([-100 100])
    for s = 1:length(subjects)
        for t = 1:length(task)
            mean_emg = mean(emg.normal.(subjects{s}).(muscle_emg{m}),2);
            peak_emg_normal = max(mean_emg)*100;
            if isempty(peak_emg_normal) || peak_emg_normal > 100
                peak_emg_normal = NaN;
            end
            try
                task_muscle = [task{t} '_' muscle_task{m} '_'];
                mean_emg = mean(emg.(task_muscle).(subjects{s}).(muscle_emg{m}),2);
                peak_emg = max(mean_emg)*100;
            catch
                peak_emg = NaN;
            end
            if isempty(peak_emg) || peak_emg > 100
                peak_emg = NaN;
            end

            diff_peak_emg = (peak_emg - peak_emg_normal)/peak_emg_normal * 100;
            plot_scatter_text(t,diff_peak_emg,{num2str(s)},colors(s,:))
            
    
        end
    end
end
axes(ha(1))
ylabel('change in peak emg activity (%)')
tight_subplot_ticks(ha,0,1)

for m = 1:length(muscle_emg)
    axes(ha(m)); hold on
    xlim([0 length(task)+1])
    xticks(1:length(task))
    xticklabels(task)
    title(muscle_emg{m})

    % plot y = 0
    x = [0:length(task)+1];
    y = zeros(size(x));
    plot(x, y, '--k', 'LineWidth', 1);
end

mmfn

saveFilePath = [fileparts(Dirs.results) fp 'peak_muscle_activity_diff.png']; 
print(gcf,saveFilePath,'-dpng','-r300')



%% ===============================================================================================================%
function plot_scatter_text(x,y,labels,color)

% Create a scatter plot with numbers
s= scatter(x, y, 'MarkerFaceColor',color);
s.SizeData = 500;
s.MarkerEdgeColor = 'none';
hold on

% Add text labels to each point
for i = 1:numel(x)
    t = text(x(i), y(i), labels{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    t.Color = 'white';
    t.FontWeight = 'bold';
    t.FontSize = 14;
end

