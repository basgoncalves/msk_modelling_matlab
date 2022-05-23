function [xz,yz] = CenterOfGravity(phir,phil,phiS,m,L,q)
% with respect to hip
xrz(:,3) = -(1-q(3))*L(3)*cos(phir(:,3));
yrz(:,3) = -(1-q(3))*L(3)*sin(phir(:,3));
xr(:,3) = -L(3)*cos(phir(:,3));
yr(:,3) = -L(3)*sin(phir(:,3));
xrz(:,2) = xr(:,3)-(1-q(2))*L(2)*cos(phir(:,2));
yrz(:,2) = yr(:,3)-(1-q(2))*L(2)*sin(phir(:,2));
xr(:,2) = xr(:,3)-L(2)*cos(phir(:,2));
yr(:,2) = yr(:,3)-L(2)*sin(phir(:,2));
xrz(:,1) = xr(:,2)-(1-q(1))*L(1)*cos(phir(:,1));
yrz(:,1) = yr(:,2)-(1-q(1))*L(1)*sin(phir(:,1));

xlz(:,3) = -(1-q(3))*L(3)*cos(phil(:,3));
ylz(:,3) = -(1-q(3))*L(3)*sin(phil(:,3));
xl(:,3) = -L(3)*cos(phil(:,3));
yl(:,3) = -L(3)*sin(phil(:,3));
xlz(:,2) = xl(:,3)-(1-q(2))*L(2)*cos(phil(:,2));
ylz(:,2) = yl(:,3)-(1-q(2))*L(2)*sin(phil(:,2));
xl(:,2) = xl(:,3)-L(2)*cos(phil(:,2));
yl(:,2) = yl(:,3)-L(2)*sin(phil(:,2));
xlz(:,1) = xl(:,2)-(1-q(1))*L(1)*cos(phil(:,1));
ylz(:,1) = yl(:,2)-(1-q(1))*L(1)*sin(phil(:,1));

xSz = q(4)*L(4)*cos(phiS);
ySz = q(4)*L(4)*sin(phiS);

xz = (m(1)*xrz(:,1)+m(2)*xrz(:,2)+m(3)*xrz(:,3) ...
     +m(1)*xlz(:,1)+m(2)*xlz(:,2)+m(3)*xlz(:,3) ...
     +m(4)*xSz(:,1))/(2*m(1)+2*m(2)+2*m(3)+m(4));

yz = (m(1)*yrz(:,1)+m(2)*yrz(:,2)+m(3)*yrz(:,3) ...
     +m(1)*ylz(:,1)+m(2)*ylz(:,2)+m(3)*ylz(:,3) ...
     +m(4)*ySz(:,1))/(2*m(1)+2*m(2)+2*m(3)+m(4));
