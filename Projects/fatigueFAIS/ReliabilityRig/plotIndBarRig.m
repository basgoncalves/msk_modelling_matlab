% plot bar graphs for to see between day difference for each trial
% use this to inspect possible subjects that may be affecting the
% reliability results


function plotIndBarRig(TotalData,description)
[~,Ntrials] = size (TotalData);                             % find the nummber of trials

Conditions = 1:2:Ntrials;                                   % each 2 trials = 1 condition

Label = 1;

for Trial = Conditions                                      % run through every second data column 
    Trial;                                                  % remove semicolon to debug and find the trial that is giving error
    Figure.figH(Trial)= figure('WindowStyle', 'docked', ...
      'Name', sprintf ('%s',description{Label}), 'NumberTitle', 'off');        % create a docked figure (https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs)
    bar(TotalData(:,Trial:Trial+1))    
    %% set graph settings   
    Dim = get(0,'ScreenSize');                                                  % get the dimesnions of the screen [Xpos Ypos Xsize Ysize]
%     set(gcf,'Position',[Dim(3)/4 Dim(4)/3 1000 500]);                            % resize the figure [Xpos Ypos Xsize Ysize]
    ylabel ('Torque (N.m)');
    set(get(gca,'ylabel'),'rotation',0,'HorizontalAlignment','right')
    xlabel ('Participants');
    box off
    title (sprintf ('%s',description{Label}),...
        'Interpreter','none');
    
    legend ('day 1','day 2')
    Label=Label+1;
end

%% save fig
save IndDataRig                           % save mat data to open later all the tabs


