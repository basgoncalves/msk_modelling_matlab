% max speed plots

function velocityMax = maxSpeedMarkers (DirC3DFile, Markers,GaitCycle)
if ~exist('DirC3DFile')
   [DirC3DFile FilePath] = uigetfile ('*.c3d','select the .c3d file');
   DirC3DFile = ([FilePath DirC3DFile]);
end

   data = btk_loadc3d(DirC3DFile);

%select markers
if ~exist('Markers')
   MarkersC3D = fieldnames(data.marker_data.Markers);
   [idx,~] = listdlg('PromptString',{'Choose the marers to measrure max speed from'},'ListString',MarkersC3D);
   Markers =  MarkersC3D(idx);
end

% if GaitCycle does not exist use the whole length of the trial 
if ~exist('GaitCycle') || isempty(GaitCycle)
  GaitCycle = 1:length(data.marker_data.Markers.(Markers{1}));
  plotData = 0;
else 
    GaitCycle = GaitCycle(1):GaitCycle(2);
    plotData = 1;
end

fs = data.marker_data.Info.frequency;
PathMArkers=[];
for ii = 1: length(Markers)
PathMArkers(:,ii) = smooth(smooth(smooth(data.marker_data.Markers.(Markers{ii})(:,2))));

end


% calclate velocity 
GaitCycle = GaitCycle(GaitCycle>0);
GaitCycle = GaitCycle(length(GaitCycle)/4:length(GaitCycle)/4*3);       %get only the middle 2/4 of the gait cycle to avoid artifacts
x = PathMArkers(GaitCycle,:)/1000;
velocity = calcVelocity (x,fs);

if plotData ==0
    f1 = figure;
    plot(velocity)
    title(DirC3DFile)
    [x,~]=ginput(2);
    selectedData = velocity(round(x(1)):round(x(2)),:);
else
    selectedData = velocity;
end

velocityMax = mean(max(movmean(abs(selectedData),fs)));
close gcf