function [anglesList] = outputJointAngles(markersList, ground, angles)
%Function to calculate angles between joints in a vicon mocap trial
%   Input marker data, ground value, and cell array containing angles of interest to determine the trunk,
%   shoulder abduction, shoulder forward flexion, and hip flexion angles
%   for the ROM trials. This is for data collected in the load sharing
%   project.

% Create empty structure to store angles info
anglesList = struct();

% Pelvis --- % VICON DATA
try
    % Create Dummy Variables to determine more accurate X Axis
    PelO=(markersList.RASI+markersList.LASI)/2;
    Sac=(markersList.RPSI+markersList.LPSI)/2;
    % Create transformation matrix
    Pelvis_Rot=createSegmentDCMZX(markersList.RASI, markersList.LASI, PelO, Sac);
    for n=1:size(Pelvis_Rot,3)
        Ground(:,:,n)=ground;
    end
    
    
    [PelRot, PelList , PelTilt]=computeISBAngles(Pelvis_Rot,Ground);
    
catch
    disp('Pelvis markers do not exist');
end

% Lumbar ---% VICON DATA
try
    TorsoOrigin=(markersList.CLAV+markersList.T8)/2;
    LowerTorsoOrigin=(PelO+Sac)/2;
    
    % create Transform
    Torso_Rot=createSegmentDCMYX( TorsoOrigin, LowerTorsoOrigin , markersList.CLAV, markersList.T8);
    
    % Torso flexion calculated wrt ground because pelvis is not super reliable
    % in deep trunk flexion.
    [LumbarRotation, LumbarBend, LumbarExtension]=computeISBAngles(Torso_Rot, Ground);
    
catch
    disp('Trunk markers do not exist');
end

if length(angles) == 4
    
    if strncmp(angles{4}, 'RHip', 4)
        % Right Thigh --- % VICON DATA
        try
            % Define the Transform
            RightThigh_Rot=createSegmentDCMYZ( markersList.RASI,markersList.RLFC, markersList.RLFC, markersList.RMFC);
            
            [RHip_Flex , RHip_Add, RHip_Rot]=computeISBAngles(RightThigh_Rot , Pelvis_Rot);
            
            % Right Tibia --- % Vicon
            % Define the rotation matrix
            RightTibia_Rot=createSegmentDCMYZ( markersList.RLFC, markersList.RLMAL, markersList.RLMAL, markersList.RMMAL);
            
            [RKnee_Flex, RKnee_Add, RKnee_Rot]=computeISBAngles(RightTibia_Rot, RightThigh_Rot);
            
            % Right Foot -- % Vicon
            % Use the foot rig - set rcal height to the same as midfoot
            % Set RMT1 X and Y to RMT5
            RMidFoot=(markersList.RMT5+markersList.RMT1)/2;
            VirtRCAL=markersList.RCAL;
            VirtRCAL(2)=RMidFoot(2);
            VirtRMT1=markersList.RMT1;
            VirtRMT1(1)=markersList.RMT5(1); VirtRMT1(2)=markersList.RMT5(2);
            RightFoot_Rot=createSegmentDCMZX(markersList.RMT5, VirtRMT1, RMidFoot, VirtRCAL);
            
            [RFoot_Flex, RFoot_ProSup, RFoot_Rot]=computeISBAngles(RightFoot_Rot, RightTibia_Rot);
        catch me
            disp('A marker is missing from capture, cannot compute hip angles');
        end
        
    else
    end
end

if length(angles) == 2
    
    if strncmp(angles{1}, 'RShld', 5)
        
        % % Left arm -- % Vicon
        % LUAavg=(markersList.LPUA1+markersList.LPUA3)/2;
        % % create Transform
        % LUArm_Rot=createSegmentDCMYX(markersList.LACR1, markersList.LLEP, markersList.LPUA2, LUAavg );
        %
        % [LShld_Flex, LShld_Add, LShld_Rot ]=computeISBAngles(LUArm_Rot, Torso_Rot);
        
        % Right arm -- % Vicon
        try
            RUAavg=(markersList.RPUA1+markersList.RPUA3)/2;
            
            % create Transform
            RUArm_Rot=createSegmentDCMYX(markersList.RACR1, markersList.RLEP, markersList.RPUA2, RUAavg);
            
            [RShld_Flex, RShld_Add, RShld_Rot ]=computeISBAngles(RUArm_Rot, Torso_Rot);
        catch me
            disp('A marker is missing from capture, cannot compute shoulder angles');
        end
    end
end

% Create structure with all angles of interest
% Loop through all angles of interest.
for i = 1:length(angles)
    try
        anglesList.(angles{i}) = eval(angles{i});
    catch
        break
    end
end

end

%% SUPPORTING FUNCTIONS
function [ R ] = createSegmentDCMZX( zPos, zNeg, xPos, xNeg )
% CREATESEGMENTDCMZX Creates 3x3xM DCM using "known Z, temporary X" method
%   R = createSegmentDCMZX(ZPOS,ZNEG,XPOS,XNEG) returns 3-by-3-by-M matrix
%   containing M 3-by-3 orthogonal rotation (direction cosine) matrices
%   (representing anatomical, right-handed, cartesian coordinate system of
%   segment) suitable for input to the MATLAB Aerospace Toolbox function
%   DCM2ANGLE. Function computes segment DCM using "known Z-axis, temporary
%   X-axis" method (see function comments for more info.). All input marker
%   position vectors should have the same dimensions (3-by-1-by-M or
%   1-by-3-by-M) and define location of anatomical marker with respect to
%   global coordinate frame. As far as possible, use virtual joint center
%   and boney landmark markers to define segment frames. When selecting
%   the input marker vectors, do NOT be confused by anatomical terms of
%   location (e.g. medial/lateral). Keep in mind positive axis directions.
%
%   Output 'R' 3-by-3 Matrix Format (using J.J. Craig textbook notation):
%       Frame = sup(glb)sub(seg)R =
%          [sup(glb)Xhatsub(seg) sup(glb)Yhatsub(seg) sup(glb)Zhatsub(seg)]
%       where sup() is superscript, sub() subscript, glb is 'global', seg
%       'segment', 'hat' signifies matrix columns are unit vectors.
%
%   Example Matrix:
%       Rpelvis = sup(glb)sub(pel)R =
%          [sup(glb)Xhatsub(pel) sup(glb)Yhatsub(pel) sup(glb)Zhatsub(pel)]
%
% Example(s): Rpelvis = createSegmentDCMZX(RASI,LASI,PelvisOrigin,SACR);
%             Rrfoot  = createSegmentDCMZX(RMT5,RMT1,RMidfoot,RCAL);
%
% Copyright
%
%   Author(s): Nathan Brantly
%   Affiliation: University of Auckland Bioengineering Institute (ABI)
%   email: nbra708@aucklanduni.ac.nz
%   Advisor: Thor Besier
%   Reference(s): Craig, J.J. (1989). Introduction to Robotics: mechanics
%       and control. Addison-Wesley Publishing Company, Inc., Reading, MA.
%
%   Note: Based on two MATLAB functions: [xyz_rot] =
%       coord_rot(org,dist,prox,med,lat,xyz,f) (J. Rubenson), and
%       [segmentsys] = segmentsystem(P1,P2,P3,P4,order) (James Dunne,
%       Stanford Kinemat Toolbox).
%
%   Current Version: 1.0
%   Change log:
%       - Sat. 05 Sep 2015: Created function from createSegmentFrameMatrix.
%       - Tue. 08 Sep 2015: Generalized function to accept input marker
%                           vectors as 3x1 or 1x3; Created and edited help
%                           lines; Updated function comments.
%       - Wed. 09 Sep 2015: Updated help comments; Re-added normalization
%                           of final axis (X) as testing revealed that a
%                           very small amount of round-off error caused
%                           this final axis to be different from previous
%                           calculations.
%       - Tue. 15 Sep 2015: Updated comments; Added TODO note.

% TODO: Ensure that function is generalized to accept three dimensional
%       arrays (3x1xM or 1x3xM) and return three dimensional matrix of size
%       3x3xM, where M is number of data points (camera frames) to process.
% TODO: Update function to process inputs of Mx3 matrices rather than 3x1
%       or 1x3 vectors. This will namely involve updating the vector
%       normalization procedure followed by reorganizing the R matrix into
%       a 3D array or reorganizing the input matrices up front and
%       operating on 3D arrays.

% Elements of each axis unit vector are direction cosines of vector (i.e.
% cosine of angle between vector and each axis of global coordinate frame).
stackSize= size(zPos,1);
for n=1:stackSize
    % First, define known Z-axis (positive is towards right in OpenSim).
    Z(n,:) = zPos(n,:) - zNeg(n,:);
    Z(n,:) = Z(n,:)/norm(Z(n,:));   % Normalize
    
    % Second, define temporary X-axis to fully characterize XZ plane (positive
    tempX(n,:) = xPos(n,:) - xNeg(n,:);       % is heading direction in OpenSim).
    tempX(n,:) = tempX(n,:)/norm(tempX(n,:)); % Normalize
    
    % Third, find normal vector to XZ plane (i.e. Y-axis, positive is superior
    % in OpenSim) by cross product of Z-axis and temporary X-axis.
    Y(n,:) = cross(Z(n,:),tempX(n,:)); % Y = Z x tempX
    Y(n,:) = Y(n,:)/norm(Y(n,:));      % Normalize
    
    % Fourth and finally, recalculate X-axis by crossing Y-axis and Z-axis to
    X(n,:) = cross(Y(n,:),Z(n,:)); % give perpendicular cartesian coordinate frame, X = Y x Z.
    X(n,:) = X(n,:)/norm(X(n,:));  % Normalize, necessary to avoid any small round-off error
    
    % Create Rotation (Direction Cosine) Matrix
    if ( size(X(n,:),1) == 3 ) % If 3 rows in axes vectors (i.e. column vectors),...
        R(:,:,n) = [ X(n,:)  Y(n,:)  Z(n,:)  ]; % place as the columns of R.
    else                  % Otherwise (i.e. row vectors),...
        R(:,:,n) = [ X(n,:)' Y(n,:)' Z(n,:)' ]; % transpose vectors to compose the columns of R.
    end
    
    
end
end

function [ R ] = createSegmentDCMYZ( yPos, yNeg, zPos, zNeg )
% CREATESEGMENTDCMYZ Creates 3x3xM DCM using "known Y, temporary Z" method
%   R = createSegmentDCMYZ(YPOS,YNEG,ZPOS,ZNEG) returns 3-by-3-by-M matrix
%   containing M 3-by-3 orthogonal rotation (direction cosine) matrices
%   (representing anatomical, right-handed, cartesian coordinate system of
%   segment) suitable for input to the MATLAB Aerospace Toolbox function
%   DCM2ANGLE. Function computes segment DCM using "known Y-axis, temporary
%   Z-axis" method (see function comments for more info.). All input marker
%   position vectors should have the same dimensions (3-by-1-by-M or
%   1-by-3-by-M) and define location of anatomical marker with respect to
%   global coordinate frame. As far as possible, use virtual joint center
%   and boney landmark markers to define segment frames. When selecting
%   the input marker vectors, do NOT be confused by anatomical terms of
%   location (e.g. medial/lateral). Keep in mind positive axis directions.
%
%   Output 'R' 3-by-3 Matrix Format (using J.J. Craig textbook notation):
%       Frame = sup(glb)sub(seg)R =
%          [sup(glb)Xhatsub(seg) sup(glb)Yhatsub(seg) sup(glb)Zhatsub(seg)]
%       where sup() is superscript, sub() subscript, glb is 'global', seg
%       'segment', 'hat' signifies matrix columns are unit vectors.
%
%   Example Matrix:
%       Rrthigh = sup(glb)sub(rth)R =
%          [sup(glb)Xhatsub(rth) sup(glb)Yhatsub(rth) sup(glb)Zhatsub(rth)]
%
% Example(s): Rrthigh   = createSegmentDCMYZ( RHJC, RKJC, RLFC, RMFC );
%             Rrshank   = createSegmentDCMYZ( RKJC, RAJC, RLFC, RMFC );
%             Rrforearm = createSegmentDCMYZ( RMHC, RWRU, RWRR, RWRU );
%             Rrhand    = createSegmentDCMYZ( RWJC, RCAR, RWRR, RWRU );
%
% Copyright
%
%   Author(s): Nathan Brantly
%   Affiliation: University of Auckland Bioengineering Institute (ABI)
%   email: nbra708@aucklanduni.ac.nz
%   Advisor: Thor Besier
%   Reference(s): Craig, J.J. (1989). Introduction to Robotics: mechanics
%       and control. Addison-Wesley Publishing Company, Inc., Reading, MA.
%
%   Note: Based on two MATLAB functions: [xyz_rot] =
%       coord_rot(org,dist,prox,med,lat,xyz,f) (J. Rubenson), and
%       [segmentsys] = segmentsystem(P1,P2,P3,P4,order) (James Dunne,
%       Stanford Kinemat Toolbox).
%
%   Current Version: 1.0
%   Change log:
%       - Sat. 05 Sep 2015: Created function from createSegmentFrameMatrix.
%       - Tue. 08 Sep 2015: Updated in same manner as createSegmentDCMZX.
%       - Wed. 09 Sep 2015: Updated help comments; Re-added normalization
%                           of final axis due to round-off error.

% TODO: Ensure that function is generalized to accept three dimensional
%       arrays (3x1xM or 1x3xM) and return three dimensional matrix of size
%       3x3xM, where M is number of data points (camera frames) to process.
stackSize= size(yPos,1);
% Elements of each axis unit vector are direction cosines of vector (i.e.
% cosine of angle between vector and each axis of global coordinate frame).
for n=1:stackSize
    % First, define known Y-axis (positive is superior in OpenSim).
    Y(n,:) = yPos(n,:) - yNeg(n,:);
    Y(n,:) = Y(n,:)/norm(Y(n,:));   % Normalize
    
    % Second, define temporary Z-axis to fully characterize YZ plane (positive
    tempZ(n,:) = zPos(n,:) - zNeg(n,:);       % is towards right in OpenSim).
    tempZ(n,:) = tempZ(n,:)/norm(tempZ(n,:)); % Normalize
    
    % Third, find normal vector to YZ plane (i.e. X-axis, positive is heading
    % direction in OpenSim) by cross product of Y-axis and temporary Z-axis.
    X(n,:) = cross(Y(n,:),tempZ(n,:)); % X = Y x tempZ
    X(n,:) = X(n,:)/norm(X(n,:));      % Normalize
    
    % Fourth and finally, recalculate Z-axis by crossing X-axis and Y-axis to
    Z(n,:) = cross(X(n,:),Y(n,:)); % give perpendicular cartesian coordinate frame, Z = X x Y.
    Z(n,:) = Z(n,:)/norm(Z(n,:));  % Normalize, necessary very small amount of round-off error
    
    % Create Rotation (Direction Cosine) Matrix
    if ( size(X(n,:),1) == 3 ) % If 3 rows in axes vectors (i.e. column vectors),...
        R(:,:,n) = [ X(n,:)  Y(n,:)  Z(n,:)  ]; % place as columns of R.
    else                  % Otherwise (i.e. row vectors),...
        R(:,:,n) = [ X(n,:)' Y(n,:)' Z(n,:)' ]; % transpose vectors to compose the columns of R.
    end
    
end
end

function [ R ] = createSegmentDCMYX( yPos, yNeg, xPos, xNeg )
% CREATESEGMENTDCMYX Creates 3x3xM DCM using "known Y, temporary X" method
%   R = createSegmentDCMYX(YPOS,YNEG,XPOS,XNEG) returns 3-by-3-by-M matrix
%   containing M 3-by-3 orthogonal rotation (direction cosine) matrices
%   (representing anatomical, right-handed, cartesian coordinate system of
%   segment) suitable for input to the MATLAB Aerospace Toolbox function
%   DCM2ANGLE. Function computes segment DCM using "known Y-axis, temporary
%   X-axis" method (see function comments for more info.). All input marker
%   position vectors should have the same dimensions (3-by-1-by-M or
%   1-by-3-by-M) and define location of anatomical marker with respect to
%   global coordinate frame. As far as possible, use virtual joint center
%   and boney landmark markers to define segment frames. When selecting
%   the input marker vectors, do NOT be confused by anatomical terms of
%   location (e.g. medial/lateral). Keep in mind positive axis directions.
%
%   Output 'R' 3-by-3 Matrix Format (using J.J. Craig textbook notation):
%       Frame = sup(glb)sub(seg)R =
%          [sup(glb)Xhatsub(seg) sup(glb)Yhatsub(seg) sup(glb)Zhatsub(seg)]
%       where sup() is superscript, sub() subscript, glb is 'global', seg
%       'segment', 'hat' signifies matrix columns are unit vectors.
%
%   Example Matrix:
%       Rtorso = sup(glb)sub(tor)R =
%          [sup(glb)Xhatsub(tor) sup(glb)Yhatsub(tor) sup(glb)Zhatsub(tor)]
%
% Example(s): Rtorso = createSegmentDCMYX( C7, T10, CLAV, C7 );
%
% Copyright
%
%   Author(s): Nathan Brantly
%   Affiliation: University of Auckland Bioengineering Institute (ABI)
%   email: nbra708@aucklanduni.ac.nz
%   Advisor: Thor Besier
%   Reference(s): Craig, J.J. (1989). Introduction to Robotics: mechanics
%       and control. Addison-Wesley Publishing Company, Inc., Reading, MA.
%
%   Note: Based on two MATLAB functions: [xyz_rot] =
%       coord_rot(org,dist,prox,med,lat,xyz,f) (J. Rubenson), and
%       [segmentsys] = segmentsystem(P1,P2,P3,P4,order) (James Dunne,
%       Stanford Kinemat Toolbox).
%
%   Current Version: 1.0
%   Change log:
%       - Sun. 06 Sep 2015: Created function from createSegmentFrameMatrix.
%       - Tue. 08 Sep 2015: Updated in same manner as createSegmentDCMZX.
%       - Wed. 09 Sep 2015: Updated help comments; Re-added normalization
%                           of final axis due to round-off error.

% TODO: Ensure that function is generalized to accept three dimensional
%       arrays (3x1xM or 1x3xM) and return three dimensional matrix of size
%       3x3xM, where M is number of data points (camera frames) to process.

stackSize= size(yPos,1);
% Elements of each axis unit vector are direction cosines of vector (i.e.
% cosine of angle between vector and each axis of global coordinate frame).
for n=1:stackSize
    % First, define known Y-axis (positive is superior in OpenSim).
    Y(n,:) = yPos(n,:) - yNeg(n,:);
    Y(n,:) = Y(n,:)/norm(Y(n,:));   % Normalize
    
    % Second, define temporary X-axis to fully characterize XY plane (positive
    tempX(n,:) = xPos(n,:) - xNeg(n,:);       % is heading direction in OpenSim).
    tempX(n,:)= tempX(n,:)/norm(tempX(n,:)); % Normalize
    
    % Third, find normal vector to XY plane (i.e. Z-axis, positive is towards
    % right in OpenSim) by cross product of temporary X-axis and Y-axis.
    Z(n,:) = cross(tempX(n,:),Y(n,:)); % Z = tempX x Y
    Z(n,:) = Z(n,:)/norm(Z(n,:));      % Normalize
    
    % Fourth and finally, recalculate X-axis by crossing Y-axis and Z-axis to
    X(n,:) = cross(Y(n,:),Z(n,:)); % give perpendicular cartesian coordinate frame, X = Y x Z.
    X(n,:) = X(n,:)/norm(X(n,:));  % Normalize, necessary to avoid any small round-off error.
    
    % Create Rotation (Direction Cosine) Matrix
    if ( size(X(n,:),1) == 3 ) % If 3 rows in axes vectors (i.e. column vectors),...
        R(:,:,n) = [ X(n,:)  Y(n,:)  Z(n,:)  ]; % place as columns of R.
    else                  % Otherwise (i.e. row vectors),...
        R(:,:,n) = [ X(n,:)' Y(n,:)' Z(n,:)' ]; % transpose vectors to compose the columns of R.
    end
end

end

function [flex, add, int] = computeISBAngles(child, parent)


sizeOfStack = size(child,3);
c = zeros(3,3,sizeOfStack);
flex = zeros(sizeOfStack,1);
add = zeros(sizeOfStack,1);
int = zeros(sizeOfStack,1);

for n = 1:sizeOfStack
    c(:,:,n) = parent(:,:,n)*child(:,:,n)';
    
    % see ..\documentation\EulerAngles.pdf, page 8, section 2.5. Be careful, indexing in Matlab does not start at 0.
    
    if c(3,2,n) < 1
        if c(3,2,n) > -1
            int(n) = atan2d(-c(1,2,n), c(2,2,n)); % theta Z
            flex(n) = asind(c(3,2,n)); % theta X
            add(n) = atan2d(-c(3,1,n), c(3,3,n)); % theta Y
        else % c(3,2) = -1
            int(n) = -atan2d(c(1,2,n), c(1,1,n));
            flex(n) = rad2deg(-pi/2);
            add(n) = 0;
        end
    else % c32 = +1
        int(n) = atan2d(c(1,3,n), c(1,1,n));
        flex(n) = rad2deg(pi/2);
        add(n) = 0;
    end
end
end
