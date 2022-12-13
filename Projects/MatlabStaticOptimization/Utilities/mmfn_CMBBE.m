
function mmfn_CMBBE

set(gcf,'Color',[1 1 1]);
grid off
fig=gcf;
N =  length(fig.Children);
for ii = 1:N
    set(fig.Children(ii),'box', 'off')
    if contains(class(fig.Children(ii)),'Axes')
        fig.Children(ii).FontName = 'Times New Roman';
        fig.Children(ii).Title.FontWeight = 'Normal';
        fig.Children(ii).FontSize = 14;
        for ax = 1:length(fig.Children(ii).Children)
            if contains(class(fig.Children(ii).Children(ax)),'matlab.graphics.chart.primitive.Line')
                fig.Children(ii).Children(ax).LineWidth = 2;
            end
        end
    end
     if contains(class(fig.Children(ii)),'Legend')
        fig.Children(ii).FontSize = 9;
     end
end
