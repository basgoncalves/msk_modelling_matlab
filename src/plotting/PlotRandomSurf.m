

figure
surf(surfData*500)
colormap winter
title(sprintf('Muscle activity'));
shading interp
lighting phong
light
material shiny
grid off

saveas(gcf, sprintf('ExamplePlot_FAI.tif')) 
set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca,'ztick',[])
box off
ax = gca;
c = ax.Color;
ax.Color = 'None';