% This function modifies the distal attachment points of 
% soleus, medial and lateral grastrocnemius so that the model's moment
% arm for the Achilles tendon corresponds to the experimental data
function [tunedOpenSimFilename] = tuneAchillesTendonMomentArm(osimModel, momentArmsAtZero, baseDir)
import org.opensim.modeling.*;
if ischar(osimModel)
    osimModel = Model(osimModel);
end
addpath('shared')
fp = getFp();
path = [baseDir fp 'scaling'];
muscleNames = {'lat_gas_r','med_gas_r','soleus_r'};
for i = 1:length(muscleNames)
    muscleName = muscleNames{i};
    mtu = osimModel.getMuscles().get(muscleName);
    x0 = getMomentArm(osimModel, mtu, 0);
    xLoc = fmincon(@(x) fun(osimModel,mtu,-momentArmsAtZero,x),x0);
    loc = getAttachmentPoint(mtu);
    loc.set(0,xLoc);
    setAttachmentPoint(mtu, loc);
end
tunedOpenSimFilename = join([path fp char(osimModel.getName()) "_optAT.osim"],'');
osimModel.print(tunedOpenSimFilename);
end

function err = fun(osimModel, mtu, expMa, x) 
loc = getAttachmentPoint(mtu);
loc.set(0, x);
setAttachmentPoint(mtu, loc);
ma = getMomentArm(osimModel, mtu, 0);
err = (ma - expMa)^2;
end

function ma = getMomentArm(osimModel, mtu, coordValue)
s = osimModel.initSystem();
coord = osimModel.getCoordinateSet().get('ankle_angle_r');
coord.setValue(s, coordValue);
ma = mtu.computeMomentArm(s, coord);
end

function loc = getAttachmentPoint(mtu)
pps = mtu.getGeometryPath().getPathPointSet();
n = pps.getSize();
loc =pps.get(n-1).getLocation();
end

function [] = setAttachmentPoint(mtu, loc)
pps = mtu.getGeometryPath().getPathPointSet();
n = pps.getSize();
s = mtu.getModel().initSystem();
pps.get(n-1).setLocation(s, loc);
end