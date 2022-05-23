%% MeanEMG_perSubject

mkdir([DirEMGdata fp 'EMGplots'])
Subjects = fields(EMG)';
STch = find(contains(description.channels,'_st'));      % channels contianing ST data
BFch = find(contains(description.channels,'_bf'));      % channels contianing BF data
Fch = find(contains(description.channels,'_right'));    % channels contianing Force data
fsForce = description.filter_data.force.sample_freq;    % sample frequency for Force channel


Plotfig = 1; % 0 = do not plot; 1 = plot;
MeanEMG_perSubj = struct;
RelativeForce = struct;
MVCtrial = {};
row = 0;
for SS = Subjects  % loop subjects
    row = row+1;
    mkdir([DirEMGdata fp 'EMGplots' fp SS{1}])
    Conditions = fields(EMG.(SS{1}))';
    % MVC pre
    [M1,T1] = MVIC_hams (EMG, SS{1},'MVC',Fch,fsForce,Plotfig);
    [M2,T2] = MVIC_hams (EMG, SS{1},'pre_knee',Fch,fsForce,Plotfig);
    [M3,T3] = MVIC_hams (EMG, SS{1},'pre_both',Fch,fsForce,Plotfig);
    [MVCpre,Midxpre] = max([M2 M3]);
    
    if Midxpre==1
        MVCtrial{row,1} = ['pre_knee-' T2];
    elseif Midxpre==2
        MVCtrial{row,1} = ['pre_both-' T3];
    end
    
    % MVC post
    [M2,T2] = MVIC_hams (EMG, SS{1},'post_knee',Fch,fsForce,Plotfig);
    [M3,T3] = MVIC_hams (EMG, SS{1},'post_both',Fch,fsForce,Plotfig);
    [MVCpost,Midxpost] = max([M2 M3]);
    
    if Midxpost==1
        MVCtrial{row,2} = ['post_knee-' T2];
    elseif Midxpost==2
        MVCtrial{row,2} = ['post_both-' T3];
    end
    
    if ~isfield(MeanEMG_perSubj,'MVC')
        MeanEMG_perSubj.MVC.ST = [];
        MeanEMG_perSubj.MVC.BF = [];
        RelativeForce.MVC = [];
    end
    if ~isfield(MeanEMG_perSubj,'MVCpost')
        MeanEMG_perSubj.MVCpost.ST = [];
        MeanEMG_perSubj.MVCpost.BF = [];
        RelativeForce.MVC = [];
    end
    
    for CC = Conditions % loop conditions
        col = find(contains(Conditions,CC{1}));
        Trials = fields(EMG.(SS{1}).(CC{1}))';
        saveDir = [DirEMGdata fp 'EMGplots' fp SS{1} fp CC{1}];
        mkdir(saveDir)
        
        if ~isfield(MeanEMG_perSubj,(CC{1})) && contains(CC{1},{'25' '50' '75'})
            RelativeForce.(CC{1}) = [];
            MeanEMG_perSubj.(CC{1}).ST = [];
            MeanEMG_perSubj.(CC{1}).BF = [];
        end
        
        ST = []; % emg for ST
        BF = []; % emg for BF
        relativeForceROI =[]; % mean relative force for each task
        for TT = Trials
            
            F = EMG.(SS{1}).(CC{1}).(TT{1}).Data(:,Fch); % force data
            
            if max(F)<10  % threshold to define if the force channel is "valid"
                continue
            end
            
            if contains(CC{1},'25')
                t = 0.25; % threshold
            elseif contains(CC{1},'50')
                t = 0.5;
            elseif contains(CC{1},'75')
                t = 0.75;
            elseif contains(CC{1},'post') && contains(CC{1},{'_knee' 'both'})
                t = 1;
                MVC = MVCpost;
            elseif contains(CC{1},'pre') && contains(CC{1},{'_knee' 'both'})...
                    && ~contains(CC{1},'MVC')
                t = 1;
                MVC = MVCpre;
            else
                continue
            end
            % find region of interest (closest point+/0.5sec to the determined
            % percentage)
            fROI = fsForce*3;%frames for ROI
            figure
            hold on
            plot(F)
            [x,~] = ginput(2);
            ROI = round(x(1):x(2));
            
            F2 = NaN(length(F),1);
            F2(ROI) = F(ROI);
            
            [m,i] = min(movmean(abs(F2-MVC*t),fROI)); %ROI closest to target force
            ROI = i-fROI/2 : i+fROI/2;
            relativeForceROI(end+1) = mean(F2(ROI))/MVC*100;
            
            ST(end+1,:) = mean(EMG.(SS{1}).(CC{1}).(TT{1}).Data(ROI,STch));
            BF(end+1,:) = mean(EMG.(SS{1}).(CC{1}).(TT{1}).Data(ROI,BFch));
            badtrialsBF = {};
            badtrialsST = {};
            list = {};
            if Plotfig ==1
                figure
                mmfn
                for k = 1:length(BFch)
                    subplot(4,4,k)
                    hold on
                    plot(F)
                    plot([ROI(1) ROI(1)],[0 max(ylim)],'--','MarkerSize',20)
                    plot([ROI(end) ROI(end)],[0 MVC*t],'--','MarkerSize',20)
                    
                    ylabel('Force (N)'); xlabel('fames');
                    
                    % plot EMG data
                    yyaxis right
                    plot(EMG.(SS{1}).(CC{1}).(TT{1}).Data(:,BFch(k)))
                    plot(EMG.(SS{1}).(CC{1}).(TT{1}).Data(:,STch(k)))
                    
                    plot([min(xlim) max(xlim)],[BF(k) BF(k)],'--','MarkerSize',20)
                    tt = ['channel_' num2str(k)];
                    title(tt,'Interpreter','none')
                    list{end+1} = tt;
                end
                
                
                tt = sprintf('%s (%.f%%)',CC{1}, relativeForceROI(end));
                suptitle(tt,'Interpreter','none')
                [idx,~] = listdlg('PromptString',{'Select bad BF trials'},...
                    'ListString',list);
                
                
                cd(saveDir)
                tname = [CC{1} '_' TT{1} num2str(k) '.tif'];
                saveas(gcf,tname)
            end
            
            
            
            
            % semitendinousus average EMG for a single trial
            badtrialsST = find(contains(badtrialsST,'Yes'));
            %             badtrials = ismember(STch,EMG.(SS{1}).(CC{1}).(TT{1}).BadTrials);
            ST(end,badtrialsST) = NaN;
            
            % biceps femoris  average EMG for a single trial
            %             badtrials = ismember(BFch,EMG.(SS{1}).(CC{1}).(TT{1}).BadTrials);
            badtrialsBF = find(contains(badtrialsBF,'Yes'));
            BF(end,badtrialsBF) = NaN;
            
            %             % (un)comment to plot the force data
            
            close all
        end
        
        if contains(CC{1},{'post' '_knee' 'both'})
            RelativeForce.MVC(row,1) = mean(relativeForceROI);
        else
            RelativeForce.(CC{1})(row,1) = mean(relativeForceROI);
        end
        
        
        % MVC EMG pre
        if contains(CC{1},{'pre'}) && contains(CC{1},{'_knee' 'both'})
            maxST(1,:) = max([MeanEMG_perSubj.MVC.ST; ST]);
            maxBF(1,:) = max([MeanEMG_perSubj.MVC.BF; BF]);
            MeanEMG_perSubj.MVC.ST(row,:) = maxST; % max EMG for MVC
            MeanEMG_perSubj.MVC.BF(row,:) = maxBF; % max EMG for MVC
            % zero values = NaN
            MeanEMG_perSubj.MVC.ST(MeanEMG_perSubj.MVC.ST==0) = NaN;
            MeanEMG_perSubj.MVC.BF(MeanEMG_perSubj.MVC.BF==0) = NaN;
            
            
            % MVC EMG post
        elseif contains(CC{1},{'post'}) && contains(CC{1},{'_knee' 'both'})
            
            maxST(1,:) = max([MeanEMG_perSubj.MVCpost.ST; ST]);
            maxBF(1,:) = max([MeanEMG_perSubj.MVCpost.BF; BF]);
            MeanEMG_perSubj.MVCpost.ST(row,:) = maxST; % max EMG for MVC
            MeanEMG_perSubj.MVCpost.BF(row,:) = maxBF; % max EMG for MVC
            % zero values = NaN
            MeanEMG_perSubj.MVCpost.ST(MeanEMG_perSubj.MVCpost.ST==0) = NaN;
            MeanEMG_perSubj.MVCpost.BF(MeanEMG_perSubj.MVCpost.BF==0) = NaN;
            
            
            % submaximal EMG
        else contains(CC{1},{'25' '50' '75'});
            MeanEMG_perSubj.(CC{1}).ST(row,:) = nanmean(ST,1);
            MeanEMG_perSubj.(CC{1}).BF(row,:) = nanmean(BF,1);
            % zero values = NaN
            MeanEMG_perSubj.(CC{1}).ST(MeanEMG_perSubj.(CC{1}).ST==0) = NaN;
            MeanEMG_perSubj.(CC{1}).BF(MeanEMG_perSubj.(CC{1}).BF==0) = NaN;
        end
        
    end
end

