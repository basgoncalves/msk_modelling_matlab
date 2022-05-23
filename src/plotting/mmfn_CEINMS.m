function mmfn_CEINMS

set(gcf,'Color',[1 1 1]);
set(gca,'box', 'off')
PP = gca;
PP.Title.FontSize = 20;
% Plot.XAxisLocation = 'origin';
% Plot.YAxisLocation = 'origin';
N =  length(PP.Children);
for ii = 1:N
    if contains(class(PP.Children(ii)),'matlab.graphics.chart.primitive.Bar')
        PP.Children(ii).EdgeColor = 'k';
    elseif contains(class(PP.Children(ii)),'matlab.graphics.chart.primitive.Line')
        PP.Children(ii).LineWidth = 2;
    end
end

% PP.YLabel.Rotation = 0;
% PP.YLabel.HorizontalAlignment = 'right';

grid off
% set(findobj('-property','LineWidth'),'LineWidth',1);
fig=gcf;
fig.CurrentAxes.FontSize = 20;

pos = get(0, 'Screensize')/1.3;           % half screen size = [Xposition Yposition Xsize Ysize]
pos(1) = pos(3)/6;                      
pos(2) = pos(4)/6;
set(gcf, 'Position', pos);

N =  length(fig.Children);
for ii = 1:N
    if contains(class(fig.Children(ii)),'Axes')
        fig.Children(ii).FontName = 'Times New Roman';
        fig.Children(ii).Title.FontWeight = 'Normal';
    elseif contains(class(fig.Children(ii)),'Legend')
        fig.Children(ii).Box = 'off';
    end    
end

if ~isempty(PP.Legend)
    lg = legend;
    legend ('boxoff');
end
% set(lg,'color','white','Location', 'best');
% legend_position =  get(lg, 'position');
% legend_position(1)=0.8;
% set(lg, 'position',legend_position);


