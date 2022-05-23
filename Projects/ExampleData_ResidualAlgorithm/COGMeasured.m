function [xzm,yzm] = COGMeasured(xr,yr,xl,yl,xS,yS,q,m)
% vectors from joint to joint right leg:
xv = diff([xr xS(:,1)],1,2);
yv = diff([yr yS(:,1)],1,2);
% relative position segment cog:
qrm = repmat(q(1,1:3),size(xr,1),1);
% cog positions right leg:
xzr = xr+qrm.*xv;
yzr = yr+qrm.*yv;
% vectors from joint to joint left leg:
xv = diff([xl xS(:,1)],1,2);
yv = diff([yl yS(:,1)],1,2);
% cog positions left leg:
xzl = xl+qrm.*xv;
yzl = yl+qrm.*yv;
% vectors from hip to shoulder:
xv = diff(xS,1,2);
yv = diff(yS,1,2);
% cog positions trunk:
xzS = xS(:,1)+q(1,4)*xv;
yzS = yS(:,1)+q(1,4)*yv;
% masses legs:
mrmrl = repmat(m(1,1:3),size(xr,1),1);
% x cog total:
xzm = (sum(mrmrl.*xzr,2)+sum(mrmrl.*xzl,2)+m(1,4)*xzS)/(2*m(1)+2*m(2)+2*m(3)+m(4));
% y cog total:
yzm = (sum(mrmrl.*yzr,2)+sum(mrmrl.*yzl,2)+m(1,4)*yzS)/(2*m(1)+2*m(2)+2*m(3)+m(4));
