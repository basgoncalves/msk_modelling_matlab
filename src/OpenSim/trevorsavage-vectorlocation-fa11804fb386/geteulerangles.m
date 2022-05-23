function eulermat = geteulerangles(force)

nCurves  = length(force);
nFactors = size(force,2);
eulermat = zeros(nCurves, nFactors);

%----------------------
%     (AP)
%      x  x'
% Ry = | / 
%      |/____ z (ML)

%     (V)
%      y  y'
% Rz = | / 
%      |/____ x (AP)

%     (V)
%      y  y'
% Rx = | / 
%      |/____ z (ML)
%----------------------

for i = 1:length(force)
    X = force(i,1); Y = force(i,2); Z = force(i,3);
    % Res(i) = sqrt(X^2 + Y^2 + Z^2);
    Ry(i) = atan(Z/X); % engineering z axis, biomech y axis
    Rz(i) = atan(X/Y); % engineering y axis, biomech z axis
    Rx(i) = atan(Z/Y); 
end 
% output as [ Z   Y   X]  
eulermat  = [Ry; Rz; Rx]';
% rad2deg(eulermat)