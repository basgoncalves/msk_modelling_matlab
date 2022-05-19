% Create multiple box plots and copy them to one single docked figure

function Figure = MultiBarPlot (Data,tabs,xLabels,YLabel,TopNumbers)
[~,Ntrials] = size (Data);

Groups = 1;
for Trial = 2 : length (xLabels)
    
    % the full name of 1st trial witout the numbers, eg.: HE1 => HE
    TrialName = xLabels{Trial-1};
    Numbers = regexp(TrialName,'\d*','Match');
    Compare_1 = erase(TrialName,Numbers);
    
    % the full name of 2nd trial witout the numbers, eg.: HE1 => HE
    TrialName = xLabels{Trial};
    Numbers = regexp(TrialName,'\d*','Match');
    Compare_2 = erase(TrialName,Numbers);
    
    %get the length of the longer name
    N = max(length (Compare_1),length (Compare_2));
    
    if strncmp(Compare_1,Compare_2,N)==0      % comapre the current Trial name with the previous one
        Groups (end+1) = Trial;
    end
end

if Groups(end) ~= length(xLabels)
    Groups(end+1) = length(xLabels);                             % last group of trials
end


LoadBar = waitbar(0,'Please wait...');
for Trial = 1: Ntrials                                                      % run through every second data column
    
    waitbar(Trial/Ntrials,LoadBar,'Please wait...');
    Trial;                                                                  % remove semicolon to debug and find the trial that is giving error
    
    Figure.BoxPlot(Trial) = figure('WindowStyle', 'docked', ...
        'Name', sprintf('%s', tabs{Trial}), 'NumberTitle', 'off');
    fig = bar(Data(:,Trial));
    
    if nargin > 2
        xticks(1:length(xLabels));
        xticklabels(xLabels);
        set(gca,'TickLabelInterpreter','none');                                 % https://au.mathworks.com/matlabcentral/answers/169638-how-can-i-set-the-xtick-ytick-labels-of-my-axes-with-the-interpreter-as-none-in-matlab-8-4-r
    end
    
    if nargin < 4
        ylabel ('Y axis');
    else
        ylabel (YLabel);
    end
    
    ylh = get(gca,'ylabel');
    gyl = get(ylh);                                                         % Object Information
    ylp = get(ylh, 'Position');
    
    set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle',... % https://au.mathworks.com/matlabcentral/answers/271912-rotate-ylabel-and-keep-centered
        'HorizontalAlignment','right')
    title (sprintf ('%s',tabs{Trial}),...
        'Interpreter','none');
    xtickangle (45)
    %% change bar coulours (NOTE: use groupsRig)
    fig.FaceColor = 'flat';                                             % allow changing bar colour
    for c = 2:length(Groups)                                             % loop through all the conditions (e.g. B_ABD, B_ADD..)
        if mod(c,2) == 1 
            colour = 0.4;
        else
            colour = 0.7;
        end
        
        for b = Groups(c-1):Groups(c)                                  % loop through each trail (1,2,3...)
            fig.CData(b,:) = [colour colour colour];                          % colour with the tones of orange [red green blue]
        end
    end
    hold on
    
    fig(2)= bar(NaN,NaN);
    fig(2).FaceColor = 'flat';
    fig(2).CData(1,:) = [0.4 0.4 0.4];
    legend ('Pre', 'Post')
    
    % if there are numbers to plot on top of the graph
    if nargin == 5
        text(1:length(TopNumbers(:,Trial)),Data(:,Trial),num2str(TopNumbers(:,Trial)),'vert','bottom','horiz','center');
        box off
    end
end

close(LoadBar)
save BarPlots Figure
