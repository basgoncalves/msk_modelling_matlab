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

% Notes: This file rotates the femoral bone according to the method by Arnold et al
%        - A. S. Arnold, S. S. Blemker, and S. L. Delp, “Evaluation of a deformable musculoskeletal model for estimating muscle–tendon
%           lengths during crouch gait,” Annals of biomedical engineering, vol. 29, no. 3, pp. 263–274, 2001.
%        - A. S. Arnold and S. L. Delp, “Rotational moment arms of the medial hamstrings andadductors vary with femoral geometry and limb
%           position: implications for the treatment of internally rotated gait,” Journal of biomechanics, vol. 34, no. 4, pp. 437–447, 2001.
% inputs: The model, the leg (left or right), Anteversion & neck-shaft angle (FA_angle and NS_angle), the name of the output model, femur vertix and polys
% output: xml file with rotated bone and muscle attachments.
% ------------------------------------------------------------------------
function femur_ns(dataModel, markerset, answerLeg, rightbone, FA_angle, NS_angle,answerNameModelFemur, ...
    answerNameMarkerFemur, dataFemur, place)
%% Bone vertix
% change the vertices into num and find the polys
femur = str2num(dataFemur.VTKFile.PolyData.Piece.Points.DataArray.Text);
polyText = dataFemur.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;

% The muscle attachments for the femur are put in one matrix.
% [femurMuscle, femurPlace1, ] = femur_MA(dataModel, answerLeg);
[~, ~, ~, ~, ~, ~, ~, ~, ~, femurMuscle, femurPlace1, femurNR] = get_muscle_attachments (dataModel, answerLeg);


%Find the markers attached to the femur in OpenSim
[~, ~, ~, ~, markerFemur, markerFemurNR] = OpenSimMarkers(markerset, answerLeg, rightbone);

% The vertices for the bone and muscle attachements 
% are rotated to fit the coordinate system in MATLAB
[femur_start]=coordinatesCorrection(femur);
[femurMuscle_start] = coordinatesCorrection(femurMuscle);
[markerFemur_start] = coordinatesCorrection(markerFemur);

%The new femoral shaft axis is found as well as the inner, middle and our box to prepare for the rotation of the bone
[innerBox, middleBox,innerBoxMA, innerBoxMarker, middleBoxMA, middleBoxMarker,femur_NewAxis, H_transfer,...
    angleZX, angleZY, angleXY,centroidValueLGtroch, femurMA_NewAxis, femurMarker_NewAxis,...
    Condyl_NewAxis, Shaft_proximal, Shaft_distal, CondylMA_NewAxis, ShaftMA_distal,CondylMarker_NewAxis,ShaftMarker_distal] ...
    = femurShaft_ns(dataModel, femur_start, answerLeg, rightbone, femurMuscle_start,markerFemur_start);

%% import and convert the polies for figures 
femurSize = size(femur_start);
polysplit = strsplit(polyText,'\n');
poly3 = [];
for i = 1:size(polysplit,2)
    poly3 = [poly3; str2num(polysplit{1,i})];
end
polys = poly3+1;
%% Rotation; step 1

%  Here we determine where in the bone the vertix or the muslce attachments are and rotate them depending on it create the rotation matix
Ry_NS = [cos(NS_angle) 0 sin(NS_angle); 0 1 0; -sin(NS_angle) 0 cos(NS_angle)];%neck shaft angle 
Rz_FA = [cos(FA_angle) -sin(FA_angle) 0; sin(FA_angle) cos(FA_angle) 0; 0 0 1];%femoral anteversion
RotMatrix =  Rz_FA * Ry_NS;
% The top of the femoral bone (head and greater trochanger) rotated around the femoral shaft axis, when the origin is in the center of the greater/lesser torchanter
femur_rot1_all = []; innerBox_rot1 = []; polys_innerNumber = [];
for i= 1: size(femur_NewAxis)
    if ismember(femur_NewAxis(i,:), innerBox) == 1
        item_innerBox =( RotMatrix * femur_NewAxis(i,:)')';
        femur_rot1_all(i,:) = item_innerBox(:,:);
        innerBox_rot1 = [innerBox_rot1;femur_rot1_all(i,:)];
        polys_innerNumber = [polys_innerNumber; i];
    else
        femur_rot1_all(i,:) = femur_NewAxis(i,:);
    end
end
%zeroMatrix will be the same size as tri3 filled with zeros
zeroMatrix = polys * 0;
%create a matix of ones to know when polys in shaft occur
for ii = 1:size(polys_innerNumber,1)
    zeroMatrix = zeroMatrix + (polys == polys_innerNumber(ii));
end
polys_inner = [];
%sort out triangle that occur in the shaft
for k = 1:size(zeroMatrix,1)
    if sum(zeroMatrix(k,:))==3
        polys_inner = [polys_inner; polys(k,:)]; %polys for the shaft - in the conter clockwise order
    end
end

femurMA_rot1_all = [];
for i= 1: size(femurMA_NewAxis)
    if ismember(femurMA_NewAxis(i,:), innerBoxMA) == 1
        item_innerBoxMA =( RotMatrix * femurMA_NewAxis(i,:)')';
        femurMA_rot1_all(i,:) = item_innerBoxMA(:,:);
    else
        femurMA_rot1_all(i,:) = femurMA_NewAxis(i,:);
    end
end
femurMarker_rot1_all = [];
for i= 1: size(femurMarker_NewAxis)
    if ismember(femurMarker_NewAxis(i,:), innerBoxMarker) == 1
        item_innerBoxMarker =( RotMatrix * femurMarker_NewAxis(i,:)')';
        femurMarker_rot1_all(i,:) = item_innerBoxMarker(:,:);
    else
        femurMarker_rot1_all(i,:) = femurMarker_NewAxis(i,:);
    end
end
innerBox_H_rot = (RotMatrix * H_transfer')';
figure('position', [500, 50, 500, 950]); colormap([1,1,1])
trisurf(polys, femur_rot1_all(:,1), femur_rot1_all(:,2), femur_rot1_all(:,3), 'edgecolor','black','LineStyle',':'); hold on
trisurf(polys, femur_NewAxis(:,1), femur_NewAxis(:,2), femur_NewAxis(:,3), 'edgecolor','black');
axis equal; set(gca,'FontSize',20); view(20,-10); xlabel('x'); ylabel('y'); zlabel('z')
box on % put box around new pair of axes
axis equal; view(30,-10); set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);

%% Rotation: step 2
% Find the highest and lowest value in this part
high_middleBox = max(middleBox(:,3));
low_middleBox = min(middleBox(:,3));
low_value = zeros(1,3);
high_value = zeros(1,3);
for i = 1:size(middleBox,1)
    if middleBox(i,2) <= low_middleBox
        low_value = middleBox(i,:);
    else
        high_value = middleBox(i,:);
    end
end
topmiddlebox = [0,0,high_middleBox];
bottommiddlebox = [0,0,low_middleBox];
middlevector = bottommiddlebox-topmiddlebox;
distanceMiddleBox = norm(middlevector);
polys_middle_Number = [];
femur_rot2_all = []; middleBox_rot2 = []; middleBox_before_rot = [];
for i= 1:size(femur_rot1_all)
    if ismember(femur_rot1_all(i,:), middleBox) == 1
        middleBox_before_rot = [middleBox_before_rot; femur_rot1_all(i,:)];
        a_proj = [femur_rot1_all(i,1) femur_rot1_all(i,2) femur_rot1_all(i,3)] - topmiddlebox;
        projv = dot(a_proj,middlevector)/distanceMiddleBox;
        % The linear twist in the middle part of the bone is created
        scalingRotVectZ = (abs(projv-distanceMiddleBox)/distanceMiddleBox)*FA_angle;
        RotMatrix_rot2 = [cos(scalingRotVectZ) -sin(scalingRotVectZ) 0; sin(scalingRotVectZ) cos(scalingRotVectZ) 0; 0 0 1];
        scalingRotVectY = (abs(projv-distanceMiddleBox)/distanceMiddleBox);
        grad_rot2_middleBox  = RotMatrix_rot2*femur_rot1_all(i,:)';
        femur_rot2_all(i,:) = grad_rot2_middleBox';
        middleBox_rot2 = [middleBox_rot2; grad_rot2_middleBox'];
        polys_middle_Number = [polys_middle_Number; i];
    else
        femur_rot2_all(i,:) = femur_rot1_all(i,:);
    end
end

%create a matix of ones to know when polys in shaft occur
for ii = 1:size(polys_middle_Number,1)
    zeroMatrix = zeroMatrix + (polys == polys_middle_Number(ii));
end
polys_middle = [];
%sort out triangle that occur in the shaft
for k = 1:size(zeroMatrix,1)
    if sum(zeroMatrix(k,:))==3
        polys_middle = [polys_middle; polys(k,:)]; %polys for the shaft - in the conter clockwise order
    end
end
femurMA_rot2_all = []; middleBoxMA_rot2 = []; middleBoxMA_before_rot = [];
for i= 1:size(femurMA_rot1_all)
    if ismember(femurMA_rot1_all(i,:), middleBoxMA) == 1
        middleBoxMA_before_rot = [middleBoxMA_before_rot; femurMA_rot1_all(i,:)];
        a_proj = [femurMA_rot1_all(i,1) femurMA_rot1_all(i,2) femurMA_rot1_all(i,3)] - topmiddlebox;
        projv = dot(a_proj,middlevector)/distanceMiddleBox;
        % The linear twist in the middle part of the bone is created
        scalingRotVectZ = (abs(projv-distanceMiddleBox)/distanceMiddleBox)*FA_angle;
        RotMatrix_rot2 = [cos(scalingRotVectZ) -sin(scalingRotVectZ) 0; sin(scalingRotVectZ) cos(scalingRotVectZ) 0; 0 0 1];
        scalingRotVectY = (abs(projv-distanceMiddleBox)/distanceMiddleBox);
        grad_rot2_middleBoxMA  = RotMatrix_rot2*femurMA_rot1_all(i,:)';
        femurMA_rot2_all(i,:) = grad_rot2_middleBoxMA';
        middleBoxMA_rot2 = [middleBoxMA_rot2; grad_rot2_middleBoxMA'];
    else
        femurMA_rot2_all(i,:) = femurMA_rot1_all(i,:);
    end
end

femurMarker_rot2_all = []; middleBoxMarker_rot2 = []; middleBoxMarker_before_rot = [];
for i= 1:size(femurMarker_rot1_all)
    if ismember(femurMarker_rot1_all(i,:), middleBoxMarker) == 1
        middleBoxMarker_before_rot = [middleBoxMarker_before_rot; femurMarker_rot1_all(i,:)];
        a_proj = [femurMarker_rot1_all(i,1) femurMarker_rot1_all(i,2) femurMarker_rot1_all(i,3)] - topmiddlebox;
        projv = dot(a_proj,middlevector)/distanceMiddleBox;
        % The linear twist in the middle part of the bone is created
scalingRotVectZ = (abs(projv-distanceMiddleBox)/distanceMiddleBox)*FA_angle;
        RotMatrix_rot2 = [cos(scalingRotVectZ) -sin(scalingRotVectZ) 0; sin(scalingRotVectZ) cos(scalingRotVectZ) 0; 0 0 1];
        scalingRotVectY = (abs(projv-distanceMiddleBox)/distanceMiddleBox);
        femurMarker_rot2_all(i,:) = grad_rot2_middleBoxMarker';
        middleBoxMarker_rot2 = [middleBoxMarker_rot2; grad_rot2_middleBoxMarker'];
    else
        femurMarker_rot2_all(i,:) = femurMarker_rot1_all(i,:);
    end
end
% plot the femoral bone as a scatter plot with inner and middle box rotated and twisted.
figure('position', [1000, 50, 500, 950]); colormap([1,1,1]);
trisurf(polys,femur_rot2_all(:,1),femur_rot2_all(:,2),femur_rot2_all(:,3), 'edgecolor','black','LineStyle',':'); hold on
trisurf(polys,femur_NewAxis(:,1),femur_NewAxis(:,2),femur_NewAxis(:,3), 'edgecolor','black');

axis equal; set(gca,'FontSize',20); view(30,-10); grid on; xlabel('x'); ylabel('y'); zlabel('z');

set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', [])
% create a new pair of axes inside current figure
axes('position',[.65 .250 .35 .55])
box on % put box around new pair of axes
trisurf(polys_middle,femur_rot2_all(:,1), femur_rot2_all(:,2), femur_rot2_all(:,3), 'edgecolor','black','LineStyle',':'); hold on
trisurf(polys_middle,femur_NewAxis(:,1), femur_NewAxis(:,2), femur_NewAxis(:,3), 'edgecolor','black'); hold on
trisurf(polys_inner,femur_NewAxis(:,1), femur_NewAxis(:,2), femur_NewAxis(:,3), 'edgecolor','black'); hold on
trisurf(polys_inner,femur_rot2_all(:,1), femur_rot2_all(:,2), femur_rot2_all(:,3), 'edgecolor','black','LineStyle',':'); hold on
axis equal; view(30,-10); set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);

set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);
%% Rotation; Step 3
%MOVE THE FEMORAL HEAD BACK TO FIT CONDYLAR WITHOUT MOVING THE CONDYLAR
%start by transfering the bone back to the H_ZX
transfer_step3 = H_transfer-innerBox_H_rot;

%find the distance between the highest value in the distal shaft to the highese value in the condylar
maxCondyl = max(Condyl_NewAxis(:,3));
condyl_top = zeros(1,3);
for i = 1:size(Condyl_NewAxis,1)
    if Condyl_NewAxis(i,3) >= maxCondyl
        condyl_top = Condyl_NewAxis(i,:);
    end
end

minShaft_prox = min(Shaft_proximal(:,3));
shaft_prox_min = zeros(1,3);
for i = 1:size(Shaft_proximal,1)
    if Shaft_proximal(i,3) <= minShaft_prox
        shaft_prox_min = Shaft_proximal(i,:);
    end
end
distance_shaft_distal = norm( condyl_top- shaft_prox_min);

% 
femur_rot3_all = []; % The outer box is moved back to restore the position of the femoral head to the acetabulum 
femur_rot3_all_deform = []; % the oter box has been restored and the distal part of the femoral shaft is gradually deformed to fit the condylar (which does not move)
for i = 1:size(femur_rot2_all,1)
    if ismember(femur_rot2_all(i,:), Condyl_NewAxis) == 1 % the condylar do not move but the rest is translated restore the femoral head
        femur_rot3_all(i,:) = femur_rot2_all(i,:);
    else
        item_rot3 =femur_rot2_all(i,:) + transfer_step3; %The outer box are transfered back to the postion of the femoral head
        femur_rot3_all(i,:) = item_rot3(:,:);
    end
    if ismember(femur_rot2_all(i,:), Shaft_distal) == 1
        scaler = (abs(norm(femur_rot3_all(i,:)-condyl_top))-distance_shaft_distal)/(distance_shaft_distal) * transfer_step3;
        item_rot3_distal = femur_rot3_all(i,:)+ scaler;
        femur_rot3_all_deform(i,:) = item_rot3_distal(:,:);
    else
        femur_rot3_all_deform(i,:) = femur_rot3_all(i,:);
    end
end
% Treat the muscles attachements in the same way as the bone verticies.
% centroidTroc_rot3 = centroidTroc_rot + transfer_step3;
femurMA_rot3_all = []; femurMA_rot3_all_deform = []; test = [];
for i = 1:size(femurMA_rot2_all,1)
    if ismember(femurMA_rot2_all(i,:), CondylMA_NewAxis) == 1 % the condylar do not move
        femurMA_rot3_all(i,:) = femurMA_rot2_all(i,:);
        test = [test; femurMA_rot2_all(i,:)];
    else
        item_rot3 =femurMA_rot2_all(i,:) + transfer_step3; %The inner and middel box are transfered back to the postion of the femoral head
        femurMA_rot3_all(i,:) = item_rot3(:,:);
    end
    if ismember(femurMA_rot2_all(i,:), ShaftMA_distal) == 1
        scaler = (abs(norm(femurMA_rot3_all(i,:)-condyl_top))-distance_shaft_distal)/(distance_shaft_distal) * transfer_step3;
        item_rot3_distal = femurMA_rot3_all(i,:)+ scaler;
        femurMA_rot3_all_deform(i,:) = item_rot3_distal(:,:);
    else
        femurMA_rot3_all_deform(i,:) = femurMA_rot3_all(i,:);
    end
end
% treat the markers in the same way as the bone verticies
femurMarker_rot3_all = []; femurMarker_rot3_all_deform = [];
for i = 1:size(femurMarker_rot2_all,1)
    if ismember(femurMarker_rot2_all(i,:), CondylMarker_NewAxis) == 1 % the condylar do not move
        femurMarker_rot3_all(i,:) = femurMarker_rot2_all(i,:);
    else
        item_rot3 =femurMarker_rot2_all(i,:) + transfer_step3; %The inner and middel box are transfered back to the postion of the femoral head
        femurMarker_rot3_all(i,:) = item_rot3(:,:);
    end
    if ismember(femurMarker_rot2_all(i,:), ShaftMarker_distal) == 1
        scaler = (abs(norm(femurMarker_rot3_all(i,:)-condyl_top))-distance_shaft_distal)/(distance_shaft_distal) * transfer_step3;
        item_rot3_distal = femurMarker_rot3_all(i,:)+ scaler;
        femurMarker_rot3_all_deform(i,:) = item_rot3_distal(:,:);
    else
        femurMarker_rot3_all_deform(i,:) = femurMarker_rot3_all(i,:);
    end
end

%% Rotate back to the
%the ZX plane
angleZX_back = - angleZX;
angleZY_back = -angleZY;

Rx_FA = [ 1 0 0;0 cos(angleZY_back) -sin(angleZY_back); 0 sin(angleZY_back) cos(angleZY_back)];
if strcmp(answerLeg, rightbone) == 1;
    Ry_FA = [cos(angleZX_back)  0 sin(angleZX_back); 0 1 0; -sin(angleZX_back) 0 cos(angleZX_back)];
else
    Ry_FA = [cos(-angleZX_back)  0 sin(-angleZX_back); 0 1 0; -sin(-angleZX_back) 0 cos(-angleZX_back)];
end

angleXY_back = -angleXY;
if strcmp(answerLeg, rightbone) == 1;
Rz_FA=[cos(angleXY_back) -sin(angleXY_back) 0; sin(angleXY_back) cos(angleXY_back) 0; 0 0 1];
else
  Rz_FA=[cos(-angleXY_back) -sin(-angleXY_back) 0; sin(-angleXY_back) cos(-angleXY_back) 0; 0 0 1];  
end
R_backOpenSim = Rx_FA*Ry_FA*Rz_FA;

femur_rot_back = zeros(size(femur_rot3_all_deform,1),3);
for i = 1:size(femur_rot3_all_deform,1)
    femur_rot_back_item = R_backOpenSim * femur_rot3_all_deform(i,:)';
    femur_rot_back(i,:) = femur_rot_back_item';
end
femurMA_rot_back = zeros(size(femurMA_rot3_all_deform,1),3);
for i = 1:size(femurMA_rot3_all_deform,1)
    femurMA_rot_back_item = R_backOpenSim * femurMA_rot3_all_deform(i,:)';
    femurMA_rot_back(i,:) = femurMA_rot_back_item';
end
femurMarker_rot_back = zeros(size(femurMarker_rot3_all_deform,1),3);
for i = 1:size(femurMarker_rot3_all_deform,1)
    femurMarker_rot_back_item = R_backOpenSim * femurMarker_rot3_all_deform(i,:)';
    femurMarker_rot_back(i,:) = femurMarker_rot_back_item';
end
H_ZY_back = (R_backOpenSim * H_transfer')';
% centroidTroc_ZY_back = (R_backOpenSim *centroidTroc_rot3')';

%%
femur_back = [];
for i = 1:size(femur_rot_back,1)
    femur_back_item = femur_rot_back(i,:)- centroidValueLGtroch;
    femur_back = [femur_back; femur_back_item];
end
H_back = H_ZY_back + centroidValueLGtroch;
% centroidTroc_back = centroidTroc_ZY_back + centroidValueLGtroch;
femurMA_back = [];
for i = 1:size(femurMA_rot_back,1)
    femurMA_back_item = femurMA_rot_back(i,:)- centroidValueLGtroch;
    femurMA_back = [femurMA_back; femurMA_back_item];
end
femurMarker_back = [];
for i = 1:size(femurMarker_rot_back,1)
    femurMarker_back_item = femurMarker_rot_back(i,:)- centroidValueLGtroch;
    femurMarker_back = [femurMarker_back; femurMarker_back_item];
end
femur_Rotated = femur_back;
femurMA_Rotated = femurMA_back;
femurMarker_Rotated = femurMarker_back;

figure('position', [1400, 50, 500, 950])
colormap([1,1,1]);
trisurf(polys,femur_Rotated(:,1),femur_Rotated(:,2), femur_Rotated(:,3), 'edgecolor','black','LineStyle',':'); hold on
trisurf(polys,femur_start(:,1),femur_start(:,2), femur_start(:,3), 'edgecolor','black');

grid on; axis equal; set(gca,'FontSize',20); view(30,-10); xlabel('x'); ylabel('y'); zlabel('z');
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);

%% opensim coordinates
femur_OpenSim = coordinatesOpenSim(femur_Rotated);
femurMuscle_OpenSim = coordinatesOpenSim(femurMA_Rotated);
femurMarker_OpenSim = coordinatesOpenSim(femurMarker_Rotated);

%% export the files again as xml files
% convert the femur data back to string
femur_rotated =sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',femur_OpenSim');
femur_Repared = strrep(femur_rotated,'+',' ');
% replace the generic data with the rotated bone
dataFemur.VTKFile.PolyData.Piece.Points.DataArray.Text = femur_Repared;

% convert the struct back to xml file
Femur_rotated = struct2xml(dataFemur);
%name and placement of the femoral bone file
direct = [];
% export - write the model as an xml  - remember to save as a vtp file
if strcmp(answerLeg, rightbone) == 1;
    modelName = answerNameModelFemur;
    boneName = 'femurR_rotated.vtp';
    c = sprintf('%s_%s' ,modelName,boneName);
    placeNameFemur = sprintf('%s',direct, place, c);
    %write the model as an xml file
    FID_femurR = fopen(placeNameFemur,'w');
    fprintf(FID_femurR,Femur_rotated);
    fclose(FID_femurR);
else
    modelName = answerNameModelFemur;
    boneName = 'femurL_rotated.vtp';
    c = sprintf('%s_%s' ,modelName,boneName);
    placeNameFemur = sprintf('%s',direct, place, c);
    FID_femurL = fopen(placeNameFemur,'w');
    fprintf(FID_femurL,Femur_rotated);
    fclose(FID_femurL);
end

%change the name of the femur in the gait2392 model file
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,2}.attached_geometry...
        .Mesh.mesh_file = c;
else
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,7}.attached_geometry...
        .Mesh.mesh_file = c;
end
for i = 1:size(femurMuscle,1)
    if size(femurPlace1{i,1},2) == 14 ;
        musclenr_femur = femurNR(i,:);
        string_femur = femurPlace1{i,:};
         dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_femur}...
            .GeometryPath.PathPointSet.objects.(string_femur(1:9)){1,str2num(string_femur(13))}.location.Text = femurMuscle_OpenSim(i,:);
    elseif size(femurPlace1{i,1},2) == 9;
        musclenr_femur = femurNR(i,:);
        string_femur = femurPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_femur}...
            .GeometryPath.PathPointSet.objects.(string_femur).location.Text = femurMuscle_OpenSim(i,:);
    elseif size(femurPlace1{i,1},2) == 20;
        musclenr_femur = femurNR(i,:);
        string_femur = femurPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_femur}...
            .GeometryPath.PathPointSet.objects.(string_femur).location.Text = femurMuscle_OpenSim(i,:);
    else
        musclenr_femur = femurNR(i,:);
        string_femur = femurPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_femur}...
            .GeometryPath.PathPointSet.objects.(string_femur(1:20)){1,str2num(string_femur(24))}.location.Text = femurMuscle_OpenSim(i,:);
    end
end
for i = 1:size(markerFemur_start,1)
    musclenr = markerFemurNR(i,:);
    markerset.OpenSimDocument.MarkerSet.objects.Marker{1,musclenr}.location.Text = femurMarker_OpenSim(i,:);
end


%% change the name of the model
type= 'deformed';
modelNamePrint = sprintf('%s_%s' ,modelName,type);
dataModel.OpenSimDocument.Model.Attributes.name = 'deformed_model';%modelNamePrint; 
%% Export the whole gait2392 model file - rotated muscle attachements and correct bone rotataion names
% export the gait2392
Model2392_rotatedfemur = struct2xml(dataModel);
%name and placement of the femoral bone file
placeNameModel = sprintf('%s',direct, place, modelName, '.osim');
%write the model as an xml file
FID_model = fopen(placeNameModel,'w');
fprintf(FID_model,Model2392_rotatedfemur);
fclose(FID_model);

disp(['New model file has been saved in ' placeNameModel])

% export the the marker setup for the scaling tool in opensim
markersetup_rotatedfemur = struct2xml(markerset);
%write the model as an xml file
markersName= answerNameMarkerFemur;
markerNameOut = sprintf('%s_%s' ,modelName,markersName);
%name and placement of the femoral bone file
placeNameMarkers = sprintf('%s', direct, place, markerNameOut);
FID_markers = fopen(placeNameMarkers,'w');
fprintf(FID_markers,markersetup_rotatedfemur);
fclose(FID_markers);
disp(['New marker set has been saved in ' placeNameMarker])

cd ..
