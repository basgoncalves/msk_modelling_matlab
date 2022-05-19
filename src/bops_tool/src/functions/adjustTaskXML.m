
% inputs = weights for each coordinate
function adjustTaskXML(TaskFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)


XML = xml_read(TaskFile); % use to change the parameters of the acuator xml
for ii = 1:length(XML.CMC_TaskSet.objects.CMC_Joint)
    if contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'hip')
        XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = hip;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'knee')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = knee;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'ankle')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = ankle;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'lumbar')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = lumbar;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'arm')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = arm;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'elbow')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = elbow;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'pro')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = pro;
    elseif contains(XML.CMC_TaskSet.objects.CMC_Joint(ii).coordinate,'pelvis')
         XML.CMC_TaskSet.objects.CMC_Joint(ii).weight = pelvis;
    end
    XML.CMC_TaskSet.objects.CMC_Joint(ii).active = ['true ' 'false ' 'false'];
end
root = 'OpenSimDocument';
xml_write(TaskFile, XML,root);

