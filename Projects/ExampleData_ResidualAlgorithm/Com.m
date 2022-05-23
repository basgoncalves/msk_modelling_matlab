function [xzr,yzr,xzl,yzl,xzS,yzS] = Com(xr,yr,xl,yl,xS,yS,q)
xzr = zeros(size(xr,1),3);
yzr = xzr;
xzl = xzr;
yzl = xzr;
for i = 1:2
  xzr(:,i) = xr(:,i)+q(i)*(xr(:,i+1)-xr(:,i));
  yzr(:,i) = yr(:,i)+q(i)*(yr(:,i+1)-yr(:,i));
  xzl(:,i) = xl(:,i)+q(i)*(xl(:,i+1)-xl(:,i));
  yzl(:,i) = yl(:,i)+q(i)*(yl(:,i+1)-yl(:,i));
end
xzr(:,3) = xr(:,3)+q(3)*(xS(:,1)-xr(:,3));
yzr(:,3) = yr(:,3)+q(3)*(yS(:,1)-yr(:,3));
xzl(:,3) = xl(:,3)+q(3)*(xS(:,1)-xl(:,3));
yzl(:,3) = yl(:,3)+q(3)*(yS(:,1)-yl(:,3));
xzS = xS(:,1)+q(4)*(xS(:,2)-xS(:,1));
yzS = yS(:,1)+q(4)*(yS(:,2)-yS(:,1));
