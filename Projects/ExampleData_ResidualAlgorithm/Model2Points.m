function [xr,yr,xl,yl,xS,yS] = Model2Points(xS1,yS1,phir,phil,phiS,L)
xr(:,3) = xS1(:,1)-L(3)*cos(phir(:,3));
yr(:,3) = yS1(:,1)-L(3)*sin(phir(:,3));
xr(:,2) = xr(:,3)-L(2)*cos(phir(:,2));
yr(:,2) = yr(:,3)-L(2)*sin(phir(:,2));
xr(:,1) = xr(:,2)-L(1)*cos(phir(:,1));
yr(:,1) = yr(:,2)-L(1)*sin(phir(:,1));

xl(:,3) = xS1(:,1)-L(3)*cos(phil(:,3));
yl(:,3) = yS1(:,1)-L(3)*sin(phil(:,3));
xl(:,2) = xl(:,3)-L(2)*cos(phil(:,2));
yl(:,2) = yl(:,3)-L(2)*sin(phil(:,2));
xl(:,1) = xl(:,2)-L(1)*cos(phil(:,1));
yl(:,1) = yl(:,2)-L(1)*sin(phil(:,1));

xS(:,1) = xS1;
yS(:,1) = yS1;
xS(:,2) = xS1+L(4)*cos(phiS);
yS(:,2) = yS1+L(4)*sin(phiS);
