%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   ImportEMGc3d
%   btk_loadc3d
%   
%INPUT
%   DirC3D = full directory of your C3D
%   muscleString = cell with the names of your muscles (titles of the
%   plots)
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------

%check EMG signals
function f = checkEMGdata_dynamic (DirC3D,muscleString,TrialList)

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
trialNames = trialNames(contains(trialNames,TrialList));
TrialsPerPlot = ceil(length(trialNames)/16);

%% Drop down menu Trials
screensize = get( 0, 'Screensize' )/1.2;
Xpos = screensize(1); Ypos = screensize(2);
Xsize = screensize(3); Ysize = screensize(4);

f = figure('Position', [180 75 Xsize Ysize], ...
    'Name',subjectName);
set(gca,'Color',[.8 .8 .8])
Dim = get(gcf, 'Position');
%trialnames
c = uicontrol(f,'Style','popupmenu');
c.Position = [Dim(3)*0.01 Dim(4)*0.05 80 20];                    % [Xpos Ypos Xsize Ysize]
c.String = trialNames;
c.Callback = @Subplots;

Muscles = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
Muscles.Position = [Dim(3)*0.01 Dim(4)*0.6 80 20];                    % [Xpos Ypos Xsize Ysize]
Muscles.String = muscleString;
Muscles.Callback = @Subplots;
allMuscles = Muscles.String;
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
            data = btk_loadc3d(filename);
            Fnyq = Fs/2;
            %Combine all the force plates data
            if isfield(data,'fp_data')
                data = combineForcePlates_multiple(data);
                [b,a] = butter(2,6*1.25/Fnyq,'low');
                ForceData = filtfilt(b,a,data.GRF.FP.F(:,3));  % low pass filter Force;      
            else
                ForceData
            end
            %filter EMG(high pass) and force (low pass)
            EMGdetrend = detrend(EMGdata);
            [b,a] = butter(2,50/Fnyq,'high');
            filter_EMG = filtfilt(b,a,EMGdata);
            EMG_lp = EMGLinearEnvelope(EMGdata,Fs,[50 300],6);      
            
            yyaxis left
            p = plot(ForceData);                       % plot Forcedata data
            axis tight
            yyaxis right
            % use different colors for the plots otherwise they all have the same color
            NMuscle = Muscles.Value;
            plot (filter_EMG(:,NMuscle),'LineStyle','-',...
                'Marker','none','Color',p.Color);
            hold on
            plot (EMG_lp(:,NMuscle),'LineStyle','-',...
                'Marker','none','Color','r');
            
            title (trialNames{ii},'Interpret','None');
            ylim([-0.5 3]);
            if ii == 1
               legend('Bandpass EMG (6-)','Vert GRF') 
            end
            
            %             waitbar(ii/length(trialNames),w,'plotting data');
        end
        close(w) %% close waitbar
    end
%% create next muscle button


NextB = uicontrol;
NextB.String = 'next';
NextB.Position = [Dim(3)*0.01 Dim(4)*0.7 80 20];                    % [Xpos Ypos Xsize Ysize]
NextB.Callback = @NextMuscle;

    function NextMuscle(src,event)
        %         w = waitbar(0,'Please wait...');
        
        Muscles.Value = Muscles.Value+1;
        NMuscle = Muscles.Value;
        Subplots
        
    end

%% create previous muscle button


NextB = uicontrol;
NextB.String = 'previous';
NextB.Position = [Dim(3)*0.01 Dim(4)*0.65 80 20];                    % [Xpos Ypos Xsize Ysize]
NextB.Callback = @PreviousMuscle;

    function PreviousMuscle(src,event)
        %         w = waitbar(0,'Please wait...');
       
        Muscles.Value = Muscles.Value-1;
        NMuscle = Muscles.Value;
        Subplots
        
    end
%% Good trial button - 90% height

pushSelectGood = uicontrol;
pushSelectGood.String = 'Good';
Dim = get(gcf, 'Position');
pushSelectGood.Position = [Dim(3)*0.01 Dim(4)*0.85 80 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectGood,'Backgroundcolor','g');
pushSelectGood.Callback = @SelectGood;


    function SelectGood(src,event)
        
       Variables = trialNames;
        [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
        Trials = Variables (idx);
        allMuscles = Muscles.String;
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load BadTrials
        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=0;
        end
        
        save BadTrials BadTrials trialNames allMuscles
     
    end


%% Average trial button - 80% height

pushSelectAverage = uicontrol;
pushSelectAverage.String = 'Average';
Dim = get(gcf, 'Position');
pushSelectAverage.Position = [Dim(3)*0.01 Dim(4)*0.8 80 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectAverage,'Backgroundcolor','y');
pushSelectAverage.Callback = @SelectAverage;


    function SelectAverage(src,event)
        
       Variables = trialNames;
        [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
        Trials = Variables (idx);
        allMuscles = Muscles.String;
        muscle=Muscles.String{Muscles.Value};
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')

        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=1;
        end
        save BadTrials BadTrials trialNames allMuscles
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
        allMuscles = Muscles.String;
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(c.String));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')

        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=2;
        end
        save BadTrials BadTrials trialNames allMuscles
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
            load ('BadTrials.mat')
        end
        figure
        if size(BadTrials,2) == length(c.String)
            BadTrials(:,end+1) = {1}; % this column will not show in the fig but can be used for the colors
            BadTrials(1,end) = {2};
        end
        if size(BadTrials,1) == length(Muscles.String)
            BadTrials(end+1,:) = {0};
        end
        
        pcolor(cell2mat(BadTrials));
        mycolors = [0 1 0;1 1 0; 1 0 0];            % [green yellow red]
        colormap(mycolors);
        colorbar('Ticks',[0,1,2],'TickLabels',{'good','average','bad'});
        NXticks = 1;
        xticks (NXticks:NXticks:length(c.String))
        xticklabels (c.String(NXticks:NXticks:length(c.String)));
        xtickangle (90);
        
        yticks (1:length(Muscles.String));
        NYticks = round(length(Muscles.String)/length(yticks));
        yticklabels (Muscles.String(NYticks:NYticks:end));
        
        fullscreenFig(0.9,0.9)
        
    end

end