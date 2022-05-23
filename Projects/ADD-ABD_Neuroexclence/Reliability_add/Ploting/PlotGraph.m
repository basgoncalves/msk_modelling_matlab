% open different figures for each participant 
function PlotGraph
%% get the folders for each subject
subjectDir = uigetdir('','Select subject folder');
Folders = dir (sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
Folders (1:2)=[];
deletedFolders = 0;

for i = 1: length (Folders)
    n = i - deletedFolders;
    if Folders(n).isdir ==0
       Folders(n)=[];
       deletedFolders=deletedFolders+1;
    end
end

trialNames = struct2cell(Folders)';                 % conbvert from struct to cell
trialNames = trialNames (:,1);                      % get only the first column (with the names of the trials)

%% Drop down menu
f = figure;
c = uicontrol(f,'Style','popupmenu');
c.Position = [20 75 80 20];                    % [Xpos Ypos Xsize Ysize]           
c.String = trialNames;
c.Callback = @selection;

function selection(src,event)
        val = c.Value;
        str = c.String;
        str{val};
        F = openfig (sprintf('%s\\ElaboratedData\\sessionData\\%s\\ForceData.fig',subjectDir,str{val}))
%         axObjs = F.Children
%         dataObjs = axObjs.Children
%         x = dataObjs(1).XData
%         y = dataObjs(1).YData
%         close
%         plot (x,y)
end

%% Next button
pushNext = uicontrol;
pushNext.String = 'Next Trial';
pushNext.Position = [100 75 80 20];                    % [Xpos Ypos Xsize Ysize]  
pushNext.Callback = @plotButtonPushed;

    function plotButtonPushed(src,event)
       c.Value = c.Value+1;
       val = c.Value;
       str = c.String;
       str{val};
       F = openfig (sprintf('%s\\ElaboratedData\\sessionData\\%s\\ForceData.fig',subjectDir,str{val}))
    end

%% Previous button

pushPrevious = uicontrol;
pushPrevious.String = 'Previous Trial';
pushPrevious.Position = [180 75 80 20];                    % [Xpos Ypos Xsize Ysize]  
pushPrevious.Callback = @plotPreviousTrial;

    function plotPreviousTrial(src,event)
       c.Value = c.Value-1;
       val = c.Value;
       str = c.String;
       str{val};
       F = openfig (sprintf('%s\\ElaboratedData\\sessionData\\%s\\ForceData.fig',subjectDir,str{val}))
    end

%% Close all button

pushCloseAll = uicontrol;
pushCloseAll.String = 'Close all figures';
pushCloseAll.Position = [260 75 80 20];                    % [Xpos Ypos Xsize Ysize]  
pushCloseAll.Callback = @CloseAll;

    function CloseAll(src,event)
       close all
    end

%% Select range button

pushSelectRange = uicontrol;
pushSelectRange.String = 'Select Data Range';
pushSelectRange.Position = [20 30 120 20];                    % [Xpos Ypos Xsize Ysize]  
pushSelectRange.Callback = @SelectRange;

    function SelectRange(src,event)
       val = c.Value;
       str = c.String;
       str{val};
       F = openfig (sprintf('%s\\ElaboratedData\\sessionData\\%s\\ForceData.fig',subjectDir,str{val}))
       [Xselect,~] = ginput(2);
       time1 = round(Xselect(1));
       time2 = round(Xselect(2));
       axObjs = F.Children;
       dataObjs = axObjs.Children;
       Xdata = dataObjs(1).XData;
       Ydata = dataObjs(1).YData;
       MeanData = mean (Ydata(time1:time2))
      
       
    end

end