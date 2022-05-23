function getForceLocation_stl(force, paths, SF, phases, fr, intfms, side, vargin)
% GETFORCELOCATION - ABOUT ME
% About me...
% This function takes the force vector and determines where that force 
% intersects with the stl. First, the code determines the three closest 
% vertices to the force vector, then it creates a plane from those three 
% and finally it determines the positione where the vector intersects with 
% the plane. The stl is scaled using the femoral scale factors from opensim
% for this participant.

% Tool boxes
% The following toolboxes are needed for this code. Paths to these should
% be passed in as structure:
% - geom3d
% - stlTools
% --------------------------------
% -INPUTS-
% force  - - n x 3 array of force data 
% paths  - - Paths to stlTools and geom3d as structure with 2 fields as strings 
% SF     - dbl - Scale factor of femur
% phases - - 
% fr     - dbl - frame rate 
% intfms - - 
% side   - stg - Side analysed

% -OUTPUTS-

% --------------------------------
%% READ and PLOT STL code
model = createpde(3);
setUp = paths.setup;
switch nargin
    case 4
    % geometryfile = ([setUp filesep 'femur_r.stl']); % <- OSim stl
    geometryfile = ([setUp filesep 'femur_r.stl']); % <- Segmented stl
    fr     = 100;
    intfms = 100;
    case 7
        if strcmp(side, 'Left')
            % geometryfile = ([setUp filesep 'l_femur.stl']);
            geometryfile = ([setUp filesep 'femur_r.stl']);
            geometryfile(3) = -geometryfile(3);
        elseif strcmp(side, 'Right')
            geometryfile = ([setUp filesep 'femur_r.stl']);
        end
end

% gd = importGeometry(model,geometryfile);
% 
% pdegplot(model,'FaceLabels','on');

%% STL PLOTTING
% change folders to stlTools to read as ascii
% cwd = pwd;
% cd (paths.stlTools); % OR
% Add path to stlTools to read as ascii
addpath(paths.stlTools)
[v, f, n, name] = stlRead(geometryfile);
v   = v .* SF;

f_idx = v(:,2,:) > -0.1;
fem_v = v(f_idx, :);
fem_f = f(f_idx, :);

% Plot stl
% % plot whole femur
% stlPlot(v, f, 'FAI-femur');
% plot femoral head
fig   = axes;
stlPlot(v, f, ''); %camlight('right');
hold on;
% % fit sphere - for methods schematic
% femrad = SF* 0.0235;
% sphere = [0 0 0 femrad];
% h      = drawSphere(sphere, 'nPhi', 100, 'nTheta', 100);
% ylim([-0.05 inf]); view(90, 270); % rotate(fig, direction, 25)
% camlight('right'); view(90, 0)
% axis('off')

% cd (cwd)

%% FORCE PLOTTING
% normalise the force or it gets way too big
% weight = 84.6*-9.81;
l = force;
% plot the force vector on the femur
for i = 1:length(force)
    X = ([0,l(i,1)]); 
    Y = ([0,l(i,2)]); 
    Z = ([0,l(i,3)]);
    plot3(X/10000, Y/10000, Z/10000);
end

% add path to geom3d
addpath(paths.geom3d)

% check distance of point to line and get three closest points to create plane
n = 3;

v1 = [0 0 0];
for k = 1:length(l)
    line        = ([0 0 0 l(k,1) l(k,2) l(k,3)]); % force vector
    v2          = [l(k,1) l(k,2) l(k,3)];         % END of force vector
    % Get distance from vertices to force vector and return index of closest points
    % d is the distance of vertices in order of fem_v
    % idxs is the ordered index where the first index corresponds to the
    % index of the closest distance in d
    [d, idxs]   = getDistance(v1, v2, fem_v);
    % check intersection of vector with triangle formed by points
    sr = [1 2 3; 1 2 4; 1 2 5; 1 2 6; 1 3 4; 1 3 5; 1 3 6; 1 4 5; 1 4 6; 1 5 6];
    for j = 1:size(sr, 1)
        a = idxs(sr(j,:));
        if isnan(intersectLineTriangle3d(line, [[fem_v(a(1),:)] [fem_v(a(2),:)] [fem_v(a(3),:)]]))==0
            % set values
            idxt = a;
        break
        end
    end
    % create a plane from the closest points to force vector
    plane       = createPlane([fem_v(idxt(1),:)], [fem_v(idxt(2),:)], [fem_v(idxt(3),:)]); 
    % determine where force vector intersects with plane
    insect(k,:) = intersectLinePlane(line, plane);
    
    % Plot scatter to check
%     h = figure; hold on; v2n = v2/norm(v2); v2n = v2n/2;
%     scatter3(fem_v(:,1),fem_v(:,2),fem_v(:,3));  % Scatter of matrices
%     plot3([0 v2n(1)], [0 v2n(2)], [0 v2n(3)], 'g'); % Force vector
%     scatter3([fem_v(idxs(1),1)], [fem_v(idxs(1),2)], [fem_v(idxs(1),3)], 'r'); % first closest point
%     scatter3([fem_v(idxs(2),1)], [fem_v(idxs(2),2)], [fem_v(idxs(2),3)], 'r'); % second closest point
%     scatter3([fem_v(idxs(3),1)], [fem_v(idxs(3),2)], [fem_v(idxs(3),3)], 'r'); % third closest point
%     x = ([fem_v(idxs(1),1), fem_v(idxs(2),1), fem_v(idxs(3),1)]);
%     y = ([fem_v(idxs(1),2), fem_v(idxs(2),2), fem_v(idxs(3),2)]);
%     z = ([fem_v(idxs(1),3), fem_v(idxs(2),3), fem_v(idxs(3),3)]);
%     scatter3(insect(k,1),insect(k,2),insect(k,3), 'm', 'x')
%     fill3(x, y, z, 'y'); xlabel('X');  ylabel('Y'); zlabel('Z')
%     close (h)
    
    % check if result lies on line and plane, warn if it doesn't
    % TO DO
    clear d idxs idxt
end
%% Distance and velocity of force path
for c = 2:length(insect)
    p1      = insect(c-1,:);
    p2      = insect(c,:);
    dist(c) = distancePoints3d(p1, p2);
    vel(c)  = dist(c)/(1/100);
end
cumsum(dist);
rmpath(paths.geom3d)

cmap = [1       0       0;       % Red    - Loading
        1       0.5469  0;   	 % Orange - Midstance
        1       1       0;       % Yellow - Terminal stance
        0       1       0;       % Green  - Late stance
        0       0       1];      % Blue   - Swing
        
icmap = zeros(length(insect), 1);
for i = 1:length(phases)
    start = phases(i).start - 100;
    stop = phases(i).stop - 100;
    icmap(start:stop) = i;
end

%cd ('C:\Users\s5001683\Documents\MATLAB\Add-Ons\Toolboxes\stlTools\stlTools');
figure; stlPlot(v, f, 'FAI-femur'); 
ylim([-0.1 inf]); hold on
[x, y] = meshgrid(v(:,1)', v(:,2)');
xlabel('+AP-');  ylabel('V'); zlabel('-ML+');
for p = 1:length(insect)
    %plotColor = cmap(icmap(p),:);
    %plot3(insect(phases(p).start - 100:phases(p).stop - 100,1),insect(phases(p).start - 100:phases(p).stop - 100,2),insect(phases(p).start - 100:phases(p).stop - 100,3), 'Color',plotColor, 'LineWidth', 3);
    plot3(insect(p,1),insect(p,2),insect(p,3), 'Color', cmap(icmap(p),:), 'LineWidth', 3, 'Marker', 'o');
    drawnow
    pause(0.2)
end
%cd (cwd)
ylim([-0.1 inf]);

yi = interpolateData(dist, fr, intfms);
cumsum(yi);
rmpath(paths.stlTools)
