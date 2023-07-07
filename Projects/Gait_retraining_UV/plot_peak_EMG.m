function plot_peak_EMG

Dirs = getDirs;
load(Dirs.results)


task = {'avoid','increase'};
muscle_task = {'gastro','soleus','rf','semimem','tfl'};
muscle_emg  = {'latgas','soleus','recfem','medham','tfl'};

task_muscle = [task{1} '_' muscle_task{1} '_'];
subjects = fields(emg.(task_muscle));
colors = colorBG(0,length(subjects));
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,length(muscle_emg),0.05,0.1, 0.08,[0.15 0.3 0.7 0.5]);

for m = 1:length(muscle_emg)
    axes(ha(m)); hold on
    
    for s = 1:length(subjects)
        for t = 1:length(task)


            task_muscle = [task{t} '_' muscle_task{m} '_'];
            mean_emg = mean(emg.(task_muscle).(subjects{s}).(muscle_emg{m}),2);
            peak_emg = max(mean_emg)*100;
            if peak_emg > 100
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
    xlim([0 3])
    xticks([1 2])
    xticklabels(task)
    title(muscle_emg{m})
    ylim([0 25])
end


mmfn

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

