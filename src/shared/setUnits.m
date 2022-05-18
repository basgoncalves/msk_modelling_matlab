% set units for figure
% UnitType = 'pixels','normalized'
function setUnits (Myfigure,UnitType)

set(Myfigure,'Units',UnitType);


h = gca;
set(gca,'Units',UnitType,'FontUnits',UnitType);
h.Title.FontUnits = UnitType;
h.XLabel.FontUnits = UnitType;
h.YLabel.FontUnits = UnitType;

Text = findobj(gcf, 'Type', 'Text');
for i= 1:length(Text)
Text(i).FontUnits = UnitType;
end

