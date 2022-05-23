function mmfn_JM(xlb,ylb)

set(gcf,'Color',[1 1 1]);
grid off
fig=gcf;
N =  length(fig.Children);
for ii = 1:N
    set(fig.Children(ii),'box', 'off')
    if contains(class(fig.Children(ii)),'Axes')
        fig.Children(ii).FontName = 'Times New Roman';
        fig.Children(ii).Title.FontWeight = 'Normal';
        
        for ax = 1:length(fig.Children(ii).Children)
            if contains(class(fig.Children(ii).Children(ax)),'matlab.graphics.chart.primitive.Line')
%                 fig.Children(ii).Children(ax).LineWidth = 2;
            elseif contains(class(fig.Children(ii).Children(ax)),'matlab.graphics.chart.primitive.Bar')
%                 fig.Children(ii).Children(ax).EdgeColor = 'k';
            end
        end
    end
end

if nargin>0
    xlabel(xlb)
end

if nargin>1
    ylabel(ylb)
end

