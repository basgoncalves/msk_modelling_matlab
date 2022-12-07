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
% Notes: The tibia is rotated in two parts.
%   1) distal third rotated by the entire angle with the talus, calcn and toes.
%   2) The middle part, distal to the soleus attachment continuing to the distal third of the tibia is rotated gradually as a function of superior-inferior distance.
% inputs: The model, Torsion angle (TT_angle), tibia vertix, tiba polys, tibia muscle attachments
% output: xml file with rotated bone/bones and muscle attachments
% ----------------------------------------------------------------------
function     tibia(dataModel, markerset, answerLeg, rightbone, TT_angle, answerNameModelTibia,...
    ~, dataTibia, dataCalcn, dataTalus, dataToes, place)
%% Find the muscle attachment on the tibia, calcn, talus and toes and placstr2nume in a matrix
[TibiaMuscles,TibiaPlace,TibiaNR,CalcnMuscles,CalcnPlace,CalcnNR,ToesMuscles,ToesPlace,ToesNR,...
     Femur_c, Femur_pp, Femur_na,muscle_names] = get_muscle_attachments(dataModel, answerLeg);

 
% The vertices for the bone are rotated to fit the coordinate system in MATLAB2num
[TibiaMuscles_start] = coordinatesCorrection(TibiaMuscles);
[CalcnMuscles_start] = coordinatesCorrection(CalcnMuscles);
[ToesMuscles_start] = coordinatesCorrection(ToesMuscles);
%  Prepare the data needed (str2double will not work)
calcn_NUM = str2num(dataCalcn.VTKFile.PolyData.Piece.Points.DataArray.Text);
polyText_Calcn = dataCalcn.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
talus_NUM = str2num(dataTalus.VTKFile.PolyData.Piece.Points.DataArray.Text);
polyText_Talus = dataTalus.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
toes_NUM = str2num(dataToes.VTKFile.PolyData.Piece.Points.DataArray.Text);
polyText_Toes = dataToes.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
tibia_NUM = str2num(dataTibia.VTKFile.PolyData.Piece.Points.DataArray.Text);
polyText_Tibia = dataTibia.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;

% The vertices for the bone are rotated to fit the coordinate system in MATLAB
[Tibia_start] = coordinatesCorrection(tibia_NUM);
[Talus_start] = coordinatesCorrection(talus_NUM);
[Calcn_start] = coordinatesCorrection(calcn_NUM);
[Toes_start] = coordinatesCorrection(toes_NUM);

%Find the markers attach to the tibia and calcn and convert to MATLAB %coordinate system
[markerCalcn, markerTibia, markerCalcnNR, markerTibiaNR, ~, ~] = OpenSimMarkers(markerset, answerLeg, rightbone);
[markerTibia_start] = coordinatesCorrection(markerTibia);
[markerCalcn_start] = coordinatesCorrection(markerCalcn);

%% prepare the polys in the correct format for ploting the bones
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
min_tibia_opensim = str2num(dataModel.OpenSimDocument.Model.JointSet.objects.CustomJoint{1,4}.frames.PhysicalOffsetFrame{1,1}.translation.Text);
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
%% rotation of the markers
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
dataModel = add_geometry_to_osimStruct(dataModel,tibia_rot_OpenSim,dataTibia,answerNameModelTibia,answerLeg,'tibia',place);
dataModel = add_geometry_to_osimStruct(dataModel,talus_transformed_OpenSim,dataTalus,answerNameModelTibia,answerLeg,'talus',place);
dataModel = add_geometry_to_osimStruct(dataModel,calcn_transformed_OpenSim,dataCalcn,answerNameModelTibia,answerLeg,'calcn',place);
dataModel = add_geometry_to_osimStruct(dataModel,toes_transformed_OpenSim,dataToes,answerNameModelTibia,answerLeg,'toes',place);

%% Fill in the rotated muscle attachments to the model

muscle_names;
for i = 1:size(CalcnMuscles,1)
    musclenr = CalcnNR(i,:);
    string = CalcnPlace{i,:};
    dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr}.GeometryPath.PathPointSet.objects...
        .(string(1:9)){1,str2num(string(13))}.location.Text=calcn_MA_OpenSim(i,:);
end

for i = 1:size(ToesMuscles,1)
    musclenr_toes = ToesNR(i,:);
    string_toes = ToesPlace{i,:};
    dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_toes}...
        .GeometryPath.PathPointSet.objects.(string_toes(1:9)){1,str2num(string_toes(13))}.location.Text = toes_MA_OpenSim(i,:);
end

for i = 1:size(TibiaMuscles,1)
    musclenr_tibia  = TibiaNR(i,:);
    string_tibia    = TibiaPlace{i,:};
    cell_PathPoint  = str2num(string_tibia(13));
    dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,musclenr_tibia}...
        .GeometryPath.PathPointSet.objects.PathPoint{1,cell_PathPoint}.location.Text = tibia_MA_OpenSim(i,:);
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
modelNamePrint = sprintf('%s_%s' ,answerNameModelTibia,type);
dataModel.OpenSimDocument.Model.Attributes.name = 'deformed_model'; %modelNamePrint;
%% Export the whole gait2392 model file - rotated muscle attachements and correct bone rotataion names
% export the gait2392
Model2392_rotatedtibia = struct2xml(dataModel,['.\' modelNamePrint '.osim']);
placeNameModel = ['.\' modelNamePrint '.osim'];
%write the model as an xml file
FID_model = fopen(placeNameModel,'w');
fprintf(FID_model,Model2392_rotatedtibia);
fclose(FID_model);

%% the pathpoints in the file are in the wrong order, because conditional pathpoints are put last when printed -> this corrects them to be in the right order
file = importdata(placeNameModel);
% if strcmp(answerLeg,rightbone)==1
file_out = file;
% else
% right leg
file_out = file(1:1677);

% lines in the file up to where the path points for each muscle are correct (1st input), and line where the conditional path points start (2nd input) are defined
condPathPoint(1,:) = [1 1677];
condPathPoint(2,:) = [1677 1682]; %semimem
condPathPoint(3,:) = [1722 1735]; %semiten
condPathPoint(4,:) = [2193 2202]; %grac
condPathPoint(5,:) = [2387 2396]; %iliacus
condPathPoint(6,:) = [2440 2449]; %psoas
condPathPoint(7,:) = [2898 2903]; %med_gas
condPathPoint(8,:) = [2943 2948]; %lat_gas
condPathPoint(9,:) = 3740;
for x = 2:length(condPathPoint)-1
    file_out = [file_out; file(condPathPoint(x,2):condPathPoint(x,2)+5); file(condPathPoint(x,1)+1:condPathPoint(x,2)-1); file(condPathPoint(x,2)+6:condPathPoint(x+1,1))];
end

% left leg
condPathPoint(1,:) = [1 3740];
condPathPoint(2,:) = [1677 1682]+2063; %semimem
condPathPoint(3,:) = [1722 1735]+2063; %semiten
condPathPoint(4,:) = [2193 2202]+2063; %grac
condPathPoint(5,:) = [2387 2396]+2063; %iliacus
condPathPoint(6,:) = [2440 2449]+2063; %psoas
condPathPoint(7,:) = [2898 2903]+2063; %med_gas
condPathPoint(8,:) = [2943 2948]+2063; %lat_gas
condPathPoint(9,:) = length(file);
for x = 2:length(condPathPoint)-1
    file_out = [file_out; file(condPathPoint(x,2):condPathPoint(x,2)+5); file(condPathPoint(x,1)+1:condPathPoint(x,2)-1); file(condPathPoint(x,2)+6:condPathPoint(x+1,1))];
end
% end
%%
FID_model2 = fopen(placeNameModel,'w');
fprintf(FID_model2,'%10s\n',file_out{:});
fclose(FID_model2);

disp(['New model file has been saved in ' placeNameModel])

% export the the marker setup for the scaling tool in opensim
markersetup_rotatedtibia = struct2xml(markerset);
%write the model as an xml file
markersName= answerNameMarkerTibia;
markerNameOut = sprintf('%s_%s', modelName, markersName);
%name and placement of the femoral bone file
placeNameMarker = sprintf('%s', direct, place, markerNameOut);

FID_marker = fopen(placeNameMarker,'w');
fprintf(FID_marker,markersetup_rotatedtibia);
fclose(FID_marker);
disp(['New marker set has been saved in ' placeNameMarker])

% split the figures across the screen (Nov 2022)
[~,~,window_width,~] = matWinPos;
f = figure(1); f.Position(1) = 10;
f = figure(2); f.Position(1) = window_width/4;
f = figure(3); f.Position(1) = window_width/4*2;
close all
