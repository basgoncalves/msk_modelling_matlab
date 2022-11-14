%-------------------------------------------------------------------------%
% Copyright (c) 2021 % Kirsten Veerkamp, Hans Kainz, Bryce A. Killen,     %
%    Hulda Jónasdóttir, Marjolein M. van der Krogt      		          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Authors: Hulda Jónasdóttir & Kirsten Veerkamp                        %
%                            February 2021                                %
%    email:    k.veerkamp@amsterdamumc.nl                                 % 
% ----------------------------------------------------------------------- %
% Rotating the location of the bone parts: toes, calcn and talus          
% ----------------------------------------------------------------------- %

function [dataModel, talus_old_start, calcn_old_start, toes_old_start, locationTalusRot_start, locationCalcnRot_start, ...
    locationToesRot_start]=tibia_locationInParent_rotation(dataModel, TT_angle, answerLeg, rightbone)
% the rotation matrix
Rz_TT = [cos(TT_angle) -sin(TT_angle) 0; sin(TT_angle) cos(TT_angle) 0; 0 0 1];
% Save the original joint location
if strcmp(answerLeg, rightbone) == 1;
    talus_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,4}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.Joint.CustomJoint.location_in_parent.Text);
    calcn_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,5}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,6}.Joint.CustomJoint.location_in_parent.Text);
    toes_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,6}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,7}.Joint.CustomJoint.location_in_parent.Text);
else
    talus_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,9}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.Joint.CustomJoint.location_in_parent.Text);
    calcn_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,10}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,6}.Joint.CustomJoint.location_in_parent.Text);
    toes_old = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,11}.frames.PhysicalOffsetFrame{1,1}.translation.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,7}.Joint.CustomJoint.location_in_parent.Text);
end
% The vertices for the bone are rotated to fit the coordinate system in MATLAB
[talus_old_start] = coordinatesCorrection(talus_old);
[calcn_old_start] = coordinatesCorrection(calcn_old);
[toes_old_start] = coordinatesCorrection(toes_old);

%% ankle joint -- body: talus parent: tibia
%Rotate the location 
locationTalusRot_start = (Rz_TT * talus_old_start')';
% convert the location to OpenSim coordinates before putting in the model again
[locationTalusRot]=coordinatesOpenSim(locationTalusRot_start);
%print the rotated location back to the model
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,4}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationTalusRot);
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,9}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationTalusRot);
end
%Find the joint axis
if strcmp(answerLeg, rightbone) == 1;
    Axis_Ankle = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 4}.SpatialTransform.TransformAxis{1, 1}.axis.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.Joint.CustomJoint.SpatialTransform.TransformAxis{1,1}.axis.Text);
else
    Axis_Ankle = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 9}.SpatialTransform.TransformAxis{1, 1}.axis.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,10}.Joint.CustomJoint.SpatialTransform.TransformAxis{1,1}.axis.Text);
end
% convert the the joint axis to the matlab coordinate system
[Axis_Ankle_start]=coordinatesCorrection(Axis_Ankle);
%translate the location of the ankle axis to the tibia coordinates
Axis_Ankle_translate = Axis_Ankle_start + talus_old_start;
% rotate the ankle axis around the tibia coordinates
Axis_Ankle_rot = (Rz_TT * Axis_Ankle_translate')';
% translate back to its original location
Axis_Ankle_rot_trans_start = Axis_Ankle_rot - talus_old_start;
%convert the joint axis back to Opensim coordinate before putting it to matlab
[Axis_Ankle_rot_trans]=coordinatesOpenSim(Axis_Ankle_rot_trans_start);
%Print the rotated axis into the model
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 4}.SpatialTransform.TransformAxis{1, 1}.axis.Text = num2str(Axis_Ankle_rot_trans);
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 9}.SpatialTransform.TransformAxis{1, 1}.axis.Text = num2str(Axis_Ankle_rot_trans);
end

%% subtalar joint parent talus
%Rotate the location of the joint around the tibia axis
locationCalcnRot_start = (Rz_TT * calcn_old_start')';
% convert the location to OpenSim coordinates before putting in the model again
[locationCalcn_transform]=coordinatesOpenSim(locationCalcnRot_start);
%print the rotated location of the joint into the model
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,5}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationCalcn_transform);
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,10}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationCalcn_transform);
end
%Location of the calcn axis
if strcmp(answerLeg, rightbone) == 1;
    Calcn_subtalar = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 5}.SpatialTransform.TransformAxis{1, 1}.axis.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,6}.Joint.CustomJoint.SpatialTransform.TransformAxis{1,1}.axis.Text);
else
    Calcn_subtalar = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 10}.SpatialTransform.TransformAxis{1, 1}.axis.Text);%str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,11}.Joint.CustomJoint.SpatialTransform.TransformAxis{1,1}.axis.Text);
end
% convert the the joint axis to the matlab coordinate system
[Calcn_subtalar_start]=coordinatesCorrection(Calcn_subtalar);
%translate it to the tibia coordinate system
Calcn_subtalar_translate = Calcn_subtalar_start + talus_old_start + calcn_old_start;
%rotate the axis around the tibia coordinate system
Calcn_subtalar_rot = (Rz_TT * Calcn_subtalar_translate')';
%translate it back to the original coordinate system
Calcn_subtalar_rot_trans_start = Calcn_subtalar_rot - talus_old_start - calcn_old_start;
%convert the joint axis back to Opensim coordinate before putting it to matlab
[Calcn_subtalar_rot_trans]=coordinatesOpenSim(Calcn_subtalar_rot_trans_start);
%print it back into the model
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 5}.SpatialTransform.TransformAxis{1, 1}.axis.Text = num2str(Calcn_subtalar_rot_trans);
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 10}.SpatialTransform.TransformAxis{1, 1}.axis.Text =num2str(Calcn_subtalar_rot_trans);
end

%% mtp joint parent: calcn
% Rotate the location of the foot
locationToesRot_start = (Rz_TT * toes_old_start')'; %locationToes_translate')';
% convert the location to OpenSim coordinates before putting in the model again
[locationToes_transform]=coordinatesOpenSim(locationToesRot_start);
% Print the rotated location back into the model
if strcmp(answerLeg, rightbone) == 1;
   dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,6}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationToes_transform);  
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,11}.frames.PhysicalOffsetFrame{1,1}.translation.Text = num2str(locationToes_transform);
end

% rotate the axis
% the location of the axis
if strcmp(answerLeg, rightbone) == 1;
    toes_mtp =str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 6}.SpatialTransform.TransformAxis{1, 1}.axis.Text);
else
    toes_mtp =str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 11}.SpatialTransform.TransformAxis{1, 1}.axis.Text);
end
% convert the the joint axis to the matlab coordinate system
[toes_mtp_start]=coordinatesCorrection(toes_mtp);
%translate it to the tibia coordinate system 
toes_mtp_translate = toes_mtp_start+ talus_old_start + calcn_old_start + toes_old_start;
% rotated the axis
toes_mtp_rot = (Rz_TT *toes_mtp_translate')';
% translate it back to the original coordinate system 
toes_mtp_rot_trans_start = toes_mtp_rot- talus_old_start -calcn_old_start - toes_old_start;
%convert the joint axis back to Opensim coordinate before putting it to matlab
[toes_mtp_rot_trans]=coordinatesOpenSim(toes_mtp_rot_trans_start);
%print the rotated axis back into the model.
if strcmp(answerLeg, rightbone) == 1;
   dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 6}.SpatialTransform.TransformAxis{1, 1}.axis.Text = num2str(toes_mtp_rot_trans);
else
    dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1, 11}.SpatialTransform.TransformAxis{1, 1}.axis.Text = num2str(toes_mtp_rot_trans);
end
disp('Location in parent and joint axis have been rotated')