function J = StrideMin(Xin,~,~,~,refxr,refyr,refxl,refyl,refxS,refyS, ...
                       refphir,refphil,refphiS,m,L,q,~,~,N,fs)
% model pos:
phir = reshape(Xin(1:N*3,1),N,3);
phil = reshape(Xin(N*3+1:N*6,1),N,3);
phiS = reshape(Xin(N*6+1:N*7,1),N,1);
xS = reshape(Xin(N*7+1:N*8,1),N,1);
yS = reshape(Xin(N*8+1:N*9,1),N,1);
[xr,yr,xl,yl,xS,yS] = Model2Points(xS(:,1),yS(:,1),phir,phil,phiS,L);

% differences between measured and model cartesian positions:
dxr = xr-refxr;
dyr = yr-refyr;
dxl = xl-refxl;
dyl = yl-refyl;
dxS = [xS(:,1) xS(:,2)]-refxS;
dyS = [yS(:,1) yS(:,2)]-refyS;

Js = sum(sum(dxr.^2,1),2)+ ...
     sum(sum(dyr.^2,1),2)+ ...
     sum(sum(dxl.^2,1),2)+ ...
     sum(sum(dyl.^2,1),2)+ ...
     sum(sum(dxS.^2,1),2)+ ...
     sum(sum(dyS.^2,1),2);
   
Jphi = sum(sum((phir-refphir).^2,1),2)+ ...
       sum(sum((phil-refphil).^2,1),2)+ ...
       sum((phiS-refphiS).^2,1);
J = Js+Jphi
