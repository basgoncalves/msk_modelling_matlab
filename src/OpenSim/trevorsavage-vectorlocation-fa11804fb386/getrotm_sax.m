function rotm = getrotm_sax(force)
% Code by David Saxby through Slack
nCurves  = length(force);
nFactors = size(force,2);
eulermat = zeros(nCurves, nFactors);
a        = ([1 0 0]);

for i = 1:length(force)
    p     = force(i,:);       p = p/norm(p);
    angle = acosd(dot(p,[1, 0, 0])); % acos of dot product gives the angle
    u     = cross([1,0,0],p); u = u/norm(u); 
    idmat = eye(3) * cosd(angle(1)) + sind(angle(1));    % identity matrix
    rotm(:,:,i)  = idmat * [0, -u(3), u(2); u(3),0,-u(1); -u(2),u(1) 0] + (1-cosd(angle(1))) * [u(1)^2, u(1)*u(2), u(1)*u(3); u(1)*u(2), u(2)^2, u(2)*u(3); u(1)*u(3), u(2)*u(3), u(3)^2 ];
    nwvec(i,:) = p * rotm(:,:,i);
end 
% % output as [ Z   Y   X]  
% eulermat  = [Ry; Rz; Rx]';