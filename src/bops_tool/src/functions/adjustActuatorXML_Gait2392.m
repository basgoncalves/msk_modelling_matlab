% adjustActuatorXML_Gait2392(ActuatorFile,hip,knee,ankle,lumbar,mtp,pelvis)
%  inputs = weights for each coordinate
function adjustActuatorXML_Gait2392(ActuatorFile,hip,knee,ankle,lumbar,mtp,pelvis)


XML = xml_read(ActuatorFile);                                                                                       % use to change the parameters of the acuator xml
for ii = 1:length(XML.ForceSet.objects.CoordinateActuator)
    if contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'hip')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = hip;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'knee')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = knee;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'ankle')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = ankle;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'lumbar')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = lumbar;
    elseif contains(XML.ForceSet.objects.CoordinateActuator(ii).coordinate,'mtp')
        XML.ForceSet.objects.CoordinateActuator(ii).optimal_force = mtp;
    end
end

PelvisWeight = pelvis;                                                                                              % define weights for the pelvis 

for ii = 1:length(XML.ForceSet.objects.PointActuator)                                                               % pelvis forces (Fx,Fy,Fz)
    if contains(XML.ForceSet.objects.PointActuator(ii).body,'pelvis')
        XML.ForceSet.objects.PointActuator(ii).optimal_force = PelvisWeight;                                        % optimal force
        
        XML.ForceSet.objects.PointActuator(ii).direction = ...                                                      % direction 
            num2str(XML.ForceSet.objects.PointActuator(ii).direction);
        
         XML.ForceSet.objects.PointActuator(ii).point = ...                                                         % axis 
            num2str(XML.ForceSet.objects.PointActuator(ii).point);
    end
end

for ii = 1:length(XML.ForceSet.objects.TorqueActuator)                                                              % pelvis moments (Mx,My,Mz)
   if contains(XML.ForceSet.objects.TorqueActuator(ii).bodyA,'pelvis')
       % optimal force 
       XML.ForceSet.objects.TorqueActuator(ii).optimal_force = PelvisWeight;
        % point
        XML.ForceSet.objects.TorqueActuator(ii).axis = ...
            num2str(XML.ForceSet.objects.TorqueActuator(ii).axis);
   end
end

XML = ConvertLogicToString(XML,'isDisabled');
XML = ConvertLogicToString(XML,'is_model_control');
XML = ConvertLogicToString(XML,'extrapolate');
XML = ConvertLogicToString(XML,'filter_on');
XML = ConvertLogicToString(XML,'use_steps');
XML = ConvertLogicToString(XML,'point_is_global');
XML = ConvertLogicToString(XML,'force_is_global');
XML = ConvertLogicToString(XML,'torque_is_global');
XML = ConvertLogicToString(XML,'show_axes');
XML = ConvertLogicToString(XML,'point');
XML = ConvertLogicToString(XML,'direction');
XML = ConvertLogicToString(XML,'axis');
XML = ConvertLogicToString(XML,'active');
XML = ConvertLogicToString(XML,'kp');
XML = ConvertLogicToString(XML,'kv');
XML = ConvertLogicToString(XML,'ka');
XML = ConvertLogicToString(XML,'r0');
XML = ConvertLogicToString(XML,'r1');
XML = ConvertLogicToString(XML,'r2');

root = 'OpenSimDocument';
xml_write(ActuatorFile, XML,root);
