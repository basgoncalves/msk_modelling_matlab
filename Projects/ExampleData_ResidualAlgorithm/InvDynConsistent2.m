function [Momr,Moml] = InvDynConsistent2(xr4,yr4,xl4,yl4,phir,phil,phiS, ...
                                         Fgr,Fgl,r,fs,N,m,L,q,I,alpha,g)

% model positions, all collumn vectors, no extra points:
phir1 = phir(:,1);
phir2 = phir(:,2);
phir3 = phir(:,3);
phil1 = phil(:,1);
phil2 = phil(:,2);
phil3 = phil(:,3);

xr4p = gradient(xr4,1/fs);
yr4p = gradient(yr4,1/fs);
xl4p = gradient(xl4,1/fs);
yl4p = gradient(yl4,1/fs);
phirp(:,1) = gradient(phir(:,1),1/fs);
phirp(:,2) = gradient(phir(:,2),1/fs);
phirp(:,3) = gradient(phir(:,3),1/fs);
philp(:,1) = gradient(phil(:,1),1/fs);
philp(:,2) = gradient(phil(:,2),1/fs);
philp(:,3) = gradient(phil(:,3),1/fs);
phiSp(:,1) = gradient(phiS(:,1),1/fs);

xr4dp = gradient(xr4p,1/fs);
yr4dp = gradient(yr4p,1/fs);
xl4dp = gradient(xl4p,1/fs);
yl4dp = gradient(yl4p,1/fs);
phirdp(:,1) = gradient(phirp(:,1),1/fs);
phirdp(:,2) = gradient(phirp(:,2),1/fs);
phirdp(:,3) = gradient(phirp(:,3),1/fs);
phildp(:,1) = gradient(philp(:,1),1/fs);
phildp(:,2) = gradient(philp(:,2),1/fs);
phildp(:,3) = gradient(philp(:,3),1/fs);
phiSdp(:,1) = gradient(phiSp(:,1),1/fs);

Lr1 = L(1,1);
Lr2 = L(1,2);
Lr3 = L(1,3);
Ll1 = L(1,1);
Ll2 = L(1,2);
Ll3 = L(1,3);
LS = L(1,4);
q1 = q(1,1);
q2 = q(1,2);
q3 = q(1,3);
qS = q(1,4);

phir1p = phirp(:,1);
phir2p = phirp(:,2);
phir3p = phirp(:,3);
phil1p = philp(:,1);
phil2p = philp(:,2);
phil3p = philp(:,3);

phir1dp = phirdp(:,1);
phir2dp = phirdp(:,2);
phir3dp = phirdp(:,3);
phil1dp = phildp(:,1);
phil2dp = phildp(:,2);
phil3dp = phildp(:,3);

xzr3 = xr4 + Lr3*cos(phir3)*(q3 - 1);
xr3 = xr4 - Lr3*cos(phir3);
xzr2 = xr3 + Lr2*cos(phir2)*(q2 - 1);
xr2 = xr3 - Lr2*cos(phir2);
xzr1 = xr2 + Lr1*cos(phir1)*(q1 - 1);
xr1 = xr2 - Lr1*cos(phir1);

yzr3 = yr4 + Lr3*sin(phir3)*(q3 - 1);
yr3 = yr4 - Lr3*sin(phir3);
yzr2 = yr3 + Lr2*sin(phir2)*(q2 - 1);
yr2 = yr3 - Lr2*sin(phir2);
yzr1 = yr2 + Lr1*sin(phir1)*(q1 - 1);
yr1 = yr2 - Lr1*sin(phir1);

xzl3 = xl4 + Ll3*cos(phil3)*(q3 - 1);
xl3 = xl4 - Ll3*cos(phil3);
xzl2 = xl3 + Ll2*cos(phil2)*(q2 - 1);
xl2 = xl3 - Ll2*cos(phil2);
xzl1 = xl2 + Ll1*cos(phil1)*(q1 - 1);
xl1 = xl2 - Ll1*cos(phil1);

yzl3 = yl4 + Ll3*sin(phil3)*(q3 - 1);
yl3 = yl4 - Ll3*sin(phil3);
yzl2 = yl3 + Ll2*sin(phil2)*(q2 - 1);
yl2 = yl3 - Ll2*sin(phil2);
yzl1 = yl2 + Ll1*sin(phil1)*(q1 - 1);
yl1 = yl2 - Ll1*sin(phil1);

xzS = xl4/2 + xr4/2 + LS*qS*cos(phiS-alpha);
yzS = yl4/2 + yr4/2 + LS*qS*sin(phiS-alpha);

xzr3dp = - Lr3*cos(phir3)*(q3 - 1).*phir3p.^2 + xr4dp - Lr3*phir3dp.*sin(phir3)*(q3 - 1);
yzr3dp = - Lr3*sin(phir3)*(q3 - 1).*phir3p.^2 + yr4dp + Lr3*phir3dp.*cos(phir3)*(q3 - 1);

xr3dp = Lr3*cos(phir3).*phir3p.^2 + xr4dp + Lr3*phir3dp.*sin(phir3);
yr3dp = Lr3*sin(phir3).*phir3p.^2 + yr4dp - Lr3*phir3dp.*cos(phir3);

xzr2dp = - Lr2*cos(phir2).*(q2 - 1).*phir2p.^2 + xr3dp - Lr2*phir2dp.*sin(phir2)*(q2 - 1);
yzr2dp = - Lr2*sin(phir2).*(q2 - 1).*phir2p.^2 + yr3dp + Lr2*phir2dp.*cos(phir2)*(q2 - 1);

xr2dp = Lr2*cos(phir2).*phir2p.^2 + xr3dp + Lr2*phir2dp.*sin(phir2);
yr2dp = Lr2*sin(phir2).*phir2p.^2 + yr3dp - Lr2*phir2dp.*cos(phir2);

xzr1dp = - Lr1*cos(phir1)*(q1 - 1).*phir1p.^2 + xr2dp - Lr1*phir1dp.*sin(phir1)*(q1 - 1);
yzr1dp = - Lr1*sin(phir1)*(q1 - 1).*phir1p.^2 + yr2dp + Lr1*phir1dp.*cos(phir1)*(q1 - 1);

xzl3dp = - Ll3*cos(phil3)*(q3 - 1).*phil3p.^2 + xl4dp - Ll3*phil3dp.*sin(phil3)*(q3 - 1);
yzl3dp = - Ll3*sin(phil3)*(q3 - 1).*phil3p.^2 + yl4dp + Ll3*phil3dp.*cos(phil3)*(q3 - 1);

xl3dp = Ll3*cos(phil3).*phil3p.^2 + xl4dp + Ll3*phil3dp.*sin(phil3);
yl3dp = Ll3*sin(phil3).*phil3p.^2 + yl4dp - Ll3*phil3dp.*cos(phil3);

xzl2dp = - Ll2*cos(phil2)*(q2 - 1).*phil2p.^2 + xl3dp - Ll2*phil2dp.*sin(phil2)*(q2 - 1);
yzl2dp = - Ll2*sin(phil2)*(q2 - 1).*phil2p.^2 + yl3dp + Ll2*phil2dp.*cos(phil2)*(q2 - 1);

xl2dp = Ll2*cos(phil2).*phil2p.^2 + xl3dp + Ll2*phil2dp.*sin(phil2);
yl2dp = Ll2*sin(phil2).*phil2p.^2 + yl3dp - Ll2*phil2dp.*cos(phil2);

xzl1dp = - Ll1*cos(phil1)*(q1 - 1).*phil1p.^2 + xl2dp - Ll1*phil1dp.*sin(phil1)*(q1 - 1);
yzl1dp = - Ll1*sin(phil1)*(q1 - 1).*phil1p.^2 + yl2dp + Ll1*phil1dp.*cos(phil1)*(q1 - 1);

xzSdp = - LS*qS*cos(alpha - phiS).*phiSp.^2 + xl4dp/2 + xr4dp/2 + LS*phiSdp*qS.*sin(alpha - phiS);
yzSdp = LS*qS*sin(alpha - phiS).*phiSp.^2 + yl4dp/2 + yr4dp/2 + LS*phiSdp*qS.*cos(alpha - phiS);

% collect marker positions:
xr = [xr1 xr2 xr3 xr4];
yr = [yr1 yr2 yr3 yr4];
xl = [xl1 xl2 xl3 xl4];
yl = [yl1 yl2 yl3 yl4];

% collect centres of gravity:
xzr = [xzr1 xzr2 xzr3];
yzr = [yzr1 yzr2 yzr3];
xzl = [xzl1 xzl2 xzl3];
yzl = [yzl1 yzl2 yzl3];

% collect accelerations centres of gravity:
xzrdp = [xzr1dp xzr2dp xzr3dp];
yzrdp = [yzr1dp yzr2dp yzr3dp];
xzldp = [xzl1dp xzl2dp xzl3dp];
yzldp = [yzl1dp yzl2dp yzl3dp];

% collect angular accelerations:
phirdp = [phir1dp phir2dp phir3dp];
phildp = [phil1dp phil2dp phil3dp];

% masses:
mr = [m(1,1) m(1,2) m(1,3)];
ml = [m(1,1) m(1,2) m(1,3)];
mS = m(1,4);
% moments inertia:
Ir = [I(1,1) I(1,2) I(1,3)];
Il = [I(1,1) I(1,2) I(1,3)];
IS = I(1,4);

% intersegmental forces:
Frx = [Fgr(:,1) zeros(N,3)];
Fry = [Fgr(:,2) zeros(N,3)];
% net forces right leg:
for j = 2:4
% horizontal:  
  Frx(:,j) = Frx(:,j-1)-mr(1,j-1)*xzrdp(:,j-1);
% vertical:  
  Fry(:,j) = Fry(:,j-1)-mr(1,j-1)*yzrdp(:,j-1)-mr(1,j-1)*g;
end
Flx = [Fgl(:,1) zeros(N,3)];
Fly = [Fgl(:,2) zeros(N,3)];
% net forces right leg:
for j = 2:4
% horizontal:  
  Flx(:,j) = Flx(:,j-1)-ml(1,j-1)*xzldp(:,j-1);
% vertical:  
  Fly(:,j) = Fly(:,j-1)-ml(1,j-1)*yzldp(:,j-1)-ml(1,j-1)*g;
end
Momr = zeros(N,3);
% Net right ankle moment:
Mp1 = Fgr(:,1).*yzr(:,1)+Fgr(:,2).*(r(:,1)-xzr(:,1));
Mp2 = Frx(:,2).*(yr(:,2)-yzr(:,1))+Fry(:,2).*(xzr(:,1)-xr(:,2));
Momr(:,1) = Mp1+Mp2-Ir(1,1)*phirdp(:,1);
% Net moment right knee and hip:
for j = 2:3
  Mp1 = Frx(:,j).*(yzr(:,j)-yr(:,j))+Fry(:,j).*(xr(:,j)-xzr(:,j));
  Mp2 = Frx(:,j+1).*(yr(:,j+1)-yzr(:,j))+Fry(:,j+1).*(xzr(:,j)-xr(:,j+1));
  Momr(:,j) = Mp1+Mp2+Momr(:,j-1)-Ir(1,j)*phirdp(:,j);
end  
Moml = zeros(N,3);
% Net left ankle moment:
Mp1 = Fgl(:,1).*yzl(:,1)+Fgl(:,2).*(r(:,2)-xzl(:,1));
Mp2 = Flx(:,2).*(yl(:,2)-yzl(:,1))+Fly(:,2).*(xzl(:,1)-xl(:,2));
Moml(:,1) = Mp1+Mp2-Il(1,1)*phildp(:,1);
% Net moment left knee and hip:
for j = 2:3
  Mp1 = Flx(:,j).*(yzl(:,j)-yl(:,j))+Fly(:,j).*(xl(:,j)-xzl(:,j));
  Mp2 = Flx(:,j+1).*(yl(:,j+1)-yzl(:,j))+Fly(:,j+1).*(xzl(:,j)-xl(:,j+1));
  Moml(:,j) = Mp1+Mp2+Moml(:,j-1)-Il(1,j)*phildp(:,j);
end  
