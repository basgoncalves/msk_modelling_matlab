clc
clearvars
close all
% gravity:
g = 9.81;
% sample frequency:
fs = 100;
% beneath this threshold for the combined ground reaction force it is
% assumed to be zero:
FORCETHRESHHIGH = 50;
FORCETHRESHLOW = 15;
% Minimum number of samples for swing phase duration:
MINSWING = 7;
currdir = cd;
cd ..
cd ..
nd = cd;
nd = [nd '\Project1\RuweData\herre.mat'];
load(nd);
cd(currdir)

GoodStridesSmall

% stridenr = 8; % Typical example
stridenr = 8;

subject = strides(stridenr,1);
condition = strides(stridenr,2);
stepnr = strides(stridenr,3);

x1 = output(subject).cond(condition).kinematics.x;
% x coords of markers:
x1 = [x1(:,1:5) x1(:,8:12)];
y1 = output(subject).cond(condition).kinematics.z;
% y coords of markers:
y1 = [y1(:,1:5) y1(:,8:12)];

% interpolate missing markers (x):
x1 = Interpoleer(x1);
% interpolate missing markers (y):
y1 = Interpoleer(y1);

x1 = HfFilter(x1,4,10,fs,size(x1,2));
y1 = HfFilter(y1,4,10,fs,size(x1,2));

% Ground reaction force right leg for chosen steps,
% column 1: horizontal component of force
% column 2: vertical component of force
Fgr = output(subject).cond(condition).kinetics.grf_R;
% horizontal position contact point:
r(:,1) = Fgr(:,3);
Fgr = Fgr(:,1:2);
Fgr = fliplr(Fgr);

% Ground reaction force left leg for chosen steps,
% column 1: horizontal component of force
% column 2: vertical component of force
Fgl = output(subject).cond(condition).kinetics.grf_L;
% horizontal position contact point:
r(:,2) = Fgl(:,3);
Fgl = Fgl(:,1:2);
Fgl = fliplr(Fgl);

% some vertical forces are slightly negative. This fixes that:
idxneg = find(Fgr(:,2) < 0);
Fgr(idxneg,2) = 0;
idxneg = find(Fgl(:,2) < 0);
Fgl(idxneg,2) = 0;

FgrcombSave = sqrt(Fgr(:,1).^2+Fgr(:,2).^2);
% set ground reaction force to zero if it is beneath a threshold and pick
% heel contacts (first force that is larger than zero) and toe off (first
% force that is zero):
[idxrhc,idxrto,Fgr,Fgrcomb] = StepDetect(Fgr,FORCETHRESHHIGH,FORCETHRESHLOW,MINSWING);

FglcombSave = sqrt(Fgl(:,1).^2+Fgl(:,2).^2);
% set ground reaction force to zero if it is beneath a threshold and pick
% heel contacts (first force that is larger than zero) and toe off (first
% force that is zero):
[idxlhc,idxlto,Fgl,Fglcomb] = StepDetect(Fgl,FORCETHRESHHIGH,FORCETHRESHLOW,MINSWING);

% Extract x and y foot-shoulder right side of the body:
xr = x1(:,1:5);
yr = y1(:,1:5);
% Extract x and y foot-shoulder left side of the body:
xl = x1(:,6:10);
yl = y1(:,6:10);
% Calculate base and end of the trunk:
xS = (xr(:,4:5)+xl(:,4:5))/2;
yS = (yr(:,4:5)+yl(:,4:5))/2;
% Extract foot-knee right side of the body:
xr = xr(:,1:3);
yr = yr(:,1:3);
% Extract foot-knee left side of the body:
xl = xl(:,1:3);
yl = yl(:,1:3);

to1r = idxrto(stepnr);
to2r = idxrto(stepnr+1);

% calculate body mass and modify vertical ground reaction force for a net zero delta vertical impulse:
mtot = ModifyVerticalImpulse(Fgr(to1r:to2r,2),Fgl(to1r:to2r,2),g);

% number of samples included, toe off start and the point before next toe off included:
N = to2r-to1r;
% ground reaction force for 1 stride:
Fgr = Fgr(to1r:to1r+N-1,:);
% ground reaction force left foot durig right step:
Fgl = Fgl(to1r:to1r+N-1,:);

% contact point left foot during right step:
r = [r(to1r:to1r+N-1,1) r(to1r:to1r+N-1,2)];
% x coordinates joints right leg for 1 stride
xr = xr(to1r:to1r+N-1,:);
% y coordinates joints right leg for 1 stride
yr = yr(to1r:to1r+N-1,:);
% x coordinates joints left leg for 1 stride
xl = xl(to1r:to1r+N-1,:);
% y coordinates joints left leg for 1 stride
yl = yl(to1r:to1r+N-1,:);
% spine:
xS = xS(to1r:to1r+N-1,:);
yS = yS(to1r:to1r+N-1,:);

% mean segment lengths:
Lr = SegmentLengths([xr xS(:,1)],[yr yS(:,1)]);
Ll = SegmentLengths([xl xS(:,1)],[yl yS(:,1)]);
LS = SegmentLengths(xS,yS);
Lrl = (Lr+Ll)/2;
L = [Lrl LS];

% segment angles meausured:
phir = Points2Angles([xr xS(:,1)],[yr yS(:,1)]);
phil = Points2Angles([xl xS(:,1)],[yl yS(:,1)]);
phiS = Points2Angles(xS,yS);

t = 0:1/fs:(N-1)/fs;

% coefficients for masses of segments (Winter):
% 1: foot
% 2: lower leg
% 3: upper leg
% 7: trunk
mc = [0.0145 0.0465 0.1 0.678];
m = mtot*mc;

% fractions of segments length for location of centre of gravity
% Winter
% 1: foot (from caudal to cranial)
% 2: lower leg
% 3: upper leg
% 4: torso
q = [0.5 0.567 0.567 0.626];
% radius of gyration for cog (Winter):
rg = [0.475 0.302 0.323 0.496];
% moments of inertia:
I = rg.^2.*L.^2.*m;

[MomrClassic,MomlClassic,MomHOG,FHOGX,FHOGY] = InvDynClassicFresEndTrunk(Fgr,Fgl,xr,yr,xl,yl,xS,yS,r,m,L,q,I,g,N,fs);

figure
subplot(2,1,1)
plot(t(1:N-2),(100/(mtot*g))*FHOGX(:,1),'Color',[0.8 0.5 0.5],'LineStyle','-','LineWidth',2)
hold on
plot(t(1:N-2),(100/(mtot*g))*FHOGY(:,1),'Color',[0.5 0.8 0.5],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('% Body weight')
title('Residual Force and Torque')
legend('Horizontal','Vertical')
subplot(2,1,2);
plot(t(1:N-2),MomHOG(:,1),'Color',[0.5 0.5 0.8],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Torque (Nm)')

[xz,yz] = CenterOfGravity([phir(1:2,1) phir(1:2,2) phir(1:2,3)], ...
                          [phil(1:2,1) phil(1:2,2) phil(1:2,3)],phiS(1:2,:),m,L,q);
xz = xz+xS(1:2,1);
yz = yz+yS(1:2,1);
xzp = (xz(2,1)-xz(1,1))*fs;
yzp = (yz(2,1)-yz(1,1))*fs;

% calculate prerequisites for center of grav trajectory:
Fgx = Fgr(1:N,1)+Fgl(1:N,1);
Fgy = Fgr(1:N,2)+Fgl(1:N,2);
xzdp = Fgx/(2*m(1)+2*m(2)+2*m(3)+m(4));
yzdp = (Fgy-(2*m(1)+2*m(2)+2*m(3)+m(4))*g)/(2*m(1)+2*m(2)+2*m(3)+m(4));
xzpcum = cumtrapz(xzdp)/fs;
yzpcum = cumtrapz(yzdp)/fs;
xzcum = cumtrapz(xzpcum)/fs;
yzcum = cumtrapz(yzpcum)/fs;

% model variables for optimization:
X0 = [phir(:,1);
      phir(:,2);
      phir(:,3);
      phil(:,1);
      phil(:,2);
      phil(:,3);
      phiS(:,1);
      xz(1,1);
      yz(1,1);
      xzp;
      yzp];
    
% Parameters for optimization:
A = [];
B = [];

Aeq = [];
beq = [];
% lower bounds:
lb = [];
% upper bounds:
ub = [];

%options = optimoptions('fmincon','GradObj','on','Algorithm','interior-point','MaxFunEvals',100000000,'MaxIter',10000);
fout = 1e-6;
options = optimoptions('fmincon','GradObj','off','Algorithm','interior-point','MaxFunEvals',100000000,'MaxIter',100000,'TolCon',fout,'TolFun',fout,'TolX',fout)

optimize = 1;
if optimize == 1
  [Xout,FVAL,EXITFLAG,OUTPUT,LAMBDA] = ...
  fmincon('StrideMin',X0,A,B,Aeq,beq,lb,ub,'StrideCon',options, ...
          MomrClassic,MomlClassic,Fgr,Fgl,r,xr,yr,xl,yl,xS,yS,xzdp,yzdp,xzpcum,yzpcum,xzcum,yzcum,m,L,q,I,g,N,fs);
  save Xout Xout
  disp(['Value Object Function = ' num2str(FVAL)])
  disp(['EXITFLAG = ' num2str(EXITFLAG)])
  disp(OUTPUT)
else
  load Xout
end

% Optimized linear acc and angular acc:
phirOpt = reshape(Xout(1:(N)*3,1),N,3);
philOpt = reshape(Xout((N)*3+1:(N)*6,1),N,3);
phiSOpt = reshape(Xout((N)*6+1:(N)*7,1),N,1);

[MomrOpt,MomlOpt] = HFInvDyn(Xout,Fgr,Fgl,r,m,L,q,I,g,(N),fs);

phirOpt = phirOpt(1:N,:);
philOpt = philOpt(1:N,:);
phiSOpt = phiSOpt(1:N,:);

phir = phir(1:N,:);
phil = phil(1:N,:);
phiS = phiS(1:N,:);

sumdiffsqphir = sum((phirOpt-phir).^2,1);
phirRMS = ((1/N)*sumdiffsqphir).^0.5
sumdiffsqphil = sum((philOpt-phil).^2,1);
philRMS = ((1/N)*sumdiffsqphil).^0.5
sumdiffsqphiS = sum((phiSOpt-phiS).^2,1);
phiSRMS = ((1/N)*sumdiffsqphiS).^0.5
  
sumdiffsqMomr = sum((MomrOpt-MomrClassic).^2,1);
MomrRMS = ((1/N)*sumdiffsqMomr).^0.5
sumdiffsqMoml = sum((MomlOpt-MomlClassic).^2,1);
MomlRMS = ((1/N)*sumdiffsqMoml).^0.5

N2 = N-2;
MomrClassic = MomrClassic(1:N2,:);
MomlClassic = MomlClassic(1:N2,:);
MomHOG = MomHOG(1:N2,:);

MomrOpt = MomrOpt(1:N2,:);
MomlOpt = MomlOpt(1:N2,:);

t = 0:1/fs:(N-1)/fs;
t2 = 0:1/fs:(N-3)/fs;

figure
plot(t,phir(1:N,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t,phirOpt(1:N,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t,phir(1:N,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t,phirOpt(1:N,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t,phir(1:N,3),'Color',[0.8 0 0],'LineStyle','--','LineWidth',1)
plot(t,phirOpt(1:N,3),'Color',[1 0 0],'LineStyle','-','LineWidth',2)
plot(t,phiS(1:N,1),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t,phiSOpt(1:N,1),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Segment angle (rad)')
title('Right leg')
legend('Foot measured','Foot optimized','Shank measured','Shank optimized','Thigh measured','Thigh optimized','Trunk measured','Trunk optimized')

% zelfde als hiervoor, maar zonder laatste twee punten:
figure
plot(t(1:end-2),phir(1:N-2,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t(1:end-2),phirOpt(1:N-2,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t(1:end-2),phir(1:N-2,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t(1:end-2),phirOpt(1:N-2,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t(1:end-2),phir(1:N-2,3),'Color',[0.8 0 0],'LineStyle','--','LineWidth',1)
plot(t(1:end-2),phirOpt(1:N-2,3),'Color',[1 0 0],'LineStyle','-','LineWidth',2)
plot(t(1:end-2),phiS(1:N-2,1),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t(1:end-2),phiSOpt(1:N-2,1),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Segment angle (rad)')
title('Right leg')
legend('Foot measured','Foot optimized','Shank measured','Shank optimized','Thigh measured','Thigh optimized','Trunk measured','Trunk optimized')

figure
plot(t,phil(1:N,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t,philOpt(1:N,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t,phil(1:N,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t,philOpt(1:N,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t,phil(1:N,3),'Color',[0.8 0 0],'LineStyle','--','LineWidth',1)
plot(t,philOpt(1:N,3),'Color',[1 0 0],'LineStyle','-','LineWidth',2)
plot(t,phiS(1:N,1),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t,phiSOpt(1:N,1),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Segment angle (rad)')
title('Left leg')
legend('Foot measured','Foot optimized','Shank measured','Shank optimized','Thigh measured','Thigh optimized','Trunk measured','Trunk optimized')

figure
plot(t2,MomrClassic(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,MomrOpt(:,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t2,MomrClassic(:,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,MomrOpt(:,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t2,MomrClassic(:,3),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t2,MomrOpt(:,3),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
plot(t2,MomHOG(:,1),'Color',[1 0 0],'LineStyle','--','LineWidth',1)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net torque (Nm)')
title('Right leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized','Residual classic')

% zelfde als hiervoor, maar zonder laatste twee punten:
figure
plot(t2(1:end-2),MomrClassic(1:end-2,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2(1:end-2),MomrOpt(1:end-2,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t2(1:end-2),MomrClassic(1:end-2,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2(1:end-2),MomrOpt(1:end-2,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t2(1:end-2),MomrClassic(1:end-2,3),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t2(1:end-2),MomrOpt(1:end-2,3),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
plot(t2(1:end-2),MomHOG(1:end-2,1),'Color',[1 0 0],'LineStyle','--','LineWidth',1)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net torque (Nm)')
title('Right leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized','Residual classic')

figure
plot(t2,MomlClassic(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,MomlOpt(:,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t2,MomlClassic(:,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,MomlOpt(:,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t2,MomlClassic(:,3),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t2,MomlOpt(:,3),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
plot(t2,MomHOG(:,1),'Color',[1 0 0],'LineStyle','--','LineWidth',1)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net torque (Nm)')
title('Left leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized','Residual classic')

phirJoint(:,1) = phir(:,2)-phir(:,1);
phirJoint(:,2) = phir(:,3)-phir(:,2);
phirJoint(:,3) = phiS-phir(:,3);

philJoint(:,1) = phil(:,2)-phil(:,1);
philJoint(:,2) = phil(:,3)-phil(:,2);
philJoint(:,3) = phiS-phil(:,3);

phirOptJoint(:,1) = phirOpt(:,2)-phirOpt(:,1);
phirOptJoint(:,2) = phirOpt(:,3)-phirOpt(:,2);
phirOptJoint(:,3) = phiSOpt-phirOpt(:,3);

philOptJoint(:,1) = philOpt(:,2)-philOpt(:,1);
philOptJoint(:,2) = philOpt(:,3)-philOpt(:,2);
philOptJoint(:,3) = phiSOpt-philOpt(:,3);

wr(:,1) = gradient(phirJoint(:,1),1/fs);
wr(:,2) = gradient(phirJoint(:,2),1/fs);
wr(:,3) = gradient(phirJoint(:,3),1/fs);
wl(:,1) = gradient(philJoint(:,1),1/fs);
wl(:,2) = gradient(philJoint(:,2),1/fs);
wl(:,3) = gradient(philJoint(:,3),1/fs);
Pr = MomrClassic.*wr(1:N-2,:);
Pl = MomlClassic.*wl(1:N-2,:);

wrOpt(:,1) = gradient(phirOptJoint(:,1),1/fs);
wrOpt(:,2) = gradient(phirOptJoint(:,2),1/fs);
wrOpt(:,3) = gradient(phirOptJoint(:,3),1/fs);
wlOpt(:,1) = gradient(philOptJoint(:,1),1/fs);
wlOpt(:,2) = gradient(philOptJoint(:,2),1/fs);
wlOpt(:,3) = gradient(philOptJoint(:,3),1/fs);

PrOpt = MomrOpt.*wrOpt(1:N-2,:);
PlOpt = MomlOpt.*wlOpt(1:N-2,:);

figure
plot(t2,Pr(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,PrOpt(:,1),'Color',[0.2 0.2 0.2],'LineStyle','-','LineWidth',2)
plot(t2,Pr(:,2),'Color',[0.5 0 0],'LineStyle','--','LineWidth',1)
plot(t2,PrOpt(:,2),'Color',[0.5 0 0],'LineStyle','-','LineWidth',2)
plot(t2,Pr(:,3),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,PrOpt(:,3),'Color',[0 0.8 0],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net power (Watt)')
title('Right leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized')

figure
plot(t2,Pl(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,PlOpt(:,1),'Color',[0.2 0.2 0.2],'LineStyle','-','LineWidth',2)
plot(t2,Pl(:,2),'Color',[0.5 0 0],'LineStyle','--','LineWidth',1)
plot(t2,PlOpt(:,2),'Color',[0.5 0 0],'LineStyle','-','LineWidth',2)
plot(t2,Pl(:,3),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,PrOpt(:,3),'Color',[0 0.8 0],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net power (Watt)')
title('Left leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized')

% Videogebeuren:

xz0 = Xout(N*7+1,1);
yz0 = Xout(N*7+2,1);
xzp0 = Xout(N*7+3,1);
yzp0 = Xout(N*7+4,1);

cumxzp0 = 0:xzp0/fs:(N-1)*xzp0/fs;
cumyzp0 = 0:yzp0/fs:(N-1)*yzp0/fs;
xz = xz0+cumxzp0'+xzcum;
yz = yz0+cumyzp0'+yzcum;

[xzg,yzg] = CenterOfGravity(phir,phil,phiS,m,L,q);

xSOpt(:,1) = xz-xzg;
ySOpt(:,1) = yz-yzg;

[xr,yr,xl,yl,xS,yS] = Model2Points(xS(:,1),yS(:,1),phir,phil,phiS,L);
[xrOpt,yrOpt,xlOpt,ylOpt,xSOpt,ySOpt] = Model2Points(xSOpt(:,1),ySOpt(:,1),phirOpt,philOpt,phiSOpt,L);


savedata = [xr yr xl yl xS yS xrOpt yrOpt xlOpt ylOpt xSOpt ySOpt];
bestand = 'animatie.txt';
save(bestand,'savedata','-ascii')

