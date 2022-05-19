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
function f = checkEMGdata_simple (DirC3D,muscleString,TrialList)

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

%% Drop down menu Trials - 60% height
screensize = get( 0, 'Screensize' )/1.2;
Xpos = screensize(1); Ypos = screensize(2);
Xsize = screensize(3); Ysize = screensize(4);

f = figure('Position', [180 75 Xsize Ysize], ...
    'Name',subjectName);
set(gca,'Color',[.8 .8 .8])
Dim = get(gcf, 'Position');

Muscles = uicontrol(f,'Style','popupmenu');
Dim = get(gcf, 'Position');
Muscles.Position = [Dim(3)*0.01 Dim(4)*0.6 80 20];                    % [Xpos Ypos Xsize Ysize]
Muscles.String = muscleString;
Muscles.Callback = @SelectCheckBad;
allMuscles = Muscles.String;

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
            BadTrials=cell(length(Muscles.String),length(trialNames));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')

        end
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=1;
        end
        save BadTrials BadTrials trialNames allMuscles
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
            BadTrials=cell(length(Muscles.String),length(trialNames));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')
        end
        
        
        for ii = 1:length(Trials)
            BadTrials{Muscles.Value,idx(ii)}=2;
        end
        save BadTrials BadTrials trialNames allMuscles
    end

%% "Intra muscular all bad" button - 70% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'Intramuscular all bad';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.7 120 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectRange,'Backgroundcolor','r');
pushSelectRange.Callback = @IntraAllBad;


    function IntraAllBad(src,event)
        
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            BadTrials=cell(length(Muscles.String),length(trialNames));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')
        end
        
        Variables = trialNames;
        idx = length(Muscles.String)-3:length(Muscles.String);
        for i = idx
            Muscles.Value = i;
            Trials = 1:length(Variables);
            allMuscles = Muscles.String;
            for ii = 1:length(Trials)
                BadTrials{Muscles.Value,Trials(ii)}=2;
            end            
        end
         save BadTrials BadTrials trialNames allMuscles
    end

%% "Check Bad trials" button - 50% height 

pushSelectRange = uicontrol;
pushSelectRange.String = 'Check Bad Trials';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.5 80 20];                    % [Xpos Ypos Xsize Ysize]
pushSelectRange.Callback = @SelectCheckBad;


    function SelectCheckBad (src,event)
        
        fileExisting  = (exist(fullfile(cd, 'BadTrials.mat'), 'file') == 2);
        if fileExisting==0
            
            Folders = dir ('*.c3d');
            trialNames = struct2cell(Folders)';                 % conbvert from struct to cell
            trialNames = trialNames (:,1);                      % get only the first column (with the names of the trials)
            trialNames = trialNames(contains(trialNames,TrialList));
            
            BadTrials=cell(length(Muscles.String),length(trialNames));
            BadTrials(:,:)={0};
        else
            load ('BadTrials.mat')
        end
        
        if size(BadTrials,2) == length(trialNames)
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
        xticks (NXticks:NXticks:length(trialNames))
        xticklabels (trialNames(NXticks:NXticks:length(trialNames)));
        xtickangle (90);
        
        yticks (1:length(Muscles.String));
        NYticks = round(length(Muscles.String)/length(yticks));
        yticklabels (Muscles.String(NYticks:NYticks:end));
        

        
    end

%% Delete "BadTrials" button - 40% height

pushSelectRange = uicontrol;
pushSelectRange.String = 'delete "BadTrials.mat"';
Dim = get(gcf, 'Position');
pushSelectRange.Position = [Dim(3)*0.01 Dim(4)*0.4 120 20];                    % [Xpos Ypos Xsize Ysize]
% Change to red all these buttons
set(pushSelectRange,'Backgroundcolor','w');
pushSelectRange.Callback = @DeleteBad;

    function DeleteBad(src,event)
            delete ('BadTrials.mat')
    end

end