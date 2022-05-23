% adjustActuatorXML(ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
%  inputs = weights for each coordinate
function adjustActuatorXML(ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)


XML = xml_read(ActuatorFile); % use to change the parameters of the acuator xml
for ii = 1:length(XML.ForceSet.objects.CoordinateActuator)
    if contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'hip')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = hip;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'knee')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = knee;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'ankle')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = ankle;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'lumbar')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = lumbar;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'arm')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = arm;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'elbow')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = elbow;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'pro')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = pro;
    end
end

% define weights for the pelvis 
PelvisWeight = pelvis;

% pelvis forces (Fx,Fy,Fz)
for ii = 1:length(XML.ForceSet.objects.PointActuator)
    if contains(XML.ForceSet.objects.PointActuator(ii).body,'pelvis')
        % optimal force
        XML.ForceSet.objects.PointActuator(ii).optimal_force = PelvisWeight;
        % direction 
        XML.ForceSet.objects.PointActuator(ii).direction = ...
            num2str(XML.ForceSet.objects.PointActuator(ii).direction);
        % axis 
         XML.ForceSet.objects.PointActuator(ii).point = ...
            num2str(XML.ForceSet.objects.PointActuator(ii).point);
    end
end

% pelvis moments (Mx,My,Mz)
for ii = 1:length(XML.ForceSet.objects.TorqueActuator)
   if contains(XML.ForceSet.objects.TorqueActuator(ii).bodyA,'pelvis')
       % optimal force 
       XML.ForceSet.objects.TorqueActuator(ii).optimal_force = PelvisWeight;
       % direction 
       XML.ForceSet.objects.TorqueActuator(ii).direction = ...
            num2str(XML.ForceSet.objects.TorqueActuator(ii).direction);
        % point
        XML.ForceSet.objects.TorqueActuator(ii).axis = ...
            num2str(XML.ForceSet.objects.TorqueActuator(ii).axis);
   end
end

root = 'OpenSimDocument';
xml_write(ActuatorFile, XML,root);
