function [dp, dr, theta] = getLengthPts (avgvec, pintsct, femrad)
% About me
% Returns the Arc or euclidean distance:
% 1) between sequential points (dp)
% 2) between a point on the vector path and the supplied avgvec (dr)
% Returns the included angle between dr(n) and dr(n+1) in RADIANS
%
% Inputs
% ----------------------------------------------
% avgvec  - 
% pintsct - 
% ----------------------------------------------
% Outputs
% ----------------------------------------------
% dp      - dbl - arc distance between points as ROW VECTOR
% dpe     - dbl - euclidean distance between points as ROW VECTOR
% dr      - dbl - arc distance between CoP and point on vector path as ROW VECTOR
% dre     - dbl - euclidean distance between CoP and point on vector path as ROW VECTOR
% theta   - dbl - included angle between dr(n) and dr(n+1) in RADIANS
% ----------------------------------------------

for j = 1:length(pintsct)
    P0       = avgvec;
    P1       = pintsct(j,:);
    if j <= length(pintsct)-1
        P2       = pintsct(j+1,:);
        n1       = (P2 - P0) / norm(P2 - P0); % Normalised vectors
        n2       = (P1 - P0) / norm(P1 - P0);
        % % Included Angle
        theta(j) = atan2(norm(cross(n1, n2)), dot(n1, n2)); % Stable
        % acos(dot((P1 - P0),(P2 - P0))/(norm(P1 - P0)*norm(P2 - P0))) % check
        % % Distance Between adjacent points
        % % Euclidean Distance ...
        % dpe(j)   = sqrt(sum((P1 - P2) .^ 2));  % which is the same as ...
        dpe(j)   = norm(P2 - P1);
        % dist   = distancePoints3d(P1, P2); % check lindist with built-in
        % % Arc Distance
        dp(j)    = femrad * atan2(norm(cross(P1,P2)),dot(P1,P2));
    end
    % % Distance to Centre of Pressure
    % % Euclidean Distance ...
    % dre(j)   = sqrt(sum((P1 - avgvec) .^ 2)); % which is the same as ...
    dre(j)   = norm(P1 - P0);
    % dist(j)= distancePoints3d(P1, rvintsct); % check eucdist with built-in    
    % % Arc Distance ...
    dr(j)    = femrad * atan2(norm(cross(P1,P0)),dot(P1,P0));
end