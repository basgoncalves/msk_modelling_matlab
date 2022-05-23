%-------------------------------------------------------------------------%
% Copyright (c) 2021 % Kirsten Veerkamp, Hans Kainz, Bryce A. Killen,     %
%    Hulda J�nasd�ttir, Marjolein M. van der Krogt      		          %
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
%    Authors: Hulda J�nasd�ttir & Kirsten Veerkamp                        %
%                            February 2021                                %
%    email:    k.veerkamp@amsterdamumc.nl                                 % 
% ----------------------------------------------------------------------- %
% Notes: The tibia is rotated in two parts. 
%   1) distal third rotated by the entire angle with the talus, calcn and toes.
%   2) The middle part, distal to the soleus attachment continuing to the distal third of the tibia is rotated gradually as a function of superior-inferior distance. 
% inputs: The model, Torsion angle (TT_angle), tibia vertix, tiba polys, tibia muscle attachments
% output: xml file with rotated bone/bones and muscle attachments
% ----------------------------------------------------------------------
function     tibia(dataModel, markerset, answerLeg, rightbone, TT_angle, answerNameModelTibia,...
    answerNameMarkerTibia, dataTibia, dataCalcn, dataTalus, dataToes, place)
%% Find the muscle attachment on the tibia, calcn, talus and toes and place in a matrix
[TibiaMuscles, TibiaPlace1, TibiaNR, CalcnMuscles, CalcnPlace1, CalcnNR, ToesMuscles, ToesPlace1, ToesNR ] = tibia_MA(dataModel, answerLeg, rightbone);
% The vertices for the bone are rotated to fit the coordinate system in MATLAB
[TibiaMuscles_start] = coordinatesCorrection(TibiaMuscles);
[CalcnMuscles_start] = coordinatesCorrection(CalcnMuscles);
[ToesMuscles_start] = coordinatesCorrection(ToesMuscles);
%  Prepare the data needed
if strcmp(answerLeg, rightbone) == 1;
    calcn_NUM = str2num(dataCalcn.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Calcn = dataCalcn.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    talus_NUM = str2num(dataTalus.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Talus = dataTalus.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    toes_NUM = str2num(dataToes.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Toes = dataToes.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    tibia_NUM = str2num(dataTibia.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Tibia = dataTibia.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
else
    calcn_NUM = str2num(dataCalcn.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Calcn = dataCalcn.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    talus_NUM = str2num(dataTalus.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Talus = dataTalus.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    toes_NUM = str2num(dataToes.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Toes = dataToes.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
    tibia_NUM = str2num(dataTibia.VTKFile.PolyData.Piece.Points.DataArray.Text);
    polyText_Tibia = dataTibia.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
end
% The vertices for the bone are rotated to fit the coordinate system in MATLAB
[Tibia_start] = coordinatesCorrection(tibia_NUM);
[Talus_start] = coordinatesCorrection(talus_NUM);
[Calcn_start] = coordinatesCorrection(calcn_NUM);
[Toes_start] = coordinatesCorrection(toes_NUM);

%Find the markers attach to the tibia and calcn and convert to MATLAB %coordinate system
[markerCalcn, markerTibia, markerCalcnNR, markerTibiaNR, ~, ~] = OpenSimMarkers(markerset, answerLeg, rightbone);
[markerTibia_start] = coordinatesCorrection(markerTibia);
[markerCalcn_start] = coordinatesCorrection(markerCalcn);

% prepare the polys in the correct format for ploting the bones
% Divide the text where new line occurs
polysplit_talus = strsplit(polyText_Talus,'\n');
polysplit_calcn = strsplit(polyText_Calcn,'\n');
polysplit_toes = strsplit(polyText_Toes,'\n');
polysplit_tibia = strsplit(polyText_Tibia,'\n');
% Divided into two matrixes depending on items in a line (3 or 4)
poly3_talus = []; poly4_talus = [];
for i = 1:size(polysplit_talus,2)
    if size(str2num(polysplit_talus{1,i}),2) == 3
        poly3_talus = [poly3_talus; str2num(polysplit_talus{1,i})];
    else
        poly4_talus = [poly4_talus; str2num(polysplit_talus{1,i})];
    end
end
poly3_calcn = []; poly4_calcn = [];
for i = 1:size(polysplit_calcn,2)
    if size(str2num(polysplit_calcn{1,i}),2) == 3
        poly3_calcn = [poly3_calcn; str2num(polysplit_calcn{1,i})];
    else
        poly4_calcn = [poly4_calcn; str2num(polysplit_calcn{1,i})];
    end
end
poly3_toes = []; poly4_toes = [];
for i = 1:size(polysplit_toes,2)
    if size(str2num(polysplit_toes{1,i}),2) == 3
        poly3_toes = [poly3_toes; str2num(polysplit_toes{1,i})];
    else
        poly4_toes = [poly4_toes; str2num(polysplit_toes{1,i})];
    end
end
poly3_tibia = []; poly4_tibia = [];
for i = 1:size(polysplit_tibia,2)
    if size(str2num(polysplit_tibia{1,i}),2) == 3
        poly3_tibia = [poly3_tibia; str2num(polysplit_tibia{1,i})];
    else
        poly4_tibia = [poly4_tibia; str2num(polysplit_tibia{1,i})];
    end
end
% add one to each item so the polys start from 1 not 0.
tri3_talus = poly3_talus+1; tri4_talus = poly4_talus+1;
tri3_calcn = poly3_calcn+1; tri4_calcn = poly4_calcn+1;
tri3_toes = poly3_toes+1; tri4_toes = poly4_toes+1;
tri3_tibia = poly3_tibia+1; tri4_tibia = poly4_tibia+1;

%% Rotating the location of the bone parts: toes, calcn and talus
[dataModel, talus_old_start, calcn_old_start, toes_old_start, locationTalusRot_start, locationCalcnRot_start, ...
    locationToesRot_start]=tibia_locationInParent_rotation(dataModel, TT_angle, answerLeg, rightbone);

%% location of each body before the rotation
talus_old_trans = talus_old_start; % tibia coordinate system
calcn_old_trans = calcn_old_start  + talus_old_start; % tibia coordinate system
toes_old_trans = toes_old_start + calcn_old_start + talus_old_start; % tibia coordinate system

% transform the rot location to the tibia coordinate system
locationTalusRot_trans = locationTalusRot_start;
locationCalcnRot_trans = locationCalcnRot_start + locationTalusRot_start;
locationToesRot_trans = locationToesRot_start + locationTalusRot_start + locationCalcnRot_start;

% the distance that the bodys need to be moved back to orginal location, before the location was rotated
transTalusBack = talus_old_trans - locationTalusRot_trans;
transCalcnBack = calcn_old_trans - locationCalcnRot_trans;
transToesBack = toes_old_trans - locationToesRot_trans;

% translate the bones to the tibia coordinate system and then to their own unrotated location
talus_BACK = [];
for h_talus = 1:size(Talus_start,1)
    talus_NUM_trans = Talus_start(h_talus,:) + transTalusBack + locationTalusRot_start;
    talus_BACK = [talus_BACK; talus_NUM_trans];
end
calcn_BACK = [];
for h_calcn = 1:size(Calcn_start,1)
    calcn_NUM_trans = Calcn_start(h_calcn,:)+ transCalcnBack + locationTalusRot_start + locationCalcnRot_start;
    calcn_BACK = [calcn_BACK; calcn_NUM_trans];
end
calcn_MA_BACK= [];
for h_calcn = 1:size(CalcnMuscles_start,1)
    calcn_MA_trans = CalcnMuscles_start(h_calcn,:) + locationTalusRot_start + locationCalcnRot_start + transCalcnBack;
    calcn_MA_BACK = [calcn_MA_BACK; calcn_MA_trans];
end
toes_BACK = [];
for h_toes = 1:size(Toes_start,1)
    toes_NUM_trans = Toes_start(h_toes,:)+ transToesBack + locationTalusRot_start + locationCalcnRot_start + locationToesRot_start;
    toes_BACK = [toes_BACK; toes_NUM_trans];
end
toes_MA_BACK = [];
for h_toes = 1:size(ToesMuscles_start,1)
    toes_MA_trans = ToesMuscles_start(h_toes,:)+ locationTalusRot_start + locationCalcnRot_start + locationToesRot_start + transToesBack;
    toes_MA_BACK = [toes_MA_BACK; toes_MA_trans];
end
%% Rotation of calcn by the entire angle
% rotation around the Z-axis in the tibia coordinate system
Rz_TT = [cos(TT_angle) -sin(TT_angle) 0; sin(TT_angle) cos(TT_angle) 0; 0 0 1];

talus_rot = (Rz_TT * talus_BACK')';
calcn_rot = (Rz_TT * calcn_BACK')';
calcn_MA_rot = (Rz_TT * calcn_MA_BACK')';
toes_rot = (Rz_TT * toes_BACK')';
toes_MA_rot = (Rz_TT * toes_MA_BACK')';
% Translate back to the original coordinate system for OpenSim
talus_transformed = [];
for hh_talus = 1:size(talus_rot,1)
    talus_rot_trans = talus_rot(hh_talus,:) - locationTalusRot_start- transTalusBack; %TODO is this correct
    talus_transformed = [talus_transformed; talus_rot_trans];
end
calcn_transformed = [];
for hh_calcn = 1:size(calcn_rot,1)
    calcn_rot_trans = calcn_rot(hh_calcn,:) - (locationTalusRot_start) - (locationCalcnRot_start);
    calcn_transformed = [calcn_transformed; calcn_rot_trans];
end
calcn_MA_transformed = [];
for hh_calcn = 1:size(calcn_MA_rot,1)
    calcn_rot_MA_trans = calcn_MA_rot(hh_calcn,:) - (locationTalusRot_start) - (locationCalcnRot_start);
    calcn_MA_transformed = [calcn_MA_transformed; calcn_rot_MA_trans];
end
markerCalcn_start_trans = [];
for i = 1:size(markerCalcn_start,1)
    item = markerCalcn_start(i,:) + transCalcnBack + locationTalusRot_start + locationCalcnRot_start;
    markerCalcn_start_trans = [markerCalcn_start_trans; item];
end
toes_transformed = [];
for hh_toes = 1:size(toes_rot,1)
    toes_rot_trans = toes_rot(hh_toes,:) - (locationTalusRot_start) - (locationCalcnRot_start) - (locationToesRot_start);
    toes_transformed = [toes_transformed; toes_rot_trans];
end
toes_MA_transformed = [];
for hh_toes = 1:size(toes_MA_rot,1)
    toes_MA_rot_trans = toes_MA_rot(hh_toes,:) - (locationTalusRot_start) - (locationCalcnRot_start) - (locationToesRot_start);
    toes_MA_transformed = [toes_MA_transformed; toes_MA_rot_trans];
end
figure('position', [700, 50, 450, 950])
colormap([1,1,1]); grey = [0.4 0.4 0.4];
trisurf(tri3_talus,talus_BACK(:,1),talus_BACK(:,2), talus_BACK(:,3), 'edgecolor','black'); hold on
trisurf(tri3_calcn,calcn_BACK(:,1),calcn_BACK(:,2), calcn_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_toes,toes_BACK(:,1),toes_BACK(:,2), toes_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_talus,talus_BACK(:,1),talus_BACK(:,2),talus_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_calcn,calcn_BACK(:,1),calcn_BACK(:,2),calcn_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_toes,toes_BACK(:,1),toes_BACK(:,2),toes_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_talus,talus_rot(:,1),talus_rot(:,2), talus_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri3_calcn,calcn_rot(:,1),calcn_rot(:,2), calcn_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri3_toes,toes_rot(:,1),toes_rot(:,2), toes_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_talus,talus_rot(:,1),talus_rot(:,2),talus_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_calcn,calcn_rot(:,1),calcn_rot(:,2),calcn_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_toes,toes_rot(:,1),toes_rot(:,2),toes_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on
% scatter3(calcn_MA_BACK(:,1),calcn_MA_BACK(:,2),calcn_MA_BACK(:,3), 20,'b', 'Linewidth',2); hold on
% scatter3(toes_MA_BACK(:,1),toes_MA_BACK(:,2),toes_MA_BACK(:,3), 20,'b', 'Linewidth',2); hold on
% scatter3(calcn_MA_rot(:,1),calcn_MA_rot(:,2),calcn_MA_rot(:,3), 20,'r', 'Linewidth',2); hold on
% scatter3(toes_MA_rot(:,1),toes_MA_rot(:,2),toes_MA_rot(:,3), 20,'r', 'Linewidth',2);
axis equal; xlabel('x'); ylabel('y'); zlabel('z');
set(gca,'FontSize',20); view(0,90);
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);
%% 2. rotation
% --------------------------------------------------------------------
% Notes:    Create a twist in the tibial bone, a linearly varying twist of the tibia beginning just above the distal third of the
%           tibia and continuing to a location just distal to the origin of the soleus and the patelar tendon attachemt site.
% ----------------------------------------------------------------------
%Find the distance between the knee joint and the ankle joint
max_tibia = [0 0 0];
min_tibia_opensim = str2num(dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.Joint.CustomJoint.location_in_parent.Text);
[min_tibia] = coordinatesCorrection(min_tibia_opensim);
distance = norm(max_tibia-min_tibia);

% Divide the tibia into three parts
distance_L3 = distance*(2/3); distance_L2 = distance/3;

%Divide the tibial bone into three parts and rotate
%rotation of the tibial bone
tibia_rot = []; tibia_mid_rot= []; tibia_bottom_rot= []; 
tibia_mid= []; tibia_bottom= [];
for i = 1:size(Tibia_start,1)
    vertix_dist = norm(max_tibia- Tibia_start(i,:));
    % Highest part of the tibia - not affected
    if vertix_dist <= distance_L2
        tibia_rot = [tibia_rot; Tibia_start(i,:)];
        % The linear twist in the middle part of the bone is created
    elseif (vertix_dist < distance_L3) && (vertix_dist > (distance_L2))
        scalingRotVect = ((vertix_dist-distance_L2)/distance_L2)*TT_angle;
        %Ry_rot2L = [cos(scalingRotVect) 0 sin(scalingRotVect); 0 1 0; -sin(scalingRotVect) 0 cos(scalingRotVect)];
        Rz_rot2 = [cos(scalingRotVect) -sin(scalingRotVect) 0; sin(scalingRotVect) cos(scalingRotVect) 0; 0 0 1];
        grad_rot2_tibiaL  = Rz_rot2*Tibia_start(i,:)';
        tibia_mid = [tibia_mid; Tibia_start(i,:)];
        tibia_rot(i,:) = grad_rot2_tibiaL';  
        tibia_mid_rot =[tibia_mid_rot; grad_rot2_tibiaL'];
        % The lowest part of the bone is roated by the entire angle
    elseif vertix_dist >= distance_L3
        tibia_rot2 = Rz_TT * Tibia_start(i,:)';
        tibia_bottom = [tibia_bottom; Tibia_start(i,:)];
        tibia_rot(i,:) = tibia_rot2';
        tibia_bottom_rot = [tibia_bottom_rot; tibia_rot2'];
    end
end
%rotation of the tibial muscle attachments
tibiaMA_rot = [];
for i = 1:size(TibiaMuscles_start,1)
    MA_dist = norm(max_tibia - TibiaMuscles_start(i,:));
    % Highest part of the tibia - not affected
    if MA_dist <= distance_L2
        tibiaMA_rot = [tibiaMA_rot; TibiaMuscles_start(i,:)];
        % The linear twist in the middle part of the bone is created
    elseif (MA_dist < distance_L3) && (MA_dist > (distance_L2))
        scalingRotMA = ((MA_dist-distance_L2)/distance_L2)*TT_angle;
        Rz_rot2 = [cos(scalingRotMA) -sin(scalingRotMA) 0; sin(scalingRotMA) cos(scalingRotMA) 0; 0 0 1];
        grad_rot2_tibiaMA  = Rz_rot2*TibiaMuscles_start(i,:)';
        tibiaMA_rot =[tibiaMA_rot; grad_rot2_tibiaMA'];
        % The lowest part of the bone is roated by the entire angle
    elseif MA_dist >= distance_L3
        tibia_rotMA2 = Rz_TT * TibiaMuscles_start(i,:)';
        tibiaMA_rot = [tibiaMA_rot; tibia_rotMA2'];
    end
end
% figure('position', [600, 50, 400, 950])
% grey = [0.4,0.4,0.4];
% scatter3(tibia_rot(:,1),tibia_rot(:,2), tibia_rot(:,3),20,grey); hold on 
% scatter3(Tibia_start(:,1),Tibia_start(:,2), Tibia_start(:,3),20,'black');
% dim = [.29 0.39 .46 .25];
% annotation('rectangle',dim,'Color','black'); h = text(-0.068,-.2,-.15, 'Rotation 2', 'Color','black','FontSize',14);
% set(h, 'rotation', 90); dim2 = [.29 .14 .46 .25]; annotation('rectangle',dim2,'Color','black')
% h = text(-0.068,-.2,-.28, 'Rotation 1', 'Color','black','FontSize',14); set(h, 'rotation', 90)
% for p = 1:size(tibia_rot,1)
%     h =  plot3([Tibia_start(p,1),tibia_rot(p,1)],[Tibia_start(p,2),tibia_rot(p,2)],[Tibia_start(p,3),tibia_rot(p,3)],'b');set(h,'linewidth',1); hold on
% end
% axis equal; view(-30,25); set(gca,'FontSize',14); xlabel('x'); ylabel('y'); zlabel('z')

figure('position', [700, 50, 450, 950])
colormap([1,1,1])   
trisurf(tri3_tibia,tibia_rot(:,1),tibia_rot(:,2), tibia_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_tibia,tibia_rot(:,1),tibia_rot(:,2), tibia_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on 
trisurf(tri3_tibia,Tibia_start(:,1),Tibia_start(:,2),Tibia_start(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_tibia,Tibia_start(:,1),Tibia_start(:,2),Tibia_start(:,3), 'edgecolor','black');
dim = [.31 0.4 .65 .25];
annotation('rectangle',dim,'Color','black'); h = text(-0.155,-.175,-.15, 'Rotation 2', 'Color','black','FontSize',20);
set(h, 'rotation', 90); dim2 = [.31 .12 .65 .28]; annotation('rectangle',dim2,'Color','black')
h = text(-0.155,-.175,-.26, 'Rotation 1', 'Color','black','FontSize',20); set(h, 'rotation', 90)
axis equal; grid on; 
set(gca,'FontSize',20); xlabel('x'); ylabel('y'); zlabel('z');view(-30,25);
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);
% create a new pair of axes inside current figure
axes('position',[.55 .150 .5 .50])
box on % put box around new pair of axes
scatter3(tibia_mid_rot(:,1),tibia_mid_rot(:,2), tibia_mid_rot(:,3),20,'black'); hold on 
scatter3(tibia_mid(:,1),tibia_mid(:,2), tibia_mid(:,3),20,grey); hold on 
scatter3(tibia_bottom_rot(:,1),tibia_bottom_rot(:,2), tibia_bottom_rot(:,3),20,'black'); hold on 
scatter3(tibia_bottom(:,1),tibia_bottom(:,2), tibia_bottom(:,3),20,grey); hold on 
for p = 1:size(tibia_mid,1)
    h =  plot3([tibia_mid(p,1),tibia_mid_rot(p,1)],[tibia_mid(p,2),tibia_mid_rot(p,2)],[tibia_mid(p,3),tibia_mid_rot(p,3)],'b');set(h,'linewidth',1); hold on
end
for p = 1:size(tibia_bottom,1)
    h =  plot3([tibia_bottom(p,1),tibia_bottom_rot(p,1)],[tibia_bottom(p,2),tibia_bottom_rot(p,2)],[tibia_bottom(p,3),tibia_bottom_rot(p,3)],'b');set(h,'linewidth',1); hold on
end
axis equal; view(-30,25)
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);
%%
%rotation of the markers
markerCalcn_rot = [];
for i = 1:size(markerCalcn_start_trans,1)
    marker_dist = norm(max_tibia - markerCalcn_start_trans(i,:));
    % Highest part of the tibia - not affected
    if marker_dist <= distance_L2
        markerCalcn_rot = [markerCalcn_rot; markerCalcn_start_trans(i,:)];
        % The linear twist in the middle part of the bone is created
    elseif (marker_dist < distance_L3) && (marker_dist > (distance_L2))
        scalingRotmarker = ((marker_dist-distance_L2)/distance_L2)*TT_angle;
        Rz_rot2 = [cos(scalingRotmarker) -sin(scalingRotmarker) 0; sin(scalingRotmarker) cos(scalingRotmarker) 0; 0 0 1];
        grad_rot2_marker  = Rz_rot2*markerCalcn_start_trans(i,:)';
        markerCalcn_rot =[markerCalcn_rot; grad_rot2_marker'];
        % The lowest part of the bone is roated by the entire angle
    elseif marker_dist >= distance_L3
        tibia_rotMarker = Rz_TT * markerCalcn_start_trans(i,:)';
        markerCalcn_rot = [markerCalcn_rot; tibia_rotMarker'];
    end
end
markerTibia_rot = [];
for i = 1:size(markerTibia_start,1)
    marker_dist = norm(max_tibia - markerTibia_start(i,:));
    % Highest part of the tibia - not affected
    if marker_dist <= distance_L2
        markerTibia_rot = [markerTibia_rot; markerTibia_start(i,:)];
        % The linear twist in the middle part of the bone is created
    elseif (marker_dist < distance_L3) && (marker_dist > (distance_L2))
        scalingRotmarker = ((marker_dist-distance_L2)/distance_L2)*TT_angle;
        Rz_rot2 = [cos(scalingRotmarker) -sin(scalingRotmarker) 0; sin(scalingRotmarker) cos(scalingRotmarker) 0; 0 0 1];
        grad_rot2_marker  = Rz_rot2*markerTibia_start(i,:)';
        markerTibia_rot =[markerTibia_rot; grad_rot2_marker'];
        % The lowest part of the bone is roated by the entire angle
    elseif marker_dist >= distance_L3
        tibia_rotMarker = Rz_TT * markerTibia_start(i,:)';
        markerTibia_rot = [markerTibia_rot; tibia_rotMarker'];
    end
end
% transfer the markers of the calcn to the original coordinate system
markerCalcn_start_transBACK = [];
for i = 1:size(markerCalcn_rot,1)
    item = markerCalcn_rot(i,:) - (locationTalusRot_start) - (locationCalcnRot_start);%- calcn_old_start - talus_old_start;
    markerCalcn_start_transBACK = [markerCalcn_start_transBACK; item];
end

%% plot everyting with the muscle attachment

figure('position', [700, 50, 450, 950])
colormap([1,1,1]);
trisurf(tri3_tibia,tibia_rot(:,1),tibia_rot(:,2), tibia_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_tibia,tibia_rot(:,1),tibia_rot(:,2), tibia_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri3_tibia,Tibia_start(:,1),Tibia_start(:,2), Tibia_start(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_tibia,Tibia_start(:,1),Tibia_start(:,2), Tibia_start(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_talus,talus_BACK(:,1),talus_BACK(:,2), talus_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_calcn,calcn_BACK(:,1),calcn_BACK(:,2), calcn_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_toes,toes_BACK(:,1),toes_BACK(:,2),  toes_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_talus,talus_BACK(:,1),talus_BACK(:,2), talus_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_calcn,calcn_BACK(:,1),calcn_BACK(:,2), calcn_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri4_toes,toes_BACK(:,1),toes_BACK(:,2), toes_BACK(:,3), 'edgecolor','black'); hold on;
trisurf(tri3_talus,talus_rot(:,1),talus_rot(:,2), talus_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri3_calcn,calcn_rot(:,1),calcn_rot(:,2), calcn_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri3_toes,toes_rot(:,1),toes_rot(:,2),  toes_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_talus,talus_rot(:,1),talus_rot(:,2), talus_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_calcn,calcn_rot(:,1),calcn_rot(:,2), calcn_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on;
trisurf(tri4_toes,toes_rot(:,1),toes_rot(:,2), toes_rot(:,3), 'edgecolor','black','LineStyle',':'); hold on
% scatter3(calcn_MA_BACK(:,1),calcn_MA_BACK(:,2),calcn_MA_BACK(:,3), 20,'b', 'Linewidth',2); hold on
% scatter3(toes_MA_BACK(:,1),toes_MA_BACK(:,2),toes_MA_BACK(:,3), 20,'b','Linewidth',2); hold on
% scatter3(calcn_MA_rot(:,1),calcn_MA_rot(:,2),calcn_MA_rot(:,3), 20,'r','Linewidth',2); hold on
% scatter3(toes_MA_rot(:,1),toes_MA_rot(:,2),toes_MA_rot(:,3), 20,'r','Linewidth',2); hold on
% scatter3(tibiaMA_rot(:,1),tibiaMA_rot(:,2),tibiaMA_rot(:,3), 20,'r','Linewidth',2); hold on 
% scatter3(TibiaMuscles_start(:,1),TibiaMuscles_start(:,2),TibiaMuscles_start(:,3), 20,'b','Linewidth',2);
if strcmp(answerLeg, rightbone) == 1;
    view(10,40)
else
    view(50,30)
end
axis equal; xlabel('x'); ylabel('y'); zlabel('z'); set(gca, 'fontsize',20);
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'ZTickLabelMode', 'manual', 'ZTickLabel', []);
%% convert back to the OpenSim coordinates
[tibia_rot_OpenSim]=coordinatesOpenSim(tibia_rot);
[talus_transformed_OpenSim]=coordinatesOpenSim(talus_transformed);
[calcn_transformed_OpenSim]=coordinatesOpenSim(calcn_transformed);
[toes_transformed_OpenSim]=coordinatesOpenSim(toes_transformed);

[tibia_MA_OpenSim]=coordinatesOpenSim(tibiaMA_rot);
[calcn_MA_OpenSim]=coordinatesOpenSim(calcn_MA_transformed);
[toes_MA_OpenSim]=coordinatesOpenSim(toes_MA_transformed);

[tibia_marker_OpenSim]=coordinatesOpenSim(markerTibia_rot);
[calcn_marker_OpenSim]=coordinatesOpenSim(markerCalcn_start_transBACK);

%% export the data
% convert the tibia data back to string
tibia_rotated =sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',tibia_rot_OpenSim');
tibia_Repared = strrep(tibia_rotated,'+',' ');
% replace the generic data with the rotated bone
dataTibia.VTKFile.PolyData.Piece.Points.DataArray.Text = tibia_Repared;

% convert the struct back to xml file
Tibia_rotated = struct2xml(dataTibia);
%name and placement of the tibia bone file
direct = [];
% export - write the model as an xml  - remember to save as a vtp file
if strcmp(answerLeg, rightbone) == 1;
    modelName = answerNameModelTibia;
    boneName = 'tibiaR_rotated.vtp';
    cTibiaR = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cTibiaR);
    FID_tibiaR = fopen(placeNameTibia,'w');
    fprintf(FID_tibiaR,Tibia_rotated);
    fclose(FID_tibiaR);
else
    modelName = answerNameModelTibia;
    boneName = 'tibiaL_rotated.vtp';
    cTibiaL = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cTibiaL);
    FID_tibiaL = fopen(placeNameTibia,'w');
    fprintf(FID_tibiaL,Tibia_rotated);
    fclose(FID_tibiaL);
end

%change the name of the tibia in the gait2392 model file
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,4}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry{1,1}.geometry_file.Text = cTibiaR;
else
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,9}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry{1,1}.geometry_file.Text = cTibiaL;
end

% convert the tibia data back to string
talus_rotated =sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',talus_transformed_OpenSim');
talus_Repared = strrep(talus_rotated,'+',' ');
% replace the generic data with the rotated bone
dataTalus.VTKFile.PolyData.Piece.Points.DataArray.Text = talus_Repared;

% convert the struct back to xml file
Talus_rotated = struct2xml(dataTalus);
% export - write the model as an xml  - remember to save as a vtp file
if strcmp(answerLeg, rightbone) == 1;
    modelName = answerNameModelTibia;
    boneName = 'talusR_rotated.vtp';
    cTalusR = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cTalusR);
    FID_talusR = fopen(placeNameTibia,'w');
    fprintf(FID_talusR,Talus_rotated);
    fclose(FID_talusR);
else
    modelName = answerNameModelTibia;
    boneName = 'talusL_rotated.vtp';
    cTalusL = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cTalusL);
    FID_talusL = fopen(placeNameTibia,'w');
    fprintf(FID_talusL,Talus_rotated);
    fclose(FID_talusL);
end


%change the name of the tibia in the gait2392 model file
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cTalusR;
else
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,10}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cTalusL;
end

% convert the tibia data back to string
calcn_rotated =sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',calcn_transformed_OpenSim');
calcn_Repared = strrep(calcn_rotated,'+',' ');
% replace the generic data with the rotated bone
dataCalcn.VTKFile.PolyData.Piece.Points.DataArray.Text = calcn_Repared;

% convert the struct back to xml file
Calcn_rotated = struct2xml(dataCalcn);
% export - write the model as an xml  - remember to save as a vtp file
if strcmp(answerLeg, rightbone) == 1;
    modelName = answerNameModelTibia;
    boneName = 'calcnR_rotated.vtp';
    cCalcnR = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cCalcnR);
    FID_calcnR = fopen(placeNameTibia,'w');
    fprintf(FID_calcnR,Calcn_rotated);
    fclose(FID_calcnR);  
else
    modelName = answerNameModelTibia;
    boneName = 'calcnL_rotated.vtp';
    cCalcnL = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cCalcnL);
    FID_calcnL = fopen(placeNameTibia,'w');
    fprintf(FID_calcnL,Calcn_rotated);
    fclose(FID_calcnL);
end

%change the name of the tibia in the gait2392 model file
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,6}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cCalcnR; 
else
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,11}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cCalcnL;
end

% convert the tibia data back to string
toes_rotated =sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',toes_transformed_OpenSim');
toes_Repared = strrep(toes_rotated,'+',' ');
% replace the generic data with the rotated bone
dataToes.VTKFile.PolyData.Piece.Points.DataArray.Text = toes_Repared;

% convert the struct back to xml file
Toes_rotated = struct2xml(dataToes);
% export - write the model as an xml  - remember to save as a vtp file
if strcmp(answerLeg, rightbone) == 1;
    modelName = answerNameModelTibia;
    boneName = 'toesR_rotated.vtp';
    cToesR = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cToesR);
    FID_toesR = fopen(placeNameTibia,'w');
    fprintf(FID_toesR,Toes_rotated);
    fclose(FID_toesR);
else
    modelName = answerNameModelTibia;
    boneName = 'toesL_rotated.vtp';
    cToesL = sprintf('%s_%s' ,modelName,boneName);
    placeNameTibia = sprintf('%s', direct, place, cToesL);
    FID_toesL = fopen(placeNameTibia,'w');
    fprintf(FID_toesL,Toes_rotated);
    fclose(FID_toesL);
end


%change the name of the tibia in the gait2392 model file
if strcmp(answerLeg, rightbone) == 1;
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,7}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cToesR;
else
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,12}.VisibleObject...
        .GeometrySet.objects.DisplayGeometry.geometry_file.Text = cToesL;
end

%% Fill in the rotated muscle attachments to the model
for i = 1:size(CalcnMuscles,1)
    musclenr = CalcnNR(i,:);
    string = CalcnPlace1{i,:};   
    dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr}.GeometryPath.PathPointSet.objects...
        .(string(1:9)){1,str2num(string(13))}.location.Text=calcn_MA_OpenSim(i,:);
end
for i = 1:size(ToesMuscles,1)
    musclenr_toes = ToesNR(i,:);
    string_toes = ToesPlace1{i,:};   
    dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_toes}...
        .GeometryPath.PathPointSet.objects.(string_toes(1:9)){1,str2num(string_toes(13))}.location.Text = toes_MA_OpenSim(i,:);
end
for i = 1:size(TibiaMuscles,1)
    if size(TibiaPlace1{i,1},2) == 14 ;
        musclenr_tibia = TibiaNR(i,:);
        string_tibia = TibiaPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_tibia}...
            .GeometryPath.PathPointSet.objects.(string_tibia(1:9)){1,str2num(string_tibia(13))}.location.Text = tibia_MA_OpenSim(i,:);
    elseif size(TibiaPlace1{i,1},2) == 20;
        musclenr_tibia = TibiaNR(i,:);
        string_tibia = TibiaPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_tibia}...
            .GeometryPath.PathPointSet.objects.(string_tibia).location.Text = tibia_MA_OpenSim(i,:);
    else
        musclenr_tibia = TibiaNR(i,:);
        string_tibia = TibiaPlace1{i,:};
        dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_tibia}...
            .GeometryPath.PathPointSet.objects.(string_tibia).location.Text = tibia_MA_OpenSim(i,:);
    end
end
for i = 1:size(markerCalcn_rot,1)
    musclenr = markerCalcnNR(i,:);
    markerset.OpenSimDocument.MarkerSet.objects.Marker{1,musclenr}.location.Text = calcn_marker_OpenSim(i,:);
end
for i = 1:size(markerTibia_rot,1)
    musclenr = markerTibiaNR(i,:);
    markerset.OpenSimDocument.MarkerSet.objects.Marker{1,musclenr}.location.Text = tibia_marker_OpenSim(i,:);
end
%% change the name of the model
type= 'deformed';
modelNamePrint = sprintf('%s_%s' ,modelName,type);
dataModel.OpenSimDocument.Model.Attributes.name = 'deformed_model';%modelNamePrint; 
%% Export the whole gait2392 model file - rotated muscle attachements and correct bone rotataion names
% export the gait2392
cd functions
Model2392_rotatedtibia = struct2xml(dataModel);
%name and placement of the femoral bone file
if strcmp(answerLeg,rightbone) == 1
placeNameModel = sprintf('%s', direct, place, modelName,'.osim');
else
placeNameModel = sprintf('%s', direct, place, 'FINAL_PERSONALISEDTORSIONS','.osim');
end
%write the model as an xml file
FID_model = fopen(placeNameModel,'w');
fprintf(FID_model,Model2392_rotatedtibia);
fclose(FID_model);

%% the pathpoints in the file are in the wrong order, because conditional pathpoints are put last when printed -> this corrects them to be in the right order
file=importdata(placeNameModel);
% right leg
file_out = file(1:1881+4);

% lines in the file up to where the path points for each muscle are correct (1st input), and line where the conditional path points start (2nd input) are defined
condPathPoint(1,:) = [1 1885];
condPathPoint(2,:) = [1885 1890]; %semimem
condPathPoint(3,:) = [1939 1952]; %semiten
condPathPoint(4,:) = [2509 2518]; %grac
condPathPoint(5,:) = [2739 2748]; %iliacus
condPathPoint(6,:) = [2801 2810]; %psoas
condPathPoint(7,:) = [3331 3336]; %med_gas
condPathPoint(8,:) = [3385 3390];
condPathPoint(9,:) = 4335;
for x = 2:length(condPathPoint)-1
    file_out = [file_out; file(condPathPoint(x,2):condPathPoint(x,2)+5); file(condPathPoint(x,1)+1:condPathPoint(x,2)-1); file(condPathPoint(x,2)+6:condPathPoint(x+1,1))];
end

% left leg
%     file_out = file(1:4221);
    condPathPoint(1,:) = [1 4335];
condPathPoint(2,:) = [1885 1890]+2450; %semimem
condPathPoint(3,:) = [1939 1952]+2450; %semiten
condPathPoint(4,:) = [2509 2518]+2450; %grac
condPathPoint(5,:) = [2739 2748]+2450; %iliacus
condPathPoint(6,:) = [2801 2810]+2450; %psoas
condPathPoint(7,:) = [3331 3336]+2450; %med_gas
condPathPoint(8,:) = [3385 3390]+2450;
condPathPoint(9,:) = length(file);
for x = 2:length(condPathPoint)-1
    file_out = [file_out; file(condPathPoint(x,2):condPathPoint(x,2)+5); file(condPathPoint(x,1)+1:condPathPoint(x,2)-1); file(condPathPoint(x,2)+6:condPathPoint(x+1,1))];
end

%%

if strcmp(answerLeg,rightbone) == 1
placeNameModel = sprintf('%s', direct, place, modelName,'.osim');
else
placeNameModel = sprintf('%s', direct, place, 'FINAL_PERSONALISEDTORSIONS','.osim');
end
FID_model2 = fopen(placeNameModel,'w');
fprintf(FID_model2,'%10s\n',file_out{:});
fclose(FID_model2);

disp('New model file has been saved')

% export the the marker setup for the scaling tool in opensim
markersetup_rotatedtibia = struct2xml(markerset);
%write the model as an xml file
markersName= answerNameMarkerTibia;
markerNameOut = sprintf('%s_%s', modelName, markersName);
%name and placement of the femoral bone file
if strcmp(answerLeg,rightbone) == 1
placeNameMarker = sprintf('%s', direct, place, markerNameOut);
else
placeNameMarker = sprintf('%s', direct, place, 'FINAL_MARKERSET.xml');
end
FID_marker = fopen(placeNameMarker,'w');
fprintf(FID_marker,markersetup_rotatedtibia);
fclose(FID_marker);
disp('New marker set has been saved')
cd ..
