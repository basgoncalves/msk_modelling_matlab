%% Description - Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves 
% interpolate to get the x at y = FindPoint
%
%INPUT
%
%   Data = NxM matrix
%   FindPoint = a scalar indication the point in the curve that you want to
%   find 
%
%   Example: yi = Interp (Data, 2)   -> get the x value at the y = 2
%REFERENCES 
%   https://au.mathworks.com/help/matlab/ref/interp1.html
%   https://au.mathworks.com/matlabcentral/answers/255505-find-value-in-interpolated-data

function yi = Interp (Data,FindPoint)

[~,Ncol] = size (Data);
yi = zeros (1,Ncol);

for col = 2: Ncol

x = Data (:,1)';
y = Data (:,col)';

yi(col) = interp1(y,x,FindPoint);
plot (x,y); hold on; plot (yi,2, 'o');

end