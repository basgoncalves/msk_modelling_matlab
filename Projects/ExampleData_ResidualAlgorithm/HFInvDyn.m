function [Mr,Ml] = HFInvDyn(Xin,Fgr,Fgl,r,m,L,q,I,g,N,fs)
phir = reshape(Xin(1:N*3,1),N,3);
phil = reshape(Xin(N*3+1:N*6,1),N,3);
phiS = reshape(Xin(N*6+1:N*7,1),N,1);
xS = reshape(Xin(N*7+1:N*8,1),N,1);
yS = reshape(Xin(N*8+1:N*9,1),N,1);
[xr,yr,xl,yl,xS,yS] = Model2Points(xS(:,1),yS(:,1),phir,phil,phiS,L);

h = 1/fs;
phirp = zeros(N-2,3);
philp = zeros(N-2,3);
phirdp = zeros(N-2,3);
phildp = zeros(N-2,3);
for i = 1:3
  phirp(:,i) = gradient1(phir(1:end,i),h);
  philp(:,i) = gradient1(phil(1:end,i),h);
  phirdp(:,i) = gradient2(phir(:,i),h);
  phildp(:,i) = gradient2(phil(:,i),h);
end
phiSdp = gradient2(phiS(:,1),h);

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

xzrp = zeros(N-2,3);
yzrp = zeros(N-2,3);
xzlp = zeros(N-2,3);
yzlp = zeros(N-2,3);
xzrdp = zeros(N-2,3);
yzrdp = zeros(N-2,3);
xzldp = zeros(N-2,3);
yzldp = zeros(N-2,3);
for i = 1:3
  xzrp(:,i) = gradient1(xzr(1:end,i),h);
  yzrp(:,i) = gradient1(yzr(1:end,i),h);
  xzlp(:,i) = gradient1(xzl(1:end,i),h);
  yzlp(:,i) = gradient1(yzl(1:end,i),h);
  xzrdp(:,i) = gradient2(xzr(:,i),h);
  yzrdp(:,i) = gradient2(yzr(:,i),h);
  xzldp(:,i) = gradient2(xzl(:,i),h);
  yzldp(:,i) = gradient2(yzl(:,i),h);
end
xzSdp = gradient2(xzS,h);
yzSdp = gradient2(yzS,h);
  
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
