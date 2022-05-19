
function resizeFigure (Xratio,Yratio)

fig = gcf;
pos = get(0, 'MonitorPositions');
pos = pos(1,:)*0.99;                        % screen size = [Xposition Yposition Xsize Ysize]
pos(3) = pos(3)*Xratio; pos(1) = (pos(3))-(pos(3)*Xratio); 
pos(4) = pos(4)*Yratio; pos(2) = ((pos(4))-pos(4)*Yratio)/2; 
%rescale the axis
fig.Position = pos;