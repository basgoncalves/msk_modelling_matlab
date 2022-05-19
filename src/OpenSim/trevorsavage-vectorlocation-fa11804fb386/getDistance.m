function [ds, idx] = getDistance(v1, v2, fem)
% ABOUT ME
% * Creates a tringle between the origin and endpoint of the line 'v' and 
%   the point in the cluster
% * Determines the most obtuse angle between the point and the origin and
%   endpoint of the line
% * Determines the distance of the from the point (fem(j, :)) to the line 
%   (v2 - v1) along the arm
%
% -----------------------------------
% INPUTS
% v1  - 
% v2  - 
% fem - arr

% OUTPUTS
% ds  - dbl - sorted distances from point to line v2-v1
% idx - dbl - index of closest points from point to line
% -----------------------------------

for j = 1:length(fem)
    pt = fem(j, :);
    a  = lineLength (v1, pt);
    b  = lineLength (v2, pt);
    c  = lineLength (v1, v2);
    A  = cosRule(b, c, a, 1);
    B  = cosRule(a, c, b, 1);
    C  = cosRule(a, b, c, 1);
    if C > 90
         d(j)  = distancePointLine3d(pt, [v1, v2]);
    elseif C < 90
        if A > B
        % shortest distance is dep
            d(j) = b;     
        elseif B > A
        % shortest distance is dsp
            d(j) = a;
        end
    elseif C == 90
        d(j) = c;
    end
%     % Plot to check results
%     h = figure; hold on
%     scatter3(fem(:,1),fem(:,2),fem(:,3), 'c');
%     plot3([0 v2(1)], [0 v2(2)], [0 v2(3)], 'g'); % line c, force vector
%     plot3([0 pt(1)], [0 pt(2)], [0 pt(3)], 'r'); % line a, origin - vertice
%     plot3([v2(1) pt(1)], [v2(2) pt(2)], [v2(3) pt(3)], 'm'); % line b, end of force vector to vertice
%     close(h);
end

% get the distances (ds) indexes of the distances (idxs) to the line
[ds, idx] = sort(d);