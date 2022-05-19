function mmfn(FS,xlb,ylb)

set(gcf,'Color',[1 1 1]);
set(gca,'box', 'off')
FigAx = get(gcf,'Children')';

if nargin <1; FS=12; end
for ax=FigAx
    ax.FontSize=FS;           % change font size
    if contains(class(ax),'Axes')
       ax.FontName = 'Times New Roman';
       ax.Title.FontWeight = 'Normal';
    end
    
    if ~isempty(ax.Legend); legend('boxoff'); end
    
    N =  length(ax.Children);
    for ii = 1:N
        if contains(class(ax.Children(ii)),'matlab.graphics.chart.primitive.Bar')
            ax.Children(ii).EdgeColor = 'k';
        elseif contains(class(ax.Children(ii)),'matlab.graphics.chart.primitive.Line')
            ax.Children(ii).LineWidth = 2;
        end
    end
    grid off
end

if nargin>1; xlabel(xlb); end

if nargin>2; ylabel(ylb); end

