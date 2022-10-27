function InspectEMG_bops

fp = filesep;
bops = load_setup_bops;
subject_settings = setupSubject;

trialList       = subject_settings.trials.dynamicTrials;
muscle_names    = bops.emg.Muscle;
n_emg           = length(muscle_names);
n_trials        = length(trialList);

savedir  = [subject_settings.directories.Elaborated fp 'EMG_check'];
if ~exist(savedir,"dir")
    mkdir(savedir)
end

emg_check_filename = [savedir fp 'emg_check.xlsx'];
if ~exist(emg_check_filename)
    emg_check                           = cell(n_trials+1,n_emg+1);                                                 % create a matrix with all EMGs and trials
    emg_check(2:n_trials+1,1)           = trialList;
    emg_check(1,2:n_emg+1)              = muscle_names;
    emg_check(2:n_trials+1,2:n_emg+1)   = {1};                                                                      % assign all the values to 1 (Good)
    emg_check(1,1)                      = {'-'};                                                                    % because write cells doesnt allow missing values

    writecell(emg_check,emg_check_filename);                                                                        % save file
else
    emg_check = readcell(emg_check_filename);
end

for iTrial = 1:length(trialList)

    trialName   = trialList{iTrial};
    [osimFiles] = getdirosimfiles_BOPS(trialName);                                                                  % get directories of opensim files for this trial

    check_values    =  logical(cell2mat(emg_check(iTrial+1,2:end))');

    emg_data        = load_sto_file(osimFiles.emg);                                                                 % load and transform EMG data
    channel_names   = fields(emg_data);
    emg_data        = struct2array(emg_data);
    nChannels       = length(channel_names);

    [ax, ~,FirstCol,LastRow,~] = tight_subplotBG (nChannels-1,0,[],[],[],[0.05 0.2 0.6 0.6]);                                      % plot all the EMG channels to inspect
    plot_fig = gcf;
    plot_fig.Units = 'pixels';
    
    [x,y,w,h] = matWinPos;                                                                                          % get siye and position of the pc screen

    w_box = w/8;                                                                                                    % define dimensions of the figure and location based on number of channels
    h_box = (nChannels*0.03)*h;
    x_box = plot_fig.Position(3) + (w - (plot_fig.Position(1) + plot_fig.Position(3)))/2;
    y_box = y+(h-h_box)/2;

    for iEMG = 2:nChannels
        plot(ax(iEMG-1),emg_data(:,iEMG))
        title(ax(iEMG-1),channel_names(iEMG))
    end
    mmfn_inspect
    tight_subplot_ticks(ax,LastRow,FirstCol)


    fig_check_boxes = figure("Position",[x_box,y_box,w_box,h_box]);                                                 % create figure for check boxes
    y_boxes = 0.05:0.8/(nChannels-1):0.9;
    
    for iEMG = flip(2:nChannels)
        check_boxes(iEMG-1) = uicontrol(fig_check_boxes,'Style','checkbox','Value', check_values(iEMG-1),...
            'String',channel_names{iEMG},'Units','normalized',...
            'Position',[0.1 y_boxes(iEMG-1) 0.9 0.1],'Callback', @(src,evnt)update_emg_check);                      % check boxes
    end

    uicontrol(fig_check_boxes,'Style','pushbutton',...
        'String','Next','Units','normalized',...
        'Position',[0.35 0.025 0.25 0.05],'Callback',@(src,evnt)next);                                               % "next" button

    uiwait(fig_check_boxes);

end



    function update_emg_check()                                                                                     % close all the figures

        for i=1:length(check_boxes)
            emg_check{iTrial+1,i+1} = check_boxes(i).Value;
            if check_boxes(i).Value == 0
                ax(i).Children.Color = [1 0 0];
            end
        end

    end

    function next()        
        saveas(plot_fig,[savedir fp trialName '.jpeg'])
        writecell(emg_check,emg_check_filename);     
        close all
    end

end
