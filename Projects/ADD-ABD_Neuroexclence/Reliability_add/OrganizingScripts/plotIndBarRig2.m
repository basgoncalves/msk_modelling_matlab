function plotIndBarRig2(TotalData,description)
[~,Ntrials] = size (TotalData);                             % find the nummber of trials

Label = 1;


for Trial = 1:6                                      % run through every second data column 
    Trial;                                                  % remove semicolon to debug and find the trial that is giving error
    Figure.figH(Trial)= figure('WindowStyle', 'docked', ...
      'Name', sprintf ('%s',description{Label}), 'NumberTitle', 'off');        % create a docked figure (https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs)
    scatter(TotalData(:,Trial),TotalData (:,Trial+6))   
    coef = polyfit(TotalData(:,Trial),TotalData (:,Trial+6),1);                     % calculate linear regression coefficients
    h = refline(coef(1), coef(2));  
    %% set graph settings   
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
save BiodexvsRig                           % save mat data to open later all the tabs

