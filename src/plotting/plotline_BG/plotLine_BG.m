%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot data in a struct;
%   - one field per row
%   - one column of data per column
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   mmfn
%   tight_subplot_BG
%   plotVert
%   
%INPUT (only needs S, leave others e
%   S = struct with data
%   LG = cell with legend
%   Xlab = char with x-axis label
%   TT = title of each column (should be the same for the two rows)
%   LW = line width (default = 20)
%-------------------------------------------------------------------------
%OUTPUT
%    = 
%--------------------------------------------------------------------------

function plotLine_BG(S,Ylab,Xlab,TT,LW,Vert)

f = fields(S);
Nrow = length(f);
Ncol = size(S.(f{1}),2);

if nargin < 2 || isempty(Ylab)
    Ylab = f;
end

if nargin < 3 || isempty(Xlab)
    Xlab = '';
end

if nargin < 4 || isempty(TT)
    TT = split(sprintf('column_%.f ',[1:size(S.(f{1}),2)]),' ');
    TT(end) = [];
end

if nargin < 5 || isempty(LW)
    LW = 2;
end

c = 1; % count loops
cf = gcf;
if length(cf.Children)< Nrow*Ncol
    for  rr = 1: Nrow   % loop through fields
        for cc = 1: Ncol % loop through columns of each field
            subplot(Nrow,Ncol,c)
            c = c+1;
        end
    end
    
    cf.Children = flip(cf.Children);
else
    changeFig = 1;
end


c = 1; % count loops
for  rr = 1: Nrow   % loop through fields
    for cc = 1: Ncol % loop through columns of each field
        yData = S.(f{rr})(:,cc);
        ax = cf.Children(c);
        axes(ax);
        plot(ax,yData,'LineWidth', LW)
        hold on
        
        % plot vertical lines with time events
        if nargin > 5
            plotVert(Vert,{},{}) 
        end
        if cc == 1
          yl = ax.YLabel;
          yl.String = Ylab{rr};
          yl.HorizontalAlignment = 'right';
          yl.Rotation = 0;
%         else 
%             yticks('')
        end
        
        if cc == 1 && rr == 1
            title (TT(cc),'interpreter','none')
        elseif rr == 1
            title (TT(cc),'interpreter','none')
        end
        
        if rr ~= Nrow
            xticklabels('');   
        elseif rr == Nrow
            xlabel(Xlab)
        end
        
        mmfn
        c = c+1;
    end
end

[ha, pos] = tight_subplot_BG(Nrow, Ncol,0.05,0.1,0.2);
