function transformedvec = transformRefFrame(modelPath, forcePath, IKPath, Side, frame)
% TRANSFORMEDVEC - ABOUT ME
% --------------------------------
% CEINMS outputs contact forces in the global co-ordinate frame
% This function uses the simbody engine to tranform a joint contact force
% in the global frame to a segment frame, currently set to hip but can be
% modified to any joint by modifying the target in the "get body" section
% -INPUTS-
% modelPath - stg - Path to .osim model, either scaled for subject or generic
% forcePath - stg - Path to CNMS contact force sto, as string
% IKPath    - stg - Path to OSim IK mot, as string
% Side      - stg - Side analysed, as string
% Frame     - stg - Frame to convert into

% -OUTPUTS-
% transformedvec = vector in target reference frame
% --------------------------------
%%
forcedata = importdata(forcePath);
IKdata    = importdata(IKPath);
% import OSIM library
import org.opensim.modeling.*;
% get model and save state
model     = Model(modelPath); 
% model.setUseVisualizer(true); %<-- open osim visualiser window
state     = model.initSystem();
% not sure what this does... not used
mss       = model.getMatterSubsystem();
% accesses simbody engine api
se        = model.updSimbodyEngine();
% get ground
groundBody = model.getGroundBody();
% get body
if strcmp (Side, 'Right') == 1
    side = 'r';
elseif strcmp(Side, 'Left') == 1
    side = 'l';
end
% get force data
lbs_jcf     = {['hip_' side '_x'], ['hip_' side '_y'], ['hip_' side '_z']};
jcf_side    = getHipSide(forcedata.colheaders, lbs_jcf); % hip_side    = [8 9 10];

if strcmp(frame, 'Pelvis')
    lbs_hipDOFS = {'pelvis_tilt'; 'pelvis_list'; 'pelvis_rotation'};
    hip_side    = getHipSide(IKdata.colheaders, lbs_hipDOFS); % hip_side    = [8 9 10];
    femurBody   = model.getBodySet().get('pelvis');    
elseif strcmp (frame, 'Femur') == 1
    lbs_hipDOFS = {['hip_flexion_' side]; ['hip_adduction_' side]; ['hip_rotation_' side]};
    hip_side    = getHipSide(IKdata.colheaders, lbs_hipDOFS); % hip_side    = [8 9 10];
    femurBody   = model.getBodySet().get(['femur_' side]);
end
transformedvec = zeros(length(forcedata.data),4);
transformedvec(:,1) = forcedata.data(:,1);
for i = 1:length(forcedata.data)
    result = Vec3(0,0,0); %result = ~[0,0,0]
    fx = forcedata.data(i,jcf_side(1)); fy = forcedata.data(i,jcf_side(2)); fz = forcedata.data(i,jcf_side(3));
    force  = Vec3(fx,fy,fz);
    %force = ~[0,1,2]
    hipFlexionCoord = model.updCoordinateSet().get(lbs_hipDOFS{1});
    hip_ik_x = (IKdata.data(i,(hip_side(1)))*(pi/180)); hipFlexionCoord.setValue(state, hip_ik_x);
    hipAddCoord = model.updCoordinateSet().get(lbs_hipDOFS{2});
    hip_ik_y = (IKdata.data(i,(hip_side(2)))*(pi/180)); hipAddCoord.setValue(state, hip_ik_y);
    hipRotCoord = model.updCoordinateSet().get(lbs_hipDOFS{3});
    hip_ik_z = (IKdata.data(i,(hip_side(3)))*(pi/180)); hipRotCoord.setValue(state, hip_ik_z);
    % model.getVisualizer().show(state) % <-- uncomment to run visualiser
    % transform (const SimTK::State &s, const OpenSim::Body &aBodyFrom, const SimTK::Vec3 &aVec, const OpenSim::Body &aBodyTo, SimTK::Vec3 &rVec) const
    se.transform(state, groundBody, force, femurBody, result);
    %create a matrix to hold the vector output
    transformedvec(i,2) = result.get(0);
    transformedvec(i,3) = result.get(1);
    transformedvec(i,4) = result.get(2);% result = ~[1,0,2]
end
forcedata.data = transformedvec;
transformedvec = forcedata;

% nested functions
function [idx_out] = getHipSide(colheaders, DOFS)
% hipDOFS = {'hip_flexion_'; 'hip_adduction_'; 'hip_rotation_'};
for j = 1:length(DOFS)
    str = ([DOFS{j}]);
    for k = 1:length(colheaders)
        if strcmp(colheaders{k}, str) == 1
            idx_out(j) = k;
        end
    end
end