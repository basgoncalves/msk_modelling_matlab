%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------

%check EMG signals
function checkEMGdata_multiple (DirC3D,muscleString)

if nargin <1
    DirC3D = uigetdir('','select Folder with c3d files for EMG trials');
end

cd (DirC3D);
idcs   = strfind(DirC3D,'\');
subjectName = DirC3D(idcs(end-1)+1:idcs(end)-1);
% get all the c3d files in the path

Folders = dir ('*.c3d');
trialNames = struct2cell(Folders)';                 % conbvert from struct to cell
trialNames = trialNames (:,1);                      % get only the first column (with the names of the trials)
TrialsPerPlot = ceil(length(trialNames)/16);

%% Drop down menu Trials
screensize = get( 0, 'Screensize' )/1.2;
Xpos = screensize(1); Ypos = screensize(2);
Xsize = screensize(3); Ysize = screensize(4);

f = figure('Position', [180 75 Xsize Ysize]);
set(gca,'Color',[.8 .8 .8])

%trialnames
c = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
c.Position = [Dim(3)*0.01 Dim(4)*0.05 80 20];                    % [Xpos Ypos Xsize Ysize]
c.String = trialNames;
c.Callback = @Subplots;

Muscles = uicontrol;
Muscles.String = 'muscles';
Muscles.Position = [Dim(3)*0.01 Dim(4)*0.65 80 20];                    % [Xpos Ypos Xsize Ysize]
Muscles = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
Muscles.Position = [Dim(3)*0.01 Dim(4)*0.6 80 20];                    % [Xpos Ypos Xsize Ysize]
Muscles.String = muscleString;
Muscles.Callback = @Subplots;

%% create subplot button

pushCloseAll = uicontrol;
pushCloseAll.String = 'subplots';
Dim = get(gcf, 'Position');
pushCloseAll.Position = [Dim(3)*0.01 Dim(4)*0.20 80 20];                    % [Xpos Ypos Xsize Ysize]
pushCloseAll.Callback = @Subplots;

    function Subplots(src,event)
        %         w = waitbar(0,'Please wait...');
        w = msgbox('Ploting data...');
        for ii = 1:length(trialNames)
            Nplots = ceil(sqrt(length(trialNames)));
            
            figure(f);
            subplot(Nplots,Nplots,ii)
            cla            
            hold off
            filename=trialNames{ii};
            
            % channels to look for in the c3dfile 
            ChannelNames = {'Voltage_1_VM';'Voltage_2_VL';'Voltage_3_RF';'Voltage_4_GRA';'Voltage_5_TA';...
            'Voltage_6_AL';'Voltage_7_ST';'Voltage_8_BF';'Voltage_9_MG';'Voltage_10_LG';...
            'Voltage_11_TFL';'Voltage_12_Gmax';'Voltage_13_Gmed_intra';'Voltage_14_PIR_intra';...
            'Voltage_15_OI_intra';'Voltage_16_QF_intra';'Force_Rig'};
            
            [filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename,ChannelNames);
            
            %filter EMG(high pass) and force (low pass)
            EMGdetrend = detrend(EMGdata);
            Fnyq = Fs/2;
            [b,a] = butter(2,50/Fnyq,'high');
            filter_EMG = filtfilt(b,a,EMGdata);
             
            [b,a] = butter(2,6*1.25/Fnyq,'low');
            ForceData = filtfilt(b,a,EMGdata(:,end));                            % low pass filter Force;
               
            yyaxis left
            p = plot(ForceData);                       % plot Forcedata data
            axis tight
            yyaxis right
            % use different colors for the plots otherwise they all have the same color
            NMuscle = Muscles.Value;
            plot (filter_EMG(:,NMuscle),'LineStyle','-',...
                'Marker','none','Color',p.Color);
            
            title (trialNames{ii},'Interpret','None');
            ylim([-0.5 3]);
            
            
            %             waitbar(ii/length(trialNames),w,'plotting data');
        end
        close(w) %% close waitbar
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
        
       Variables = trialNames;
        [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
        Trials = Variables (idx);
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=1;
        end
        save BadTrials BadTrials
        %         SelectNextMuscle
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
        
        Variables = trialNames;
        [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
        Trials = Variables (idx);    
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=2;
        end
        save BadTrials BadTrials
        %         SelectNextMuscle
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
        if size(BadTrials,2) == length(c.String)
            BadTrials(:,end+1) = {0};
        end
        pcolor(cell2mat(BadTrials));
        mycolors = [0 0 1;1 1 0; 1 0 0];            % [blue yellow red]
        colormap(mycolors);
        colorbar('Ticks',[0,1,2],'TickLabels',{'good','average','bad'});
        NXticks = 1;
        xticks (NXticks:NXticks:length(c.String))
        xticklabels (c.String(NXticks:NXticks:length(c.String)));
        xtickangle (90);
        
        yticks (1:length(Muscles.String)-1);
        NYticks = round(length(Muscles.String)/length(yticks));
        yticklabels (Muscles.String(NYticks:NYticks:end));
        
        fullscreenFig(0.9,0.9)
        
    end

end