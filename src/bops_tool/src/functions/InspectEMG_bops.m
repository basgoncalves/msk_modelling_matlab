

function InspectEMG_bops(manual_inspect)

if nargin < 1 || all(manual_inspect ~= [1,0])
    out = questdlg('do you want to manually go through all EMG signals');
    if contains(out,'Yes')
        manual_inspect = 1;
    elseif contains(out,'Cancel')
        disp('')
        disp('User canceled "InspectEMG_bops"')
        disp('')
        return
    else
        manual_inspect = 0;
    end
end

fp = filesep;
bops = load_setup_bops;                                                                                             % load bops and subject settings
subject_settings = setupSubject;                                                                                    

trialList       = subject_settings.trials.dynamicTrials;                                                            % use all the trials in the dynamic elaboration folder 
muscle_names    = bops.emg.Muscle;                                                                                  % define muscle names
n_emg           = length(muscle_names);
n_trials        = length(trialList);

savedir             = [subject_settings.directories.Elaborated fp 'EMG_check'];                                     % define and if needed create EMG_check.xlsx
emg_check_filename  = [savedir fp 'EMG_check.xlsx'];
if ~exist(savedir,"dir")
    mkdir(savedir)
end

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

[x,y,w,h] = matWinPos;                                                                                              % get siye and position of the pc screen
dimensions_plot_fig = [w,h,w,h] .* [0.05 0.2 0.6 0.6];

w_box = w/8;                                                                                                        % define dimensions of the check box figure and location based on number of channels
h_box = (1*0.03)*h;
x_box = dimensions_plot_fig(3) + (w - (dimensions_plot_fig(1) + dimensions_plot_fig(3)))/2;
y_box = y+(h-h_box)/2;

dimensions_checkbox_fig = [x_box, y_box,w_box,h_box];                                                               % dimensions of the check box figure

for iTrial = 1:length(trialList)

    trialName   = trialList{iTrial};
    [osimFiles] = getdirosimfiles_BOPS(trialName);                                                                  % get directories of opensim files for this trial

    check_values    =  logical(cell2mat(emg_check(iTrial+1,2:end))');

    emg_data        = load_sto_file(osimFiles.emg);                                                                 % load and transform EMG data
    emg_data        = rmfield(emg_data,"time");
    channel_names   = fields(emg_data);

    emg_data        = struct2array(emg_data);
    nChannels       = length(channel_names);

    dimensions_checkbox_fig(4) = h_box * nChannels;                                                                 % update the size of the checkbox fig based on the number of EMG channels per trial

    [ax, ~,FirstCol,LastRow,~] = tight_subplotBG (nChannels,0,[],[],[],dimensions_plot_fig);                        % plot all the EMG channels to inspect
    plot_fig = gcf;
    plot_fig.Units = 'pixels';


    for iEMG = flip(1:nChannels)                                                                                    % loop through all the EMG channels, plot data and assign red (bad) or blue(good)
        plot(ax(iEMG),emg_data(:,iEMG))
        if check_values(iEMG) == 0
            ax(iEMG).Children.Color = [1 0 0];
        else
            ax(iEMG).Children.Color = [0 0 1];
        end
        title(ax(iEMG),channel_names(iEMG))
    end
    mmfn_inspect
    tight_subplot_ticks(ax,LastRow,FirstCol)
    suptitle(trialName)


    if manual_inspect == 1

        fig_check_boxes = figure("Position",dimensions_checkbox_fig);                                                   % create figure for check boxes
        y_boxes = flip(0.05:0.8/(nChannels):0.9);

        for iEMG = flip(1:nChannels)
            check_boxes(iEMG) = uicontrol(fig_check_boxes,'Style','checkbox','Value', check_values(iEMG),...
                'String',channel_names{iEMG},'Units','normalized',...
                'Position',[0.1 y_boxes(iEMG) 0.9 0.1],'Callback', @(src,evnt)update_emg_check);                    % check boxes
        end

        uicontrol(fig_check_boxes,'Style','pushbutton',...
            'String','Next','Units','normalized',...
            'Position',[0.35 0.025 0.25 0.05],'Callback',@(src,evnt)next);                                          % "next" button

        uiwait(fig_check_boxes);
    end

    saveas(plot_fig,[savedir fp trialName '.jpeg'])                                                                 % save fig and xls file
    writecell(emg_check,emg_check_filename);
    close all

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Callback functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function update_emg_check()                                                                                     % close all the figures

        for i=1:length(check_boxes)
            emg_check{iTrial+1,i+1} = check_boxes(i).Value;
            if check_boxes(i).Value == 0
                ax(i).Children.Color = [1 0 0];                                                                     % assign red to channels with unchecked boxes
            else
                ax(i).Children.Color = [0 0 1];                                                                     % assign blue 
            end
        end
    end

    function next()
        close all
    end

end
