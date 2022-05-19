function rotm = getrotm(force, paths, side, SF)
% 3rd party functions required...
% STL tools
% Geom3D

% INPUTS
% --------------------------------------
% force - dbl - JCF as n X 3 vector
% paths - str - To required external functions
% side  - stg - side being analysed (Left or Right)
% SF    - dbl - column vector of morphometric scale factors for the segment
% --------------------------------------
% OUTPUTS
% rotm  - -  rotation matrix
% --------------------------------------
% ABOUT ME
% Using the joint contact force data, create a rotation matrix
% T.N.Savage 2020

setUp = paths.setup;

if strcmp(side, 'Left')
    geometryfile = ([setUp filesep 'l_femur.stl']);
    force(:,3)     = -force(:,3);
elseif strcmp(side, 'Right')
    geometryfile = ([setUp filesep 'r_femur.stl']);
end

%% STL PLOTTING
% change folders to stlTools to read as ascii
% cwd = pwd;
% cd (paths.stlTools); % OR
% Add path to stlTools to read as ascii
addpath(paths.stlTools)
[v, f, n, name] = stlReadAscii(geometryfile);
v   = v .* SF; %<- scale

% f_idx = v(:,2,:) > -0.1; %<- get index of vertices where y > -0.1
% fem_v = v(f_idx, :); 
% fem_f = f(f_idx, :);
% 
% % Plot stl
% % % plot whole femur
% % stlPlot(v, f, 'FAI-femur');
% % plot femoral head
% figure(50)
% stlPlot(v, f, 'FAI-femur'); xlabel('X');  ylabel('Y'); zlabel('Z')

% cd (cwd)
%%
nCurves  = length(force);
nFactors = size(force,2);
eulermat = zeros(nCurves, nFactors);
b        = ([1 0 0]);

for i = 1:length(force)
    p = force(i,:);       a = p/norm(p);
    r = vrrotvec(a,b);
    rotm(:,:,i) = vrrotvec2mat(r);
    nwvec(i,:)  = b * rotm(:,:,i);
    % round(nwvec(i,:),4) == round(a,4)
%     % UNCOMMENT TO PLOT
%     % Plot femur
%     % nv = v * rotm(:,:,i); %<- apply rotation matrix to femur
%     figure(50); hold on;
%     stlPlot(v, f,'' ,[1 0 1]);
%     plot3([0 nwvec(i,1)], [0 nwvec(i,2)], [0 nwvec(i,3)]);
%     plot3([0 b(i,1)], [0 b(i,2)], [0 b(i,3)]);
%     plot3([0 a(i,1)], [0 a(i,2)], [0 a(i,3)],'y--');
%     % Labels
%     xlabel('X');  ylabel('Y'); zlabel('Z')
%     ylim([-0.1 0.1]); xlim([-0.1 0.1]); zlim([-0.1 0.1]);
end 
% % output as [ Z   Y   X]  
% eulermat  = [Ry; Rz; Rx]';