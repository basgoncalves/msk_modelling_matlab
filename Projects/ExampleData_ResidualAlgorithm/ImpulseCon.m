function [c,ceq] = ImpulseCon(Xin,refFgr,refFgl,N,g,fs)
Fgrx = Xin(1:N,1);
Fgry = Xin(N+1:N*2,1);
Fglx = Xin(N*2+1:N*3,1);
Fgly = Xin(N*3+1:N*4,1);
mtot = Xin(N*4+1:N*4+1,1);

ceq(1,1) = Fgrx(1,1)-Fgrx(end,1);
ceq(2,1) = Fgry(1,1)-Fgry(end,1);
ceq(3,1) = Fglx(1,1)-Fglx(end,1);
ceq(4,1) = Fgly(1,1)-Fgly(end,1);

Fresx = Fgrx+Fglx;
Fresy = Fgry+Fgly-mtot*g;

vX = (1/(fs*mtot))*trapz(Fresx);
vY = (1/(fs*mtot))*trapz(Fresy);

ceq(5,1) = vX;
ceq(6,1) = vY;
c = [];