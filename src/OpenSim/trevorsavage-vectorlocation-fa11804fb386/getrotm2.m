function rotm = getrotm(force)

nCurves  = length(force);
nFactors = size(force,2);
eulermat = zeros(nCurves, nFactors);
a        = ([1 0 0]);

for i = 1:length(force)
    p = force(i,:);       b = p/norm(p);
    r = vrrotvec(a,b);
    rotm(:,:,i) = vrrotvec2mat(r);
    nwvec(i,:)  = p * rotm(:,:,i);
end 
% % output as [ Z   Y   X]  
% eulermat  = [Ry; Rz; Rx]';