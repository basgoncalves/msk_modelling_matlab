function stlRadius(paths, side, SF)
% GETFORCELOCATION - ABOUT ME
% This script returns the average radius of the input stl
%
% --------------------------------
% -INPUTS-
% force = n x 3 array of force data 
% paths = Paths to stlTools and geom3d as structure with 2 fields as strings 
% SF    = Scale factor of femur, as double
% side  = Side analysed, as string

% -OUTPUTS-

% --------------------------------
%% READ and PLOT STL code
setUp = paths.setup;
if strcmp(side, 'Left')
    geometryfile = ([setUp filesep 'femur_l_2392_FASHIoN study.stl']);
   
l = ([25,  0,  0; ...  X
       0, 25,  0; ...  Y
       0,  0, 25; ...  Z
      25, 25,  0; ...  X Y       
      25,  0, 25; ...  X Z
       0, 25, 25; ...  Y Z
      25, 25, 25; ...  X Y Z
     % other negative 
     -25,  0,  0; ... -X
       0,-25,  0; ... -Y 
     % other sagittal
     -25, 25,  0; ... -X Y
     -25,-25,  0; ... -X-Y
      25,-25,  0; ...  X-Y     
     % other transverse
     -25,  0, 25; ... -X Z
      25,  0,-25; ...  X-Z     
     % other frontal
       0,-25, 25; ... -Y Z     
       0, 25,-25; ...  Y-Z     
     % other on the 45
      25, 25, 25; ... -X Y Z
      25, 25, 25; ... -X-Y Z
      25, 25, 25]); %  X-Y Z            
  
elseif strcmp(side, 'Right')
    geometryfile = ([setUp filesep 'femur_r_2392_FASHIoN study.stl']);
   
l = ([25,  0,  0; ...  X
       0, 25,  0; ...  Y
       0,  0,-25; ...  Z
      25, 25,  0; ...  X Y
      25,  0,-25; ...  X Z
       0, 25,-25; ...  Y Z
      25, 25,-25; ...  X Y Z
     % other negative 
     -25,  0,  0; ... -X
       0,-25,  0; ... -Y 
     % other sagittal
     -25, 25,  0; ... -X Y
     -25,-25,  0; ... -X-Y
      25,-25,  0; ...  X-Y     
     % other transverse
     -25,  0,-25; ... -X Z
      25,  0, 25; ...  X-Z     
     % other frontal
       0,-25,-25; ... -Y Z     
       0, 25, 25; ...  Y-Z     
     % other on the 45
      25, 25,-25; ... -X Y Z
      25, 25,-25; ... -X-Y Z
      25, 25,-25]); %  X-Y Z     ]);
end

%% STL PLOTTING
% change folders to stlTools to read as ascii
% cwd = pwd;
% cd (paths.stlTools); % OR
% Add path to stlTools to read as ascii
addpath(paths.stlTools)
[v, f, n, name] = stlReadAscii(geometryfile);
% Scale v using scale factor
v   = v .* SF;

f_idx = v(:,2,:) > -0.1;
fem_v = v(f_idx, :);
fem_f = f(f_idx, :);

% Plot stl
% % plot whole femur
% stlPlot(v, f, 'FAI-femur');
% plot femoral head
ax = axes;
stlPlot(v, f, 'FAI-femur', 'm');
hold on;
% cd (cwd)

% add path to geom3d
addpath(paths.geom3d)

% check distance of point to line and get three closest points to create plane
v1 = [0 0 0];

for k = 1:length(l)
    line        = ([0 0 0 l(k,1) l(k,2) l(k,3)]); % force vector
    v2          = [l(k,1) l(k,2) l(k,3)];         % END of force vector
    % Get distance from vertices to force vector and return index of closest points
    [d, idxs]   = getDistance(v1, v2, fem_v);
    % check intersection of vector with triangle formed by the 6 closest points
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
    
    clear d idxs idxt
end
%% Distance and velocity of force path
for c = 2:length(insect)
    p1      = insect(c-1,:);
    p2      = insect(c,:);
    dist(c) = distancePoints3d(p1, p2);
end