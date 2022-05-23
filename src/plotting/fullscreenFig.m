% full screen figure
% Needs function "resizeFigure"

function fullscreenFig(Xratio,Yratio,FontSizeRatio)

% select current figure
hFig  = findobj('Type','Figure'); hFig = hFig(1);


if ~exist ('Xratio')|| Xratio> 1 || Xratio<=0
   Xratio = 1;
  
end
if ~exist ('Yratio')|| Yratio> 1 || Yratio<=0
  Yratio = 1;
  
end
if ~exist ('FontSizeRatio')|| FontSizeRatio> 1 || FontSizeRatio<=0
  FontSizeRatio = max(Xratio,Yratio);
end

resizeFigure (Xratio,Yratio)

%check if legend exists
a= gca;
FS_ax = a.FontSize;
FS_tt = a.Title.FontSize;
FS_xlab = a.XLabel.FontSize;
FS_ylab = a.YLabel.FontSize;
Text = findobj(a, 'Type', 'Text');
for i= 1:length(Text)
FS_txt(i) = Text(i).FontSize;
end
if ~isempty(a.Legend)
       
    lhd=legend;
    lhdSize = get(lhd,'FontSize');  
    set(lhd,'FontSize',lhdSize*FontSizeRatio)
end

    

for i= 1:length(Text)
    Text(i).FontSize = FS_txt(i)*FontSizeRatio;
end

    %match font size to all axis
N =  length(hFig.Children);
for ii = 1:N
    if contains(class(hFig.Children(ii)),'Axes')
        hFig.Children(ii).FontSize = FS_ax*FontSizeRatio;
        hFig.Children(ii).YLabel.FontSize = FS_ylab*FontSizeRatio;
        hFig.Children(ii).XLabel.FontSize = FS_xlab*FontSizeRatio;
        hFig.Children(ii).Title.FontSize = FS_tt*FontSizeRatio;
    elseif contains(class(hFig.Children(ii)),'Legend')
        hFig.Children(ii).FontSize = FS_tt*FontSizeRatio;
    end    
end

