
function [mass_original_model,mass_model_to_adjust,mass_out_model,body_names] = restoreOriginalMass(Path_original_model,Path_model_to_adjust, Path_output_model)


import org.opensim.modeling.*

filepath    = Path_original_model;
fileadjustpath  = Path_model_to_adjust;
fileoutpath = Path_output_model;

% Create original OpenSim model for the Modified Model
Model_original = Model(filepath);
Model_original.initSystem;

%Create the OpenSim model to adjust from a .osim file
Model_adjusted = Model(fileadjustpath);
Model_adjusted.initSystem;

% Create a copy of the OpenSim model to adjust for the Modified Model
Model_out = Model(Model_adjusted);
Model_out.initSystem;
[~,filename] = fileparts(Path_output_model);
Model_out.setName(filename); % Rename the modified Model so that it comes up with a different name in the GUI navigator

% Get the set of bodies that are in the original model
Bodies_original = Model_original.getBodySet();
Bodies_adjusted = Model_adjusted.getBodySet();
Bodies_out = Model_out.getBodySet();

nBodies = Bodies_original.getSize(); %Count the bodies

body_names ={};
mass_original_model = [];
mass_model_to_adjust = [];
mass_out_model = [];
% loop through bodies and scale body mass accordingly (index starts at 0)
for i = 0:nBodies-1
    % row in matlab starts at 1 while opensim bodies start at 0
    row = i+1;
    
    %get the body that the original body set points to read body type and the body mass
    currentBody = Bodies_original.get(i);
    body_names(row,1) = currentBody.getName;
    mass_original_model(row,1) = currentBody.getMass;
    
    adjustedBody = Bodies_adjusted.get(i);
    mass_model_to_adjust(row,1) = adjustedBody.getMass;
    
    
    %define the body in the modified model for changing
    outBody = Bodies_out.get(i);
    outBody.setMass(mass_original_model(row,1));
    mass_out_model(row,1) = outBody.getMass;
end

Model_out.print(fileoutpath);
disp(['The new model has been saved at ' fileoutpath]);

end

