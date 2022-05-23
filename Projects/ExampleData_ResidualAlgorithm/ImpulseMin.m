function J = ImpulseMin(Xin,refFgr,refFgl,N,g,fs)
Fgrx = Xin(1:N,1);
Fgry = Xin(N+1:N*2,1);
Fglx = Xin(N*2+1:N*3,1);
Fgly = Xin(N*3+1:N*4,1);

J = sum((refFgr(:,1)-Fgrx).^2,1)+ ...
    sum((refFgr(:,2)-Fgry).^2,1)+ ...
    sum((refFgl(:,1)-Fglx).^2,1)+ ...
    sum((refFgl(:,2)-Fgly).^2,1)
