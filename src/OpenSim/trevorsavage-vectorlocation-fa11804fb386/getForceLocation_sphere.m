function [dp, dr, pintsct, Ae, A2D] = getForceLocation_sphere(force, avgvec_ph, avgvec_tsk, frame, paths, side, femrad, fr, intfms)
% About me...
% This function takes the force vector and determines where that force 
% intersects with a sphere scaled using scale factors from opensim for a
% participant.

% Tool boxes
% The following toolboxes are needed for this code. Paths to these should
% be passed in as structure:
% - geom3d

% INPUT VARIABLES
% -------------------------------------
% force      - -
% avgvec_ph  - dbl - average vector for phase
% avgvec_tsk - dbl -  
% paths      - str - paths to external tool boxes
% side       - stg - side studied
% femrad     - dbl - femur radius
% fr         - dbl - frame rate
% intfms     - dbl - interpolate frames 
% -------------------------------------
% OUTPUTS
% dp         - dbl - distance between points on vector path
% dr         - dbl - distance between point and centre of pressure
% rvintsct   - dbl - intersection of the representative vector
% Ae         - dbl - Surface area of the triangle dr1-o-dr2
% -------------------------------------

% %change path to geom3d
addpath(paths.geom3d)
% gfr      = 24.3;             % defines radius in cm
% r_scl  = gfr*SF;             % scale radius
sphere     = [0 0 0 femrad]; % r_scaled = r*ss_scalefact;

avgvec_ph  = (avgvec_ph * femrad);
avgvec_tsk = (avgvec_tsk * femrad);

% point of intersection of representative vector
line       = ([0 0 0 avgvec_ph]);
rvpts      = intersectLineSphere(line, sphere);
rvintsct   = rvpts(find(rvpts(:,2)>0),:);    % get y +ve point of intersection

l = force/50;
% plot the force vector on the 'femoral head'
for i = 1:length(l)
    x = l(i,1); %X = ([0, x]); 
    y = l(i,2); %Y = ([0, y]);
    if strcmp(side, 'Left') == 1
        z = -l(i,3); %Z = ([0, z]);
    elseif strcmp(side, 'Right') == 1
        z = l(i,3); %Z = ([0, z]);
    end
    line = ([-x -y -z x y z]); % MATLAB default is AP,ML,vertical
    % plot3(X, Z, Y);
    points       = intersectLineSphere(line, sphere);
    pintsct(i,:) = points(find(points(:,2)>0),:); % get y +ve point of intersection
    [theta(i), rho(i), Z(i)] = cart2pol(pintsct(i,1), pintsct(i,2), pintsct(i,3)); % get polar coords(NOT USED)
    [theta(i), phi(i), r(i)] = cart2sph(pintsct(i,1), pintsct(i,2), pintsct(i,3)); % get polar coords(NOT USED)    
end

%% QUALITY CONTROL plot vector and manuscript figures
% % Plot the path as a line across the surface
% h  = drawSphere(sphere, 'nPhi', 100, 'nTheta', 100);  
% hold on
% set(h, 'linestyle', 'none'); set(h, 'facecolor', 'y');
% axis equal; alpha 0.3;
% % Plot the average position of the path (red hexegram)
% plot3(avgvec_tsk(:,1),avgvec_tsk(:,2)+0.1,avgvec_tsk(:,3),'hr', 'MarkerFaceColor', 'r', 'MarkerSize', 18); 
% % Add joint centre (black circle)
% % plot3(0,0,0,'.k', 'MarkerFaceColor', 'k', 'MarkerSize', 24); text(0,0,0,' \leftarrow Hip joint centre', 'FontSize',14)
% % Labels
% xlabel('+AP-');  ylabel('V'); zlabel('-ML+')
% % Plot the path (blue line)
% plot3(pintsct(:,1),pintsct(:,2),pintsct(:,3), 'LineWidth', 2.5); xlabel('X');  ylabel('Y'); zlabel('Z');
% % plot the 'spread' of each third point on the path 
% for i = 1:3:length(pintsct)
%     plot3([avgvec_tsk(:,1) pintsct(i,1)],[avgvec_tsk(:,2) pintsct(i,2)],[avgvec_tsk(:,3) pintsct(i,3)], 'k', 'LineWidth', 0.2)
% end
% % Blow it up to fit a plot and turn axes off
% xlim([-4 14]); ylim([0 25]); zlim([-14 4]); axis('off');
% hold off
% 
% 
% figure
% h  = drawSphere(sphere, 'nPhi', 100, 'nTheta', 100); 
% hold on
% set(h, 'linestyle', 'none'); set(h, 'facecolor', 'y');
% axis equal; alpha 0.3;
% % Plot the average position of the path (red hexegram)
% plot3(avgvec_ph(:,1),avgvec_ph(:,2),avgvec_ph(:,3),'hr', 'MarkerFaceColor', 'r', 'MarkerSize', 18); 
% xlabel('Anteroposterior');  ylabel('Vertical'); zlabel('Mediolateral'); zs = zeros(length(pintsct));
% markcol = [41 99 40]/245; % 'Marker', 'o', 'MarkerEdgeColor', markcol,
% % Plot the path (blue circles)
% for p = 1:length(pintsct)
%     plot3(pintsct(p,1),pintsct(p,2),pintsct(p,3), 'ob', 'LineWidth', 2); % <- surface vector path
%     % plot3([0 -l(p,1)],[0 -l(p,2)],[0 -l(p,3)],'b'); % <- force vectors
% end
% % Draw second sphere with larger faces to give depth to the sphere without confusion
% h2  = drawSphere(sphere, 'nPhi', 10, 'nTheta', 10); 
% set(h2, 'linestyle', ':'); set(h2, 'facecolor', 'y');
% axis equal; alpha 0.3;
% % Plot line from HJC to path
% zs = zeros(length(pintsct));
% for i = 1:3:length(pintsct)
%     plot3([zs(i,1) pintsct(i,1)],[zs(i,1) pintsct(i,2)],[zs(i,1) pintsct(i,3)], 'k', 'LineWidth', 0.2)
% end
% hold off

%% Get the distances
% Phase - distances from CoP for phase to force vector
[dp, dr, ~]      = getEuclidean (avgvec_ph, pintsct, femrad);
% Gait cycle - distances from CoP for gaitcycle/task to force vector
[~,  dr_tsk, th] = getEuclidean (avgvec_tsk, pintsct, femrad);

%% Calculate area
% 3D euclidean Area
for d = 1:length(dr_tsk)-1
    % Using included angle calculate the area
    a    = dr_tsk(d); b = dr_tsk(d+1);
    Ae(d)= (a * b * sin(th(d)))/2;
    % check length of 'c' against dp using theta
    c    = sqrt(a^2 + b^2 - 2 * a * b * cos(th(d)));
    % calculate error ratio with respect to length of dp
  dpc(d) = (c - dp(d))/dp(d);
end
% mean(dpc);

% Area of 3D shape projected in 2D
x = [avgvec_tsk(1); pintsct(:,1)]; y = [avgvec_tsk(2); pintsct(:,2)]; z = [avgvec_tsk(3); pintsct(:,3)];
x1= pintsct(:,1);  y1 = pintsct(:,2);  z1 = pintsct(:,3);
ax= avgvec_tsk(1); ay = avgvec_tsk(2); az = avgvec_tsk(3);
if strcmp(frame, 'Femur') == 1 
    [k, A2D] = boundary(x, z);
     % plot (x(k), z(k), '--b'); hold on; plot (x1, z1, 'r'); plot(ax,az,'*r'); 
elseif strcmp(frame, 'Pelvis') == 1 
    [k, A2D] = boundary(x, z);
     % plot (x(k), z(k), '--b'); hold on; plot (x1, z1, 'r'); plot(ax,az,'*r'); 
end
% 
% title('Joint contact force projected in 2D (blue) with perimeter boundary (red)');

%% Interpolate data
dp     = interpolateData(dp,fr,intfms);
dr     = interpolateData(dr,fr,intfms);
% th     = interpolateData(th,fr,intfms);
% dr_tsk = interpolateData(dr_tsk,fr,intfms);
Ae     = interpolateData(Ae,fr,intfms);
rmpath(paths.geom3d)
