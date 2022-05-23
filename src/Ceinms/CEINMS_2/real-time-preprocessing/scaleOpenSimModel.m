function scaledOsimModel = scaleOpenSimModel(osimModel)
import org.opensim.modeling.*;
if ischar(osimModel)
    osimModel = Model(osimModel);
end
addpath('shared')
fp = getFp();
path = [baseDir fp 'scaling'];
scalingTemplate = ['Template/scaling/ScaleTool.xml'];



end