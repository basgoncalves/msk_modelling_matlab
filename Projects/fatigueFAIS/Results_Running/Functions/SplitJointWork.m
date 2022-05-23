% SplitJointWork
% based of David Winter criteria - DOI 10.1055/s-2002-20136

function [pfW,nfW,peW,neW] = SplitJointWork (Power,Moments,AngVel,fs)


[Nrows,Ncols] = size(Power);
if Nrows<2
    pfW=NaN(1,Ncols);
    nfW=NaN(1,Ncols);
    peW=NaN(1,Ncols);
    neW=NaN(1,Ncols);
    return
end

% Poitive moment + poitive velocity (flexors positive work)
pfW=WorkCalc(Power,Moments,AngVel,fs,1,1);
% Poitive moment + negative velocity (flexors negative work)
nfW=WorkCalc(Power,Moments,AngVel,fs,1,-1);
% Negative moment + Positive velocity (extensor negative work) - Eccentric extensors
neW=WorkCalc(Power,Moments,AngVel,fs,-1,1);
% Negative moment + Negative velocity (extensor negative work) - Concentric extensors
peW=WorkCalc(Power,Moments,AngVel,fs,-1,-1);

    function W=WorkCalc(Power,Moments,AngVel,fs,MomSig,VelSig) %Sig = 1 or -1 (positive or negative)
        
        
        Log1 = double(MomSig * Moments>0);
        Log2 = double(VelSig * AngVel>0);
        Log3 = Log1+Log2;
        Log3(Log3<2) = 0;
        Log3(Log3==2) = 1;
        P = Power;
        P(Log3~=1)= 0;
        [Nrows,~] = size(P);
        
        time = 1/fs:1/fs:Nrows/fs;
        W = trapz(time,P);
        
    end
end