function plotAvVec(vecDist, paths, lbl, dirPlot, frame, scFac)

q     = vecDist.quat.gaitcyc;
u     = vecDist.mpos.gaitcyc;
side  = {vecDist.metadata.side}.';
setUp = paths.setup;
femrad= 0.023915; %average of osim femrad and osim acerad

fig = figure;
if strcmp(frame, 'Pelvis')
    geometryfile = ([setUp filesep 'Pelvis_r_trans.stl']);
    femrad = femrad - 0.001; % ~* scale factor to appear below surface
elseif strcmp(frame, 'Femur')
    geometryfile = ([setUp filesep 'femur_r.stl']);
    femrad  = femrad * scFac; % * scale factor to appear above surface
end

addpath(paths.stlTools)
[v, f, n, name] = stlRead(geometryfile);

stlPlot(v*scFac, f, lbl); 
ylim([-0.1 inf]); hold on

for i = 1: length(u)
    p(i,:) = femrad * u(i,:);
%     if strcmp(side{i}, 'Left') == 1
%         plot3(p(i,1),p(i,2),-p(i,3), 'LineWidth', 3, 'Marker', 'o');
%     elseif strcmp(side{i}, 'Right') == 1
        plot3(p(i,1),p(i,2),p(i,3), 'LineWidth', 3, 'Marker', 'o');
%     end
end

% Format
if strcmp(frame, 'Pelvis')
    view(0,360); xlabel('+AP- (m)');  ylabel('V (m)'); zlabel('-ML+ (m)')
    camlight('Right');
elseif strcmp(frame, 'Hip')
    view(180,360); xlabel('+AP- (m)');  ylabel('V (m)'); zlabel('-ML+ (m)')
    zlim([-0.02 0.02]) 
end
rmpath(paths.stlTools)
% save
saveas(fig,[dirPlot filesep 'HJCFmeanVecCP_' frame '_' lbl '.png']);
%savefig(fig, [dirPlot filesep 'HJCFvecVariance_' frame '_' lbl '.fig']);