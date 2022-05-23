

function ActNames = getModelActuators(model_file)

OSIM = xml_read(model_file);
% get actuator names in OSIM model
Nact = length(OSIM.Model.ForceSet.objects.CoordinateActuator);
ActNames = {};

for k = 1:Nact
   ActNames{k} = OSIM.Model.ForceSet.objects.CoordinateActuator(k).ATTRIBUTE.name;
   Coordinates{k} = 
end