
%check EMG signals
function checkEMGdataFAI

subjectDir = uigetdir('','select Folder with c3d files for isometric trials');
cd (subjectDir);
idcs   = strfind(subjectDir,'\');
subjectName = subjectDir(idcs(end-1)+1:idcs(end)-1);
% get all the c3d files in the path

Folders = dir ('*.c3d');
trialNames = struct2cell(Folders)';                 % conbvert from struct to cell
trialNames = trialNames (:,1);                      % get only the first column (with the names of the trials)

%% Drop down menu Trials
screensize = get( 0, 'Screensize' )/1.2;
Xpos = screensize(1); Ypos = screensize(2);
Xsize = screensize(3); Ysize = screensize(4);

f = figure('Position', [180 75 Xsize Ysize]);
set(gca,'Color',[.8 .8 .8])
c = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
c.Position = [Dim(3)*0.01 Dim(4)*0.05 80 20];                    % [Xpos Ypos Xsize Ysize]
c.String = trialNames;
c.Callback = @selection;

    function selection(src,event)
        val = c.Value;
        str = c.String;
        
        muscle=Muscles.String{Muscles.Value};
        
        filename=str{val};
        [filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename);
        EMGdetrend = detrend(EMGdata);
        Fnyq = Fs/2;
        
        [b,a] = butter(2,50/Fnyq,'high');
        filter_EMG = filtfilt(b,a,EMGdetrend);
        [b,a] = butter(2,6*1.25/Fnyq,'low');
        ForceData = filtfilt(b,a,EMGdata(:,end));                            % low pass filter Force;
        colors ='rbmykrbmykrbmyk';
        colors = colors(randi([1 length(colors)]));
%         hold off
        yyaxis left
        
        
        plot(ForceData,'Color',colors);                       % plot Forcedata data
        axis tight
        yyaxis right
                                          % use different colors for the plots otherwise they all have the same color
        NMuscle = Muscles.Value;
        F(Muscles.Value) = plot (filter_EMG(:,NMuscle),'LineStyle','-',...
            'Marker','none','Color',colors);
        
        title ('Muscle EMG','Interpret','None');
        legend;
        hLegend = findobj(gcf, 'Type', 'Legend');
        Nlgd =length(hLegend.String);
        NameTrial = sprintf('%s-%s',filename(1:end-4),muscle);
        legend ([hLegend.String(1:Nlgd-1) NameTrial],'Interpreter','none');
        ylim([-0.5 3]);
        hold on
    end


%% Clear plot button

pushCloseAll = uicontrol;
pushCloseAll.String = 'Clear plot';
Dim = get(gcf, 'Position');
pushCloseAll.Position = [Dim(3)*0.01 Dim(4)*0.20 80 20];                    % [Xpos Ypos Xsize Ysize]
pushCloseAll.Callback = @CloseAll;

    function CloseAll(src,event)
        yyaxis left
        hold off
        plot(NaN,NaN)
        yyaxis right
        hold off
        plot(NaN,NaN)
        legend('hide');
    end

%% Next trial button
pushNext = uicontrol;
pushNext.String = 'Next Trial';
Dim = get(gcf, 'Position');

pushNext.Position = [Dim(3)*0.01 Dim(4)*0.1 80 20];                    % [Xpos Ypos Xsize Ysize]
pushNext.Callback = @plotNextTrial;

    function plotNextTrial(src,event)
        c.Value = c.Value+1;
        selection
        
    end

%% Previous trial button

pushPrevious = uicontrol;
pushPrevious.String = 'Previous Trial';
Dim = get(gcf, 'Position');
pushPrevious.Position = [Dim(3)*0.01 Dim(4)*0.15 80 20];                    % [Xpos Ypos Xsize Ysize]
pushPrevious.Callback = @plotPreviousTrial;

    function plotPreviousTrial(src,event)
        c.Value = c.Value-1;
        selection
        
    end

%% Next muscle button - 90% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'Next muscle';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.9 80 20];                    % [Xpos Ypos Xsize Ysize]
pushSelectRange.Callback = @SelectNextMuscle;

    function SelectNextMuscle(src,event)
        if Muscles.Value == length(Muscles.String)
            Muscles.Value = 1;
        else
            Muscles.Value = Muscles.Value+1;     % move to the next muscle
        end
        CloseEMG
        selectionMuscles                     % select muscle fucntion
        
    end

%% Previous muscle button - 85% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'Previous muscle';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.85 80 20];                    % [Xpos Ypos Xsize Ysize]
pushSelectRange.Callback = @SelectPreviousMuscle;

    function SelectPreviousMuscle(src,event)
        
        if Muscles.Value == 1
            Muscles.Value = length(Muscles.String);
        else
            Muscles.Value = Muscles.Value-1;     % move to the previous muscle
        end
        CloseEMG
        selectionMuscles                     % select muscle fucntion
        
        
    end

%% Average trial button - 80% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'Average';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.8 80 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectRange,'Backgroundcolor','y');
pushSelectRange.Callback = @SelectAverage;


    function SelectAverage(src,event)
        
        val = c.Value;
        str = c.String;
        Trial = str{val};
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        BadTrials{Muscles.Value,c.Value}=1;
        save BadTrials BadTrials
        CloseEMG
%         SelectNextMuscle
        plotNextTrial
    end

%% Bad trial button - 75% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'Bad';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.75 80 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectRange,'Backgroundcolor','r');
pushSelectRange.Callback = @SelectBad;


    function SelectBad(src,event)
        
        val = c.Value;
        str = c.String;
        Trial = str{val};
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        BadTrials{Muscles.Value,c.Value}=2;
        save BadTrials BadTrials
        CloseEMG
%         SelectNextMuscle
        plotNextTrial
    end

%% Close EMG plots button - 70% height

pushCloseAll = uicontrol;
pushCloseAll.String = 'Close EMG plots';
Dim = get(gcf, 'Position');
pushCloseAll.Position = [Dim(3)*0.01 Dim(4)*0.70 80 20];                    % [Xpos Ypos Xsize Ysize]
pushCloseAll.Callback = @CloseEMG;

    function CloseEMG(src,event)
        
        yyaxis right
        hold off
        plot(NaN,NaN);
        legend;
    end

%% Drop down menu Muscles - 65% height
Muscles = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
Muscles.Position = [Dim(3)*0.01 Dim(4)*0.65 80 20];                    % [Xpos Ypos Xsize Ysize]
Muscles.String = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF','Force'};
Muscles.Callback = @selectionMuscles;

    function selectionMuscles(~,~)
        val = Muscles.Value;
        str = Muscles.String;
        muscle =str{val};
        
        filename = c.String{c.Value};
        [filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename);
        EMGdetrend = detrend(EMGdata);
        Fnyq = Fs/2;
        [b,a] = butter(2,50/Fnyq,'high');
        filter_EMG = filtfilt(b,a,EMGdetrend);
        
        hold on
        
        colors ='rgbcmykrgbcmykrgbcmyk';
        NMuscle = Muscles.Value;
        F(Muscles.Value) = plot (filter_EMG(:,NMuscle),'LineStyle','-',...
            'Marker','none','Color',colors(randi([1 length(colors)])));
        legend;
        hLegend = findobj(gcf, 'Type', 'Legend');
        Nlgd =length(hLegend.String);
        NameTrial = sprintf('%s-%s',filename(1:end-4),muscle);
        legend ([hLegend.String(1:Nlgd-1) NameTrial]);
        ylim([-0.5 3]);
        
    end

%% Check Bad trial button

pushSelectRange = uicontrol;
pushSelectRange.String = 'Check Bad Trials';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.5 80 20];                    % [Xpos Ypos Xsize Ysize]
pushSelectRange.Callback = @SelectCheckBad;


    function SelectCheckBad (src,event)
        
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        figure
        pcolor(cell2mat(BadTrials));
        mycolors = [0 0 1;1 1 0; 1 0 0];            % [blue yellow red]
        colormap(mycolors);
        colorbar('Ticks',[0,1,2],'TickLabels',{'good','average','bad'});
        NXticks = round(length(c.String)/length(xticks));
        xticklabels (c.String(NXticks:NXticks:end));
        xtickangle (90);
        
        yticks (1:length(Muscles.String)-1);
        NYticks = round(length(Muscles.String)/length(yticks));
        yticklabels (Muscles.String(NYticks:NYticks:end));
        
        
    end

end