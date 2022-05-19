%% PlotRuningEMG_FAI
% plot running EMG FAI project
% Basilio Goncalves 2019
%

if exist ('SubjFolder')==0
    SubjFolder = uigetdir(cd,'Select Subject Folder');
end

Trial =2;
screensize = get( 0, 'Screensize' )/1.2;
Xpos = screensize(1); Ypos = screensize(2); Xsize = screensize(3); Ysize = screensize(4);
EMGPlot = figure('Position', [180 75 Xsize Ysize]);
idcs   = strfind(SubjFolder,'\');
Subject = SubjFolder(idcs(end)+1:end);
fs=2000;

for ii = 1:16
    Figure.Plot(ii) = subplot(5,4,ii);
end

Trials =1:length(fields(RunningEvents)); 
for Trial = Trials
    
    TrialNames = fields(RunningEvents);
    if isempty(RunningEMG.(TrialNames{Trial}))==0
              
        for ii = 1:16                                                   % loop through
            hold(Figure.Plot(ii),'on')
            EMGdata = TimeNormalizedEMG.(TrialNames{Trial})(:,ii);
            plot(Figure.Plot(ii),EMGdata);
            
            title (Figure.Plot(ii),RunningEMG.channels(ii));
            ylabel (Figure.Plot(ii),'Normalized EMG');
            xlabel (Figure.Plot(ii),'% Gait cycle');
            xticks(Figure.Plot(ii),0:25:100);
            XLables = {'0','25','50','75','100'};
            axis (Figure.Plot(ii),'tight')
            xticklabels(Figure.Plot(ii),XLables);
            set(gca,'TickLabelInterpreter','none');
            %             x= ToeOff/2000*100/timeTrial(end);
            %             y = max(TimeNormalizedEMG);                      % plot heel strike
            %             line(Figure.Plot(ii),[x x], [0 y]);
            
            
        end
        suptitle(sprintf('Running EMG %s',Subject))
        
    end
end


for ii = 1: 12                                                  % loop through
            hold(Figure.Plot(ii),'on')
            set(Figure.Plot(ii),'xlabel',[])
end

LegendNames = fields(RunningEvents);
lg = legend(LegendNames', 'Interpreter','none',...
    'orientation','horizontal','Location','SouthOutside');


mmfn %make figure nice 

cd([DirFigure filesep 'RunningEMG'])
saveas(gcf, sprintf('RuningEMG-%s.jpeg',Subject))