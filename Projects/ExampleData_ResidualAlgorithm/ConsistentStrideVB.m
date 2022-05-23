clc
clearvars
close all
% gravity:
g = 9.81;
% sample frequency:
fs = 100;
% beneath this threshold for the combined ground reaction force it is
% assumed to be zero:
FORCETHRESHHIGH = 110;
FORCETHRESHLOW = 93;
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

load('x1.mat','x1')
% x coords of markers:
x1 = [x1(:,1:5) x1(:,8:12)];
load('y1.mat','y1')
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
load('Fgr.mat','Fgr')
% horizontal position contact point:
r(:,1) = Fgr(:,3);
Fgr = Fgr(:,1:2);
Fgr = fliplr(Fgr);

% Ground reaction force left leg for chosen steps,
% column 1: horizontal component of force
% column 2: vertical component of force
load('Fgl.mat','Fgl')
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
mtot = ModifyVerticalImpulse(Fgr(to1r:to2r-1,2),Fgl(to1r:to2r-1,2),g);

% number of samples included, point before toe off start and the point after next toe off included:
N = to2r-to1r+3;
% ground reaction force for 1 stride:
Fgr = Fgr(to1r-1:to1r+N-2,:);
% ground reaction force left foot durig right step:
Fgl = Fgl(to1r-1:to1r+N-2,:);

% contact point left foot during right step:
r = [r(to1r-1:to1r+N-2,1) r(to1r-1:to1r+N-2,2)];
% x coordinates joints right leg for 1 stride
xr = xr(to1r-1:to1r+N-2,:);
% y coordinates joints right leg for 1 stride
yr = yr(to1r-1:to1r+N-2,:);
% x coordinates joints left leg for 1 stride
xl = xl(to1r-1:to1r+N-2,:);
% y coordinates joints left leg for 1 stride
yl = yl(to1r-1:to1r+N-2,:);
% spine:
xS = xS(to1r-1:to1r+N-2,:);
yS = yS(to1r-1:to1r+N-2,:);

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

% model variables for optimization:
X0 = [phir(:,1);
      phir(:,2);
      phir(:,3);
      phil(:,1);
      phil(:,2);
      phil(:,3);
      phiS(:,1);
      xS(:,1);
      yS(:,1)];

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
          Fgr,Fgl,r,xr,yr,xl,yl,xS,yS,phir,phil,phiS,m,L,q,I,g,N,fs);
  save Xout Xout
  disp(['Value Object Function = ' num2str(FVAL)])
  disp(['EXITFLAG = ' num2str(EXITFLAG)])
  disp(OUTPUT)
else
  load Xout
end

phirOpt = reshape(Xout(1:3*N),N,3);
philOpt = reshape(Xout(3*N+1:6*N),N,3);
phiSOpt = reshape(Xout(6*N+1:7*N),N,1);
xSOpt = reshape(Xout(7*N+1:8*N),N,1);
ySOpt = reshape(Xout(8*N+1:9*N),N,1);

t = 0:1/fs:(N-1)/fs;
tp = 100*t/t(end);

figure(1)
plot(t,xSOpt(1:N,1),'Color',[0.2 0.2 0.2],'LineStyle','-','LineWidth',2)
hold on
plot(t,ySOpt(1:N,1),'Color',[0 0.8 0],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Hip position (m)')
title('Hip')
legend('X hip','Y hip')

figure(2)
plot(tp,phir(1:N,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(tp,phirOpt(1:N,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(tp,phir(1:N,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(tp,phirOpt(1:N,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(tp,phir(1:N,3),'Color',[0.8 0 0],'LineStyle','--','LineWidth',1)
plot(tp,phirOpt(1:N,3),'Color',[1 0 0],'LineStyle','-','LineWidth',2)
plot(tp,phiS(1:N,1),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(tp,phiSOpt(1:N,1),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca, 'FontName', 'Arial')
set(gca,'FontSize',12)
xlabel('Percentage of stride')
ylabel('Segment angle (rad)')
title('Right leg')
legend('Foot measured','Foot optimized','Shank measured','Shank optimized','Thigh measured','Thigh optimized','Trunk measured','Trunk optimized')

set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 10 10])
print -dtiff probeersel.tif -r300

figure(3)
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

t2 = 1/fs:1/fs:(N-2)/fs;

[MomrClassic,MomlClassic,~,~,~,~] = InvDynClassic(Fgr,Fgl,xr,yr,xl,yl,xS,yS,r,m,q,I,g,N,fs);
[MomrOpt,MomlOpt] = HFInvDyn(Xout,Fgr,Fgl,r,m,L,q,I,g,N,fs);

figure(4)
plot(t2,MomrClassic(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,MomrOpt(:,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t2,MomrClassic(:,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,MomrOpt(:,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t2,MomrClassic(:,3),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t2,MomrOpt(:,3),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net torque (Nm)')
title('Right leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized')

figure(5)
plot(t2,MomlClassic(:,1),'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1)
hold on
plot(t2,MomlOpt(:,1),'Color',[0 0 0],'LineStyle','-','LineWidth',2)
plot(t2,MomlClassic(:,2),'Color',[0 0.8 0],'LineStyle','--','LineWidth',1)
plot(t2,MomlOpt(:,2),'Color',[0 1 0],'LineStyle','-','LineWidth',2)
plot(t2,MomlClassic(:,3),'Color',[0 0 0.8],'LineStyle','--','LineWidth',1)
plot(t2,MomlOpt(:,3),'Color',[0 0 1],'LineStyle','-','LineWidth',2)
set(gca,'FontSize',16)
xlabel('Time (s)')
ylabel('Net torque (Nm)')
title('Left leg')
legend('Ankle classic','Ankle optimized','Knee classic','Knee optimized','Hip classic','Hip optimized')
