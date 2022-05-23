% SplitJointWork 
% based of Belli et al (2002) - DOI 10.1055/s-2002-20136

function [pfW,nfW,peW,neW] = SplitJointPower_Belli (Power,Moments,AngVel,fs)


% Poitive moment + poitive velocity (flexors positive work)
Log1 = double(Moments>0);
Log2 = double(AngVel>0);
Log0 = double(Power>0);
Log3 = Log0+Log1+Log2;
Log3(Log3<3) = 0;
Log3(Log3==3) = 1;
P = Power;
P(Log3~=1)= 0;

pfW = P;
%     figure
%     hold on
%     plot(p(:,1))
%     plot(Moments(:,1))
%     yyaxis right
%     plot(AngVel(:,1))


% Poitive moment + negative velocity (flexors negative work)
Log1 = double(Moments>0);
Log2 = double(AngVel<0);
Log0 = double(Power<0);
Log3 = Log0+Log1+Log2;
Log3(Log3<3) = 0;
Log3(Log3==3) = 1;
P = Power;
P(Log3~=1)= 0;

nfW = P;  


% Negative moment + Positive velocity (extensor negative work) - 
% Eccentric extensors

Log1 = double(Moments<0);       %Moments lower than zero
Log2 = double(AngVel>0);        % velocity greater than zero
Log0 = double(Power<0);
Log3 = Log0+Log1+Log2;
Log3(Log3<3) = 0;
Log3(Log3==3) = 1;
P = Power;
P(Log3~=1)= 0;

neW = P;  

% Negative moment + Negative velocity (extensor positive work) - 
% Concentric extensors

Log1 = double(Moments<0);
Log2 = double(AngVel<0);
Log0 = double(Power>0);
Log3 = Log0+Log1+Log2;
Log3(Log3<3) = 0;
Log3(Log3==3) = 1;
P = Power;
P(Log3~=1)= 0;

peW = P;  
