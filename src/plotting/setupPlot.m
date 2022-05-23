
% Arguments (make {} if not to be used): 
% yticks,ylabel,ylim,yticklabels,ytickangle,YLabelRotation,...
% xticks,xlabel,xlim,xticklabels,xtickangle,XLabelRotation,...
% [PosX,PosY,SizeX,SizeY], TitleString, FontSize

function setupPlot(varargin)

ax = gca;
count = 1;
%% Y axis
if nargin > (count-1) && ~isempty(varargin{count})
    ax.YTick = (varargin{count});
end
count = count+1;

if nargin > (count-1) && ~isempty(varargin{count})
     ylabel(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   ylim(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   yticklabels(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   ytickangle(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   ax.YLabel.Rotation = varargin{count};
   if ax.YLabel.Rotation == 0
       ax.YLabel.HorizontalAlignment = 'right';
   end
%    ax.YLabel.Position(1) = ax.YLabel.Position(1)- ax.XTick(1);
end
count = count+1;
 
%% Xaxis
if nargin > (count-1) && ~isempty(varargin{count})
    ax.XTick = (varargin{count});
end
count = count+1;

if nargin > (count-1) && ~isempty(varargin{count})
     xlabel(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   xlim(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   xticklabels(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   xtickangle(varargin{count})
end
count = count+1;

if nargin > (count-1)  && ~isempty(varargin{count})
   ax.XLabelRotation = varargin{count};
end
count = count+1;

%% Size 
if nargin > (count-1)  && ~isempty(varargin{count})
   ax.Position = varargin{count};
end
count = count+1;

%% title 
if nargin > (count-1)  && ~isempty(varargin{count})
   ax.Title.String = varargin{count};
end
count = count+1;

%% Font size 
if nargin > (count-1)  && ~isempty(varargin{count})
   ax.FontSize = varargin{count};
end
count = count+1;
