
function out = sum3Dvector(X,Y,Z)

if nargin == 3
    out = sqrt(X.^2 + Y.^2 + Z.^2);
elseif nargin == 1
    out = sqrt(X(:,1).^2 + X(:,2).^2 + X(:,3).^2);
else
    error('please input a 3 columns matrix or 3 seperate vectors')
end