function [c,ceq] = StrideConTry(Xin,Fgr,Fgl,r,refxr,refyr,refxl,refyl,refxS,refyS,xzdp,yzdp,xzpcum,yzpcum,xzcum,yzcum,m,L,q,I,g,N,fs,phidpmax,phidpmin)
c = [];
% model pos:
phir = reshape(Xin(1:N*3,1),N,3);
phil = reshape(Xin(N*3+1:N*6,1),N,3);
phiS = reshape(Xin(N*6+1:N*7,1),N,1);
xz0 = Xin(N*7+1,1);
yz0 = Xin(N*7+2,1);
xzp0 = Xin(N*7+3,1);
yzp0 = Xin(N*7+4,1);
cumxzp0 = 0:xzp0/fs:(N-1)*xzp0/fs;
cumyzp0 = 0:yzp0/fs:(N-1)*yzp0/fs;
xz = xz0+cumxzp0'+xzcum;
yz = yz0+cumyzp0'+yzcum;
[xzg,yzg] = CenterOfGravity(phir,phil,phiS,m,L,q);
xS(:,1) = xz-xzg;
yS(:,1) = yz-yzg;
[xr,yr,xl,yl,xS,yS] = Model2Points(xS(:,1),yS(:,1),phir,phil,phiS,L);

h = 1/fs;
phirp = zeros(N-2,3);
philp = zeros(N-2,3);
phirdp = zeros(N-2,3);
phildp = zeros(N-2,3);
for i = 1:3
  phirp(:,i) = gradient1(phir(2:end,i),h);
  philp(:,i) = gradient1(phil(2:end,i),h);
  phirdp(:,i) = gradient2(phir(:,i),h);
  phildp(:,i) = gradient2(phil(:,i),h);
end
phiSdp = gradient2(phiS(:,1),h);

xSp(:,1) = gradient1(xS(:,1),h);
ySp(:,1) = gradient1(yS(:,1),h);
xSdp(:,1) = gradient1(xSp(:,1),h);
ySdp(:,1) = gradient1(ySp(:,1),h);

xzr = zeros(N,3);
yzr = zeros(N,3);
xzl = zeros(N,3);
yzl = zeros(N,3);
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

phir = phir(2:end-1,:);
phil = phil(2:end-1,:);
phiS = phiS(2:end-1,:);

xzrdp(:,3) = xSdp(:,1)+(1-q(3))*L(3)*phirdp(:,3).*sin(phir(:,3))+(1-q(3))*L(3)*phirp(:,3).^2.*cos(phir(:,3));
yzrdp(:,3) = ySdp(:,1)-(1-q(3))*L(3)*phirdp(:,3).*cos(phir(:,3))+(1-q(3))*L(3)*phirp(:,3).^2.*sin(phir(:,3));

xrdp(:,3) = xSdp(:,1)+L(3)*phirdp(:,3).*sin(phir(:,3))+L(3)*phirp(:,3).^2.*cos(phir(:,3));
yrdp(:,3) = ySdp(:,1)-L(3)*phirdp(:,3).*cos(phir(:,3))+L(3)*phirp(:,3).^2.*sin(phir(:,3));

xzrdp(:,2) = xrdp(:,3)+(1-q(2))*L(2)*phirdp(:,2).*sin(phir(:,2))+(1-q(2))*L(2)*phirp(:,2).^2.*cos(phir(:,2));
yzrdp(:,2) = yrdp(:,3)-(1-q(2))*L(2)*phirdp(:,2).*cos(phir(:,2))+(1-q(2))*L(2)*phirp(:,2).^2.*sin(phir(:,2));

xrdp(:,2) = xrdp(:,3)+L(2)*phirdp(:,2).*sin(phir(:,2))+L(2)*phirp(:,2).^2.*cos(phir(:,2));
yrdp(:,2) = yrdp(:,3)-L(2)*phirdp(:,2).*cos(phir(:,2))+L(2)*phirp(:,2).^2.*sin(phir(:,2));

xzrdp(:,1) = xrdp(:,2)+(1-q(1))*L(1)*phirdp(:,1).*sin(phir(:,1))+(1-q(1))*L(1)*phirp(:,1).^2.*cos(phir(:,1));
yzrdp(:,1) = yrdp(:,2)-(1-q(1))*L(1)*phirdp(:,1).*cos(phir(:,1))+(1-q(1))*L(1)*phirp(:,1).^2.*sin(phir(:,1));

xzldp(:,3) = xSdp(:,1)+(1-q(3))*L(3)*phildp(:,3).*sin(phil(:,3))+(1-q(3))*L(3)*philp(:,3).^2.*cos(phil(:,3));
yzldp(:,3) = ySdp(:,1)-(1-q(3))*L(3)*phildp(:,3).*cos(phil(:,3))+(1-q(3))*L(3)*philp(:,3).^2.*sin(phil(:,3));

xldp(:,3) = xSdp(:,1)+L(3)*phildp(:,3).*sin(phil(:,3))+L(3)*philp(:,3).^2.*cos(phil(:,3));
yldp(:,3) = ySdp(:,1)-L(3)*phildp(:,3).*cos(phil(:,3))+L(3)*philp(:,3).^2.*sin(phil(:,3));

xzldp(:,2) = xldp(:,3)+(1-q(2))*L(2)*phildp(:,2).*sin(phil(:,2))+(1-q(2))*L(2)*philp(:,2).^2.*cos(phil(:,2));
yzldp(:,2) = yldp(:,3)-(1-q(2))*L(2)*phildp(:,2).*cos(phil(:,2))+(1-q(2))*L(2)*philp(:,2).^2.*sin(phil(:,2));

xldp(:,2) = xldp(:,3)+L(2)*phildp(:,2).*sin(phil(:,2))+L(2)*philp(:,2).^2.*cos(phil(:,2));
yldp(:,2) = yldp(:,3)-L(2)*phildp(:,2).*cos(phil(:,2))+L(2)*philp(:,2).^2.*sin(phil(:,2));

xzldp(:,1) = xldp(:,2)+(1-q(1))*L(1)*phildp(:,1).*sin(phil(:,1))+(1-q(1))*L(1)*philp(:,1).^2.*cos(phil(:,1));
yzldp(:,1) = yldp(:,2)-(1-q(1))*L(1)*phildp(:,1).*cos(phil(:,1))+(1-q(1))*L(1)*philp(:,1).^2.*sin(phil(:,1));
  
N2 = N-1;

xr = xr(2:N2,:);
yr = yr(2:N2,:);
xl = xl(2:N2,:);
yl = yl(2:N2,:);
xS = xS(2:N2,:);
yS = yS(2:N2,:);

xzr = xzr(2:N2,:);
yzr = yzr(2:N2,:);
xzl = xzl(2:N2,:);
yzl = yzl(2:N2,:);
xzS = xzS(2:N2,:);
yzS = yzS(2:N2,:);

Fgr = Fgr(2:N2,:);
Fgl = Fgl(2:N2,:);
r = r(2:N2,:);

N2 = N2-1;
% intersegmental forces:
Frx = [Fgr(:,1) zeros(N2,3)];
Fry = [Fgr(:,2) zeros(N2,3)];
% net forces right leg:
for j = 2:4
% horizontal:  
  Frx(:,j) = Frx(:,j-1)-m(j-1)*xzrdp(:,j-1);
% vertical:  
  Fry(:,j) = Fry(:,j-1)-m(j-1)*yzrdp(:,j-1)-m(j-1)*g;
end
Flx = [Fgl(:,1) zeros(N2,3)];
Fly = [Fgl(:,2) zeros(N2,3)];
% net forces right leg:
for j = 2:4
% horizontal:  
  Flx(:,j) = Flx(:,j-1)-m(j-1)*xzldp(:,j-1);
% vertical:  
  Fly(:,j) = Fly(:,j-1)-m(j-1)*yzldp(:,j-1)-m(j-1)*g;
end
Mr = zeros(N2,3);
% Net right ankle moment:
Mp1 = Frx(:,1).*yzr(:,1)+Fry(:,1).*(r(1:N2,1)-xzr(:,1));
Mp2 = Frx(:,2).*(yr(:,2)-yzr(:,1))+Fry(:,2).*(xzr(:,1)-xr(:,2));
Mr(:,1) = Mp1+Mp2-I(1)*phirdp(:,1);
% Net moment right knee:
Mp1 = Frx(:,2).*(yzr(:,2)-yr(:,2))+Fry(:,2).*(xr(:,2)-xzr(:,2));
Mp2 = Frx(:,3).*(yr(:,3)-yzr(:,2))+Fry(:,3).*(xzr(:,2)-xr(:,3));
Mr(:,2) = Mp1+Mp2+Mr(:,1)-I(2)*phirdp(:,2);
% Net moment right hip:
Mp1 = Frx(:,3).*(yzr(:,3)-yr(:,3))+Fry(:,3).*(xr(:,3)-xzr(:,3));
Mp2 = Frx(:,4).*(yS(:,1)-yzr(:,3))+Fry(:,4).*(xzr(:,3)-xS(:,1));
Mr(:,3) = Mp1+Mp2+Mr(:,2)-I(3)*phirdp(:,3);
Ml = zeros(N2,3);
% Net left ankle moment:
Mp1 = Flx(:,1).*yzl(:,1)+Fly(:,1).*(r(1:N2,2)-xzl(:,1));
Mp2 = Flx(:,2).*(yl(:,2)-yzl(:,1))+Fly(:,2).*(xzl(:,1)-xl(:,2));
Ml(:,1) = Mp1+Mp2-I(1)*phildp(:,1);
% Net moment left knee:
Mp1 = Flx(:,2).*(yzl(:,2)-yl(:,2))+Fly(:,2).*(xl(:,2)-xzl(:,2));
Mp2 = Flx(:,3).*(yl(:,3)-yzl(:,2))+Fly(:,3).*(xzl(:,2)-xl(:,3));
Ml(:,2) = Mp1+Mp2+Ml(:,1)-I(2)*phildp(:,2);
% Net moment left hip:
Mp1 = Flx(:,3).*(yzl(:,3)-yl(:,3))+Fly(:,3).*(xl(:,3)-xzl(:,3));
Mp2 = Flx(:,4).*(yS(:,1)-yzl(:,3))+Fly(:,4).*(xzl(:,3)-xS(:,1));
Ml(:,3) = Mp1+Mp2+Ml(:,2)-I(3)*phildp(:,3);
% Moments of intersegmental forces at hip around cg trunk:
Mp1 = -Frx(:,4).*(yS(:,1)-yzS)+Fry(:,4).*(xS(:,1)-xzS);
Mp2 = -Flx(:,4).*(yS(:,1)-yzS)+Fly(:,4).*(xS(:,1)-xzS);
% constraint: no hand of god moment on trunk:
ceq = Mp1+Mp2+Mr(:,3)+Ml(:,3)-I(4)*phiSdp; 
% c1 = phirdp(:,1)-repmat(phidpmax(1),N2,1);
% c2 = phirdp(:,2)-repmat(phidpmax(2),N2,1);
% c3 = phirdp(:,3)-repmat(phidpmax(3),N2,1);
% c4 = phildp(:,1)-repmat(phidpmax(4),N2,1);
% c5 = phildp(:,2)-repmat(phidpmax(5),N2,1);
% c6 = phildp(:,3)-repmat(phidpmax(6),N2,1);
% c7 = phiSdp-repmat(phidpmax(7),N2,1);
% 
% c8 = repmat(phidpmin(1),N2,1)-phirdp(:,1);
% c9 = repmat(phidpmin(2),N2,1)-phirdp(:,2);
% c10 = repmat(phidpmin(3),N2,1)-phirdp(:,3);
% c11 = repmat(phidpmin(4),N2,1)-phildp(:,1);
% c12 = repmat(phidpmin(5),N2,1)-phildp(:,2);
% c13 = repmat(phidpmin(6),N2,1)-phildp(:,3);
% c14 = repmat(phidpmin(7),N2,1)-phiSdp;
% c = [c1;
%      c2;
%      c3;
%      c4;
%      c5;
%      c6;
%      c7;
%      c8;
%      c9;
%      c10;
%      c11;
%      c12;
%      c13;
%      c14];
