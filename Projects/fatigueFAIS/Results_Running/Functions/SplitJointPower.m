% SplitJointWork 
% based of Belli et al (2002)

function [PeakPowers,Labels] = SplitJointPower (Power,Moments,AngVel,fs)
Labels={};
PeakPowers=[];

% Poitive moment + poitive velocity (flexors positive work)
Log1 = double(Moments>0);
Log2 = double(AngVel>0);
Log3 = Log1+Log2;
Log3(Log3<2) = 0;
Log3(Log3==2) = 1;
P = Power;
P(Log3~=1)= 0;

W = max(movmean(abs(P),fs/10));
PeakPowers(end+1,:) = W;
Labels{end+1} = 'pfW';


% Poitive moment + negative velocity (flexors negative work)
Log1 = double(Moments>0);
Log2 = double(AngVel<0);
Log3 = Log1+Log2;
Log3(Log3<2) = 0;
Log3(Log3==2) = 1;
P = Power;
P(Log3~=1)= 0;


W = max(movmean(abs(P),fs/10));

PeakPowers(end+1,:) = W;
Labels{end+1} = 'nfW';


% Negative moment + Positive velocity (extensor negative work) - 
% Eccentric extensors

Log1 = double(Moments<0);       %Moments lower than zero
Log2 = double(AngVel>0);        % velocity greater than zero
Log3 = Log1+Log2;
Log3(Log3<2) = 0;
Log3(Log3==2) = 1;
P = Power;
P(Log3~=1)= 0;


W = max(movmean(abs(P),fs/10));
PeakPowers(end+1,:) = W;
Labels{end+1} = 'peW';  

% Negative moment + Negative velocity (extensor negative work) - 
% Concentric extensors

Log1 = double(Moments<0);
Log2 = double(AngVel<0);
Log3 = Log1+Log2;
Log3(Log3<2) = 0;
Log3(Log3==2) = 1;
P = Power;
P(Log3~=1)= 0;

W = max(movmean(abs(P),fs/10));
PeakPowers(end+1,:) = W;
Labels{end+1} = 'neW'; 
