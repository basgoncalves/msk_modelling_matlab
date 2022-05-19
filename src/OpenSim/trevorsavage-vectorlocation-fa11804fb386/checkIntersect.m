function checkIntersect(pmat, rotm, femrad, paths)

for r = 1:length(rotm)
    rmat(r,:) = [femrad 0 0] * rotm(:, :, r);
end

% change path to geom3d
addpath(paths.geom3d)
figure; 
sphere = [0 0 0 femrad];
h  = drawSphere(sphere); hold on;
set(h, 'linestyle', ':'); set(h, 'facecolor', 'y');
axis equal; alpha 0.3; xlabel('+AP-');  ylabel('V'); zlabel('-ML+')
for p = 1:length(pmat)
    plot3(pmat(p,1),pmat(p,2),pmat(p,3),'ob');
    plot3(rmat(p,1),rmat(p,2),rmat(p,3),'*r');
end