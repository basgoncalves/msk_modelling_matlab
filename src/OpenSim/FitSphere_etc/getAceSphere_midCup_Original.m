function [center_ace, radius_ace, midcup, psup_max, center_circ] = getAceSphere_midCup(scaleF, dirFolders)
%% script to fit sphere acetabulum and find midpoint cup systematically
% all data in same coordinate system opensim - pelvis
% 1. fit sphere, 2. get line perpendicular to acetabular rim and through mid sphere, 3.get intersection line and sphere. 
%
% line through center sphere perpendicular (orientation defined by v3) to surface psup,pant,pmid
%
% x = v3(1)*t + cx; 
% y = v3(2)*t + cy;
% z = v3(3)*t + cz;
% 
% sphere: (x-cx)^2 + (y-cy)^2 + (z-xz)^2 = r^2 -> c=centre sphere, r = radius sphere
%
% solve for t. 
% get intersection
% 
% vx = a*t + x0, vy = b*t + y0, vz = c*t + z0; 
% https://www.youtube.com/watch?v=vokqijJs2Kg&ab_channel=TheOrganicChemistryTutor
% perpendicular to plane -> a, b, c => coeffs plane equation (normal vector)
% https://nl.mathworks.com/matlabcentral/answers/465826-finding-point-of-intersection-between-a-line-and-a-sphere

%%
addpath('.\shared\')
fid = fopen('acetabulum.asc', 'rt');
C = textscan(fid, '%f%f%f', 'Delimiter',' ', 'HeaderLines', 1);
fclose(fid);
scaleF = 1;

%% fit sphere to acetabulum
data_points = [C{1}(4:end), C{2}(4:end),C{3}(4:end)].* repmat(scaleF,length(C{1}(4:end)),1);
[center_ace, radius_ace] = sphereFit(data_points);
%% create plane acetabular rim:
% 3 points on surface acetabular rim 
psup = [-0.0527, -0.0541, 0.0971] .* scaleF;
pant = [-0.0326, -0.0699, 0.0768] .* scaleF;
pmid = [-0.0571, -0.0732, 0.08] .* scaleF;

% vector v3 perpendicular to surface acetabular rim  
v1 = psup - pmid;
v2 = pant - pmid;
v3 = cross(v1,v2);
% plane => ax + by + cz = d => v3(1)(x-p1_x) + v3(2)(y-p1_y) + v3(3)(z-p1_z)
d = -v3(1)*psup(1) - v3(2)*psup(2) - v3(3)*psup(3);

% find intersection line center sphere to plane (perpendicular to plane) = middle circle. 
syms t2
sol2 = solve(v3(1)* (v3(1)*t2 + center_ace(1)) + v3(2)* (v3(2)*t2 + center_ace(2))+ v3(3)* (v3(3)*t2 + center_ace(3))+d, t2);
center_circ = v3*double(sol2(1)) + center_ace;
d_center_circ2sphere = sqrt((center_ace(1) -center_circ(1))^2 + (center_ace(2) -center_circ(2))^2 +(center_ace(3) -center_circ(3))^2); 
rad_circ = sqrt(radius_ace^2 - d_center_circ2sphere^2);
d_circle2cup = radius_ace - d_center_circ2sphere;

% get 3D orientation plane - v3 = perpendicular to plane, so remove 90deg. 
alpha = atan2(v3(2),v3(3))-0.5*pi;
beta = atan2(v3(3),v3(1)) -0.5*pi;
gamma = atan2(v3(2),v3(1))-0.5*pi;

Rx = [1 0 0; 0 cos(alpha) -sin(alpha); 0 sin(alpha) cos(alpha)];
Ry = [cos(beta) 0 sin(beta); 0 1 0; -sin(beta) 0 cos(beta)];
Rz = [cos(gamma) -sin(gamma) 0; sin(gamma) cos(gamma) 0; 0 0 1];
% max superior point, is point on circle that only moves along the plane in
% y direction - > rotate point from plane to pelvis cs. 
angles = linspace(0,2*pi, 100);
for i = 1:length(angles)
    x = cos(angles(i))*rad_circ;
    y = sin(angles(i))*rad_circ;
    pcirc(i,:) = center_circ + [x,y,0]*Rx*Ry*Rz;
end
[~,imax] = max(pcirc(:,3));
psup_max = pcirc(imax,:);
syms t
sol = solve((v3(1)*t + center_ace(1) - center_ace(1))^2 + (v3(2)*t + center_ace(2) - center_ace(2))^2 + ...
    (v3(3)*t + center_ace(3) - center_ace(3))^2 == radius_ace^2, t);

intersect1 = v3*double(sol(1)) + center_ace;
intersect2 = v3*double(sol(2)) + center_ace;

% chose point that has smallest z value (closest to middle pelvis)
if intersect1(3)<intersect2(3)
    midcup = intersect1;
else
    midcup = intersect2;
end


%% write sphere dimensions to .txt. 
dirModel = [dirFolders.MOtoNMS,'OpenSim_Model\'];
fileID = fopen([dirModel, 'ace_sphere.txt'],'w');
fprintf(fileID, 'Sphere_radius (m) \t Circle_radius \t dCircle2Cup \t Sphere Center_x \t Sphere Center_y \t Sphere Center_z \t mid cup_x  \t mid cup_y \t mid cup_z \t superior point_x \t superior point_y \t superior point_z \n');
fprintf(fileID, '%.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \n', ...
    radius_ace, rad_circ, d_circle2cup, center_ace(1), center_ace(2), center_ace(3), midcup(1), midcup(2), midcup(3), psup_max(1), psup_max(2), psup_max(3) );
fclose(fileID);


%% plot
figure;hold on
[xs,ys,zs] = sphere;
xs = xs * radius_ace;
ys = ys * radius_ace;
zs = zs * radius_ace;
plot3(xs + center_ace(1), ys+center_ace(2), zs+center_ace(3),'r')
plot3(center_ace(1), center_ace(2), center_ace(3),'ok')
plot3(intersect1(1), intersect1(2), intersect1(3),'og')
plot3(intersect2(1), intersect2(2), intersect2(3),'oc')

plot3(center_circ(1), center_circ(2), center_circ(3),'or', 'linewidth',5)
plot3(midcup(1), midcup(2), midcup(3),'^c', 'linewidth',5)
plot3(psup_max(1), psup_max(2), psup_max(3),'^k', 'linewidth',15)

for i = 1:length(pcirc)
    plot3(pcirc(i,1), pcirc(i,2), pcirc(i,3),'*k', 'linewidth', 3)
end

pcshow(data_points,'k'); 
plot3(psup(1), psup(2), psup(3),'*b')
plot3(pant(1), pant(2), pant(3),'*b')
plot3(pmid(1), pmid(2), pmid(3),'*b')
axis equal



