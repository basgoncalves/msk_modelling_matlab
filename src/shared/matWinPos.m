% x = horizontal coordinates of the bottom-left corner (in pixels)
% y = vertical coordinates of the bottom-left corner (in pixels)
% h = height of the matlab window (in pixels)
% w = width of the matlab window (in pixels)

function [x,y,w,h] = matWinPos

desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
desktopMainFrame = desktop.getMainFrame;

dims = desktopMainFrame.getBounds;           % Get desktop dimensions

w = dims.width;
h = dims.height;
x = dims.x;
y = dims.y;

pos = get(0, 'MonitorPositions');
pointer = get(0, 'PointerLocation');

[~,screen_where_pointer_is] = min(abs(pos(:,1)-pointer(1)));

x = pos(screen_where_pointer_is,1);
y = pos(screen_where_pointer_is,2);
w = pos(screen_where_pointer_is,3);
h = pos(screen_where_pointer_is,4);