function J = COGMin(Xin,refxcog,refycog,xzdp,yzdp,fs)
% model pos:
xz0 = Xin(1,1);
yz0 = Xin(2,1);
xz0p = Xin(3,1);
yz0p = Xin(4,1);

cumxzp = xz0p+(1/fs)*cumtrapz(xzdp);
cumyzp = yz0p+(1/fs)*cumtrapz(yzdp);
cumxz = xz0+(1/fs)*cumtrapz(cumxzp);
cumyz = yz0+(1/fs)*cumtrapz(cumyzp);

dxz = refxcog-cumxz;
dyz = refycog-cumyz;

J = sum(dxz.^2,1)+sum(dyz.^2,1)
