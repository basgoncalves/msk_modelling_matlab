function mmfn_Joni(xlb,ylb)

set(gcf,'Color',[1 1 1]);
grid off
fig=gcf;
N =  length(fig.Children);
for ii = 1:N
    set(fig.Children(ii),'box', 'off')
    if contains(class(fig.Children(ii)),'Axes')
        fig.Children(ii).FontName = 'Times New Roman';
        fig.Children(ii).Title.FontWeight = 'Normal';
    end
end

if nargin>0
    xlabel(xlb)
end

if nargin>1
    ylabel(ylb)
end

