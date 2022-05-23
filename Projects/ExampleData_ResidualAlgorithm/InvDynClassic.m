function [Mr,Ml,MHOGs,MHOGz,FHOGX,FHOGY] = InvDynClassic(Fgr,Fgl,xr,yr,xl,yl,xS,yS,r,m,q,I,g,N,fs)
% Fgr: ground reaction force right foot
% Fgl: ground reaction force left foot
% xr: joint positions x right leg
% yr: joint positions y right leg
% xl: joint positions x left leg
% yl: joint positions y left leg
% xS: joint positions x trunk
% yS: joint positions y trunk
% r: contact points ground reaction force
% m: segment masses
% L: segment lengths
% q: relative position centre of gravity in segments relative to most
% caudal point
% I: segments moments of inertia
% g: gravity acceleration
% N: number of samples in stride
% fs: sample frequency

% timestep between samples:
h = 1/fs;

% positions centre of gravity segments right leg:
xzr1 = xr(:,1)+q(1)*(xr(:,2)-xr(:,1));
yzr1 = yr(:,1)+q(1)*(yr(:,2)-yr(:,1));
xzr2 = xr(:,2)+q(2)*(xr(:,3)-xr(:,2));
yzr2 = yr(:,2)+q(2)*(yr(:,3)-yr(:,2));
xzr3 = xr(:,3)+q(3)*(xS(:,1)-xr(:,3));
yzr3 = yr(:,3)+q(3)*(yS(:,1)-yr(:,3));

% positions centre of gravity segments left leg:
xzl1 = xl(:,1)+q(1)*(xl(:,2)-xl(:,1));
yzl1 = yl(:,1)+q(1)*(yl(:,2)-yl(:,1));
xzl2 = xl(:,2)+q(2)*(xl(:,3)-xl(:,2));
yzl2 = yl(:,2)+q(2)*(yl(:,3)-yl(:,2));
xzl3 = xl(:,3)+q(3)*(xS(:,1)-xl(:,3));
yzl3 = yl(:,3)+q(3)*(yS(:,1)-yl(:,3));

% position centre of gravity trunk:
xzS = xS(:,1)+q(4)*(xS(:,2)-xS(:,1));
yzS = yS(:,1)+q(4)*(yS(:,2)-yS(:,1));

% velocities centres of gravity right leg:
xzr1p = gradient1(xzr1,h);
yzr1p = gradient1(yzr1,h);
xzr2p = gradient1(xzr2,h);
yzr2p = gradient1(yzr2,h);
xzr3p = gradient1(xzr3,h);
yzr3p = gradient1(yzr3,h);

% velocities centres of gravity left leg:
xzl1p = gradient1(xzl1,h);
yzl1p = gradient1(yzl1,h);
xzl2p = gradient1(xzl2,h);
yzl2p = gradient1(yzl2,h);
xzl3p = gradient1(xzl3,h);
yzl3p = gradient1(yzl3,h);

% velocity centre of gravity trunk:
xzSp = gradient1(xzS,h);
yzSp = gradient1(yzS,h);

% accelerations centres of gravity right leg:
xzr1dp = gradient2(xzr1,h);
yzr1dp = gradient2(yzr1,h);
xzr2dp = gradient2(xzr2,h);
yzr2dp = gradient2(yzr2,h);
xzr3dp = gradient2(xzr3,h);
yzr3dp = gradient2(yzr3,h);

% accelerations centres of gravity left leg:
xzl1dp = gradient2(xzl1,h);
yzl1dp = gradient2(yzl1,h);
xzl2dp = gradient2(xzl2,h);
yzl2dp = gradient2(yzl2,h);
xzl3dp = gradient2(xzl3,h);
yzl3dp = gradient2(yzl3,h);

% acceleration centre of gravity trunk:
xzSdp = gradient2(xzS,h);
yzSdp = gradient2(yzS,h);

% Segment angles right leg:
phir = Points2Angles([xr xS(:,1)],[yr yS(:,1)]);
% Segment angles left leg:
phil = Points2Angles([xl xS(:,1)],[yl yS(:,1)]);
% Trunk angles:
phiS = Points2Angles(xS,yS);

% Angular velocities right leg:
phirp(:,1) = gradient1(phir(:,1),h);
phirp(:,2) = gradient1(phir(:,2),h);
phirp(:,3) = gradient1(phir(:,3),h);

% Angular velocities left leg:
philp(:,1) = gradient1(phil(:,1),h);
philp(:,2) = gradient1(phil(:,2),h);
philp(:,3) = gradient1(phil(:,3),h);

% Angular velocities trunk:
phiSp(:,1) = gradient1(phiS(:,1),h);

% Angular accelerations right leg:
phirdp(:,1) = gradient2(phir(:,1),h);
phirdp(:,2) = gradient2(phir(:,2),h);
phirdp(:,3) = gradient2(phir(:,3),h);

% Angular accelerations left leg:
phildp(:,1) = gradient2(phil(:,1),h);
phildp(:,2) = gradient2(phil(:,2),h);
phildp(:,3) = gradient2(phil(:,3),h);

% Angular accelerations right leg:
phiSdp(:,1) = gradient2(phiS(:,1),h);

% Throw away last two points because of numerical differentiation:
N2 = N-2;
xS1 = xS(2:N2+1,1);
yS1 = yS(2:N2+1,1);
xS2 = xS(2:N2+1,2);
yS2 = yS(2:N2+1,2);

xr1 = xr(2:N2+1,1);
yr1 = yr(2:N2+1,1);
xr2 = xr(2:N2+1,2);
yr2 = yr(2:N2+1,2);
xr3 = xr(2:N2+1,3);
yr3 = yr(2:N2+1,3);

xl1 = xl(2:N2+1,1);
yl1 = yl(2:N2+1,1);
xl2 = xl(2:N2+1,2);
yl2 = yl(2:N2+1,2);
xl3 = xl(2:N2+1,3);
yl3 = yl(2:N2+1,3);

xzr1 = xzr1(2:N2+1,1);
yzr1 = yzr1(2:N2+1,1);
xzr2 = xzr2(2:N2+1,1);
yzr2 = yzr2(2:N2+1,1);
xzr3 = xzr3(2:N2+1,1);
yzr3 = yzr3(2:N2+1,1);

xzl1 = xzl1(2:N2+1,1);
yzl1 = yzl1(2:N2+1,1);
xzl2 = xzl2(2:N2+1,1);
yzl2 = yzl2(2:N2+1,1);
xzl3 = xzl3(2:N2+1,1);
yzl3 = yzl3(2:N2+1,1);

xzS = xzS(2:N2+1,1);
yzS = yzS(2:N2+1,1);

% collect marker positions legs:
xr = [xr1 xr2 xr3];
yr = [yr1 yr2 yr3];
xl = [xl1 xl2 xl3];
yl = [yl1 yl2 yl3];

% collect centres of gravity legs:
xzr = [xzr1 xzr2 xzr3];
yzr = [yzr1 yzr2 yzr3];
xzl = [xzl1 xzl2 xzl3];
yzl = [yzl1 yzl2 yzl3];

% collect accelerations centres of gravity legs:
xzrdp = [xzr1dp xzr2dp xzr3dp];
yzrdp = [yzr1dp yzr2dp yzr3dp];
xzldp = [xzl1dp xzl2dp xzl3dp];
yzldp = [yzl1dp yzl2dp yzl3dp];

% collect masses:
mr = [m(1,1) m(1,2) m(1,3)];
ml = [m(1,1) m(1,2) m(1,3)];

% collect moments inertia:
Ir = [I(1,1) I(1,2) I(1,3)];
Il = [I(1,1) I(1,2) I(1,3)];
IS = I(1,4);

% all net intersegmental forces right leg:
Frx = [Fgr(2:N2+1,1) zeros(N2,3)];
Fry = [Fgr(2:N2+1,2) zeros(N2,3)];

% net forces right leg:
for j = 2:4
% horizontal:  
  Frx(:,j) = Frx(:,j-1)-mr(1,j-1)*xzrdp(:,j-1);
% vertical:  
  Fry(:,j) = Fry(:,j-1)-mr(1,j-1)*yzrdp(:,j-1)-mr(1,j-1)*g;
end

% all net intersegmental forces left leg:
Flx = [Fgl(2:N2+1,1) zeros(N2,3)];
Fly = [Fgl(2:N2+1,2) zeros(N2,3)];

% net forces right leg:
for j = 2:4
% horizontal:  
  Flx(:,j) = Flx(:,j-1)-ml(1,j-1)*xzldp(:,j-1);
% vertical:  
  Fly(:,j) = Fly(:,j-1)-ml(1,j-1)*yzldp(:,j-1)-ml(1,j-1)*g;
end

% all net torques right leg:
Mr = zeros(N2,3);

% Net right ankle torque:
Mp1 = Frx(:,1).*yzr(:,1)+Fry(:,1).*(r(1:N2,1)-xzr(:,1));
Mp2 = Frx(:,2).*(yr(:,2)-yzr(:,1))+Fry(:,2).*(xzr(:,1)-xr(:,2));
Mr(:,1) = Mp1+Mp2-Ir(1,1)*phirdp(:,1);

% Net torque right knee:
Mp1 = Frx(:,2).*(yzr(:,2)-yr(:,2))+Fry(:,2).*(xr(:,2)-xzr(:,2));
Mp2 = Frx(:,3).*(yr(:,3)-yzr(:,2))+Fry(:,3).*(xzr(:,2)-xr(:,3));
Mr(:,2) = Mp1+Mp2+Mr(:,1)-Ir(1,2)*phirdp(:,2);

% Net torque right hip:
Mp1 = Frx(:,3).*(yzr(:,3)-yr(:,3))+Fry(:,3).*(xr(:,3)-xzr(:,3));
Mp2 = Frx(:,4).*(yS1-yzr(:,3))+Fry(:,4).*(xzr(:,3)-xS1);
Mr(:,3) = Mp1+Mp2+Mr(:,2)-Ir(1,3)*phirdp(:,3);

% all net torques left leg:
Ml = zeros(N2,3);

% Net left ankle torque:
Mp1 = Flx(:,1).*yzl(:,1)+Fly(:,1).*(r(1:N2,2)-xzl(:,1));
Mp2 = Flx(:,2).*(yl(:,2)-yzl(:,1))+Fly(:,2).*(xzl(:,1)-xl(:,2));
Ml(:,1) = Mp1+Mp2-Il(1,1)*phildp(:,1);

% Net torque left knee:
Mp1 = Flx(:,2).*(yzl(:,2)-yl(:,2))+Fly(:,2).*(xl(:,2)-xzl(:,2));
Mp2 = Flx(:,3).*(yl(:,3)-yzl(:,2))+Fly(:,3).*(xzl(:,2)-xl(:,3));
Ml(:,2) = Mp1+Mp2+Ml(:,1)-Il(1,2)*phildp(:,2);

% Net torque left hip:
Mp1 = Flx(:,3).*(yzl(:,3)-yl(:,3))+Fly(:,3).*(xl(:,3)-xzl(:,3));
Mp2 = Flx(:,4).*(yS1-yzl(:,3))+Fly(:,4).*(xzl(:,3)-xS1);
Ml(:,3) = Mp1+Mp2+Ml(:,2)-Il(1,3)*phildp(:,3);

% torque on trunk due to net right hip force:
Mpr = Frx(:,4).*(yzS-yS1)-Fry(:,4).*(xzS-xS1);
% torque on trunk due to net left hip force:
Mpl = Flx(:,4).*(yzS-yS1)-Fly(:,4).*(xzS-xS1);

% residual force:
FHOGX = m(4)*xzSdp-Frx(:,4)-Flx(:,4);
FHOGY = m(4)*yzSdp+m(4)*g-Fry(:,4)-Fly(:,4);

% residual torque at the trunk with FHOG at shoulder:
MHOGs = -Mpr-Mpl-Mr(:,3)-Ml(:,3)+FHOGX.*(yS2-yzS)-FHOGY.*(xS2-xzS)+IS*phiSdp; 
% residual torque at the trunk with FHOG z:
MHOGz = -Mpr-Mpl-Mr(:,3)-Ml(:,3)+IS*phiSdp; 