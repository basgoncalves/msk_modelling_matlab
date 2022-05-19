% Create multiple box plots and copy them to one single docked figure 
%
% REFERENCES
%   https://stackoverflow.com/questions/18477705/plotting-an-existing-matlab-plot-into-another-figure
%   https://au.mathworks.com/matlabcentral/answers/127966-boxplot-outlier-how-to-reduce-outliers-boundry-change
%   

function MultiBoxPlot (Data,description)
[~,Ntrials] = size (Data);

                                

for Trial = 1: Ntrials                                                      % run through every second data column 
    Trial;                                                                  % remove semicolon to debug and find the trial that is giving error
    
    Figure.BoxPlot(Trial) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('%s', description{Trial}), 'NumberTitle', 'off');     
    fig = boxplot(Data(:,Trial),'whisker',2);
    ylabel ('Session2 - Session1(N.m)');
    title (sprintf ('%s',description{Trial}),...
        'Interpreter','none');
   
end

save BoxPlots
