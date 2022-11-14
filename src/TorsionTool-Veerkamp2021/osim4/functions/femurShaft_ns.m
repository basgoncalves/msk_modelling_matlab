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

% Notes: This scripts finds the correct rotational axis of the femoral
% bone. 
% We find the boxes for rotation as well
% inputs: the verticis of the femoral bone and the polys of it.

% output: femur_NewAxis. The vertices of the femoral bone with the rotation
% axis through the middle of the femoral shaft
% ----------------------------------------------------------------------

function [innerBox, middleBox, innerBoxMA, innerBoxMarker, middleBoxMA, middleBoxMarker,femurShaftLocRot, headShaftRot,...
    angleZX, angleZY,angleXY,translationDis, femurShaftLocRotMA, femurShaftLocRotMarkers,...
    Condylar,ShaftProx,ShaftDist, CondylarMA,ShaftDistMA,CondylarMarkers, ShaftMarkers]...
    = femurShaft_ns_082020(dataModel, femur_start, answerLeg, rightbone, femurMuscle_start,markerFemur_start)

% points defining the axes, as determined by Lorenzo's code using the undeformed generic bones
if strcmp(answerLeg, rightbone) == 1; % right leg
    SEL = [-28.5309 5.3055 -3.3018]./1000; % saddle point femoral neck
    SEL_epi = [-1.799 -19.7590 -418.0754]./1000; % saddle point between the two epicondyles
    HC = [-0.1583 -0.2439 0.0038]./1000; % centre of femoral head
    ISTHMUS = [-17.2534 4.2462 -14.4892]./1000; % centre of the femoral neck
else % left leg
    SEL = [28.5518 5.2971 -3.2637]./1000;
    SEL_epi = [1.8459 -19.72 -418.0768]./1000;
    HC = [0.1536 -0.2856 0.0421]./1000;
    ISTHMUS = [17.2422 2.2442 -14.4670]./1000;
end

point1=SEL;
point2=SEL_epi;
t=0:.001:1;
C=repmat(point1,length(t),1)'+(point2-point1)'*t;
SEL_point =C(:,111)'; % select rotation point on shaft axis, at height of smaller trochanter
% figure
% scatter3(femur_start(:,1),femur_start(:,2),femur_start(:,3),'black'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% scatter3(0,0,0,'red');
% scatter3(HC(1),HC(2),HC(3),'blue')
% scatter3(ISTHMUS(1),ISTHMUS(2),ISTHMUS(3),'blue')
% scatter3(SEL_point(1),SEL_point(2),SEL_point(3),'green')
% scatter3(SEL(1),SEL(2),SEL(3),'blue')
% scatter3(SEL_epi(1),SEL_epi(2),SEL_epi(3),'blue')
% plot3([SEL_epi(1),SEL(1)],[SEL_epi(2),SEL(2)],[SEL_epi(3),SEL(3)], 'blue', 'Linewidth',3) % shaft axis
% plot3([ISTHMUS(1),HC(1)],[ISTHMUS(2),HC(2)],[ISTHMUS(3),HC(3)], 'blue', 'Linewidth',3) % neck axis


%% Transform the new femoral shaft axis to the rotation point (SEL_point)
% move the zero point
translationDis = [0 0 0] - SEL_point;
%the bone
femurShaftLoc = [];
for i = 1:size(femur_start,1)
    item  = femur_start(i,:)+translationDis;
    femurShaftLoc = [femurShaftLoc; item];
end

SEL_epiShaft = SEL_epi + translationDis;
SEL_pointShaft = SEL_point + translationDis;
headShaft = HC +translationDis;
isthmusShaft = ISTHMUS + translationDis;

% the muscle attachments
femurShaftLocMA = [];
for i = 1:size(femurMuscle_start,1)
    item  = femurMuscle_start(i,:)+translationDis;
    femurShaftLocMA = [femurShaftLocMA; item];
end
% the markers
femurShaftLocMarkers = [];
for i = 1:size(markerFemur_start,1)
    item  = markerFemur_start(i,:)+translationDis;
    femurShaftLocMarkers = [femurShaftLocMarkers; item];
end

% figure
% % scatter3(femur_start(:,1),femur_start(:,2),femur_start(:,3),'black'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% scatter3(femurShaftLoc(:,1),femurShaftLoc(:,2),femurShaftLoc(:,3),'red'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% scatter3(SEL_epiShaft(:,1),SEL_epiShaft(:,2),SEL_epiShaft(:,3),'filled');
% scatter3(SEL_pointShaft(:,1),SEL_pointShaft(:,2),SEL_pointShaft(:,3),'filled');
% scatter3(headShaft(:,1),headShaft(:,2),headShaft(:,3),'filled');
% scatter3(isthmusShaft(:,1),isthmusShaft(:,2),isthmusShaft(:,3),'filled');
% plot3([SEL_epiShaft(:,1),SEL_pointShaft(:,1)],[SEL_epiShaft(:,2),SEL_pointShaft(:,2)],[SEL_epiShaft(:,3),SEL_pointShaft(:,3)], 'black', 'Linewidth',1.5) % shaft axis
% plot3([headShaft(:,1),isthmusShaft(:,1)],[headShaft(:,2),isthmusShaft(:,2)],[headShaft(:,3),isthmusShaft(:,3)], 'black', 'Linewidth',1.5) % neck axis
% plot3([0,0],[0,0],[-0.4,0], 'black', 'Linewidth',1.5) % z-axis knee joint


aZY = [SEL_epiShaft(1,2), SEL_epiShaft(1,3)] -[0, 0];
bZY = [0, -0.4]-[0, 0];
angleZY = (acos(dot(aZY, bZY)/(norm(aZY)*norm(bZY))));
Rx = [1 0 0; 0 cos(angleZY) -sin(angleZY); 0 sin(angleZY) cos(angleZY)];

aZX = [SEL_epiShaft(1,1), SEL_epiShaft(1,3)]-[0, 0];
bZX = [0, 0.4]-[0,0];
angleZX = pi - (acos(dot(aZX, bZX)/(norm(aZX)*norm(bZX))));

% the rotation matrix around the y -axis
if strcmp(answerLeg, rightbone) == 1;
    Ry = [cos(angleZX)  0 sin(angleZX); 0 1 0; -sin(angleZX) 0 cos(angleZX)];
else
    %This is for the left femur
    Ry= [cos(-angleZX)  0 sin(-angleZX); 0 1 0; -sin(-angleZX) 0 cos(-angleZX)];
end

R_transfer = Ry*Rx;

% align neck axis with x-axis
tmp=(R_transfer*(headShaft-isthmusShaft)')';
aXY = [tmp(1) tmp(2)];

if strcmp(answerLeg, rightbone) == 1; % right leg
    bXY = [0.4 0];
    angleXY=(acos(dot(aXY, bXY)/(norm(aXY)*norm(bXY))));
    Rz=[cos(angleXY) -sin(angleXY) 0; sin(angleXY) cos(angleXY) 0; 0 0 1];
    
else
    bXY = [-0.4 0];
    angleXY=(acos(dot(aXY, bXY)/(norm(aXY)*norm(bXY))));
    Rz=[cos(-angleXY) -sin(-angleXY) 0; sin(-angleXY) cos(-angleXY) 0; 0 0 1];
end

R_transfer = Rz*Ry*Rx;

% the bone
femurShaftLocRot = [];
for i = 1:size(femur_start,1)
    item  = (R_transfer* femurShaftLoc(i,:)')';
    femurShaftLocRot = [femurShaftLocRot; item];
end

SEL_epiShaftRot = (R_transfer * SEL_epiShaft')';
SEL_pointShaftRot = (R_transfer * SEL_pointShaft')';
headShaftRot = (R_transfer*headShaft')';
isthmusShaftRot = (R_transfer*isthmusShaft')';
% the muscle attachments
femurShaftLocRotMA = [];
for i = 1:size(femurMuscle_start,1)
    item  = (R_transfer* femurShaftLocMA(i,:)')';
    femurShaftLocRotMA = [femurShaftLocRotMA; item];
end

% the markers
femurShaftLocRotMarkers = [];
for i = 1:size(markerFemur_start,1)
    item  = (R_transfer* femurShaftLocMarkers(i,:)')';
    femurShaftLocRotMarkers = [femurShaftLocRotMarkers; item];
end

% figure
% % scatter3(femurShaftLoc(:,1),femurShaftLoc(:,2),femurShaftLoc(:,3),'black'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% scatter3(femurShaftLocRot(:,1),femurShaftLocRot(:,2),femurShaftLocRot(:,3),'filled'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% % scatter3(femurShaftLocRotMA(:,1),femurShaftLocRotMA(:,2),femurShaftLocRotMA(:,3),'blue'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% % scatter3(femurShaftLocRotMarkers(:,1),femurShaftLocRotMarkers(:,2),femurShaftLocRotMarkers(:,3),'blue'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% % scatter3(SEL_epiShaft(:,1),SEL_epiShaft(:,2),SEL_epiShaft(:,3),'green');
% scatter3(SEL_epiShaftRot(:,1),SEL_epiShaftRot(:,2),SEL_epiShaftRot(:,3),'red');
% % scatter3(SEL_pointShaft(:,1),SEL_pointShaft(:,2),SEL_pointShaft(:,3),'green');
% scatter3(SEL_pointShaftRot(:,1),SEL_pointShaftRot(:,2),SEL_pointShaftRot(:,3),'red');
% % scatter3(headShaft(:,1),headShaft(:,2),headShaft(:,3),'green');
% scatter3(headShaftRot(:,1),headShaftRot(:,2),headShaftRot(:,3),'blue');
% scatter3(isthmusShaftRot(1),isthmusShaftRot(2),isthmusShaftRot(3),'blue')
% plot3([headShaftRot(:,1),isthmusShaftRot(1)],[headShaftRot(:,2),isthmusShaftRot(2)],[headShaftRot(:,3),isthmusShaftRot(3)],'red');
% % plot3([SEL_epiShaft(:,1),SEL_pointShaft(:,1)],[SEL_epiShaft(:,2),SEL_pointShaft(:,2)],[SEL_epiShaft(:,3),SEL_pointShaft(:,3)], 'red', 'Linewidth',1.5) % z-axis knee joint
% plot3([SEL_epiShaftRot(:,1),SEL_pointShaftRot(:,1)],[SEL_epiShaftRot(:,2),SEL_pointShaftRot(:,2)],[SEL_epiShaftRot(:,3),SEL_pointShaftRot(:,3)], 'red', 'Linewidth',1.5) % z-axis knee joint
% % plot3([0,0],[0,0],[-0.4,0.1], 'black--', 'Linewidth',1.5) % z-axis knee joint
% % plot3([headShaft(:,1),0],[headShaft(:,2),0],[headShaft(:,3),0], 'black', 'Linewidth',1.5) % z-axis knee joint
% % plot3([headShaftRot(:,1),0],[headShaftRot(:,2),0],[headShaftRot(:,3),0], 'red', 'Linewidth',1.5) % z-axis knee joint

%% Find the rotation boxes of the femur
% innerBox = Femoral Head and neck;
% middleBox = lesser SEL_point and proximal part of the Shaft;
% outerBox = Femur proximal to the condylar;
% Condylar - does not rotate

% the bone
HeadNeck = []; LesserTroc = []; Shaft= [];  Condylar =[];
FemurShaftAxis = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxis = norm(FemurShaftAxis);

for i = 1:size(femurShaftLocRot,1)
    itemVector = femurShaftLocRot(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxis)/magn_FemurShaftAxis;
    if item <= 0.12*(magn_FemurShaftAxis/16)
        HeadNeck= [HeadNeck; femurShaftLocRot(i,:)];
    elseif item  < 1.45*(magn_FemurShaftAxis/16) && item > 0.12*(magn_FemurShaftAxis/16)
        LesserTroc  = [LesserTroc;femurShaftLocRot(i,:)];
    elseif item < 14*(magn_FemurShaftAxis/16) && item > 1*(magn_FemurShaftAxis/16) % limit for the shaft %0.395
        Shaft = [Shaft; femurShaftLocRot(i,:)];
    else
        Condylar = [Condylar; femurShaftLocRot(i,:)];
    end
end

% Divide the shaft into proximal and distalt part
ShaftProx = []; ShaftDist = [];
FemurShaftAxis = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxis = norm(FemurShaftAxis);
for i = 1:size(Shaft,1)
    itemVector = Shaft(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxis)/magn_FemurShaftAxis;
    if item <= 0.5*(magn_FemurShaftAxis/2) % kv: changed from 1 to 0.5 -> smoother
        ShaftProx= [ShaftProx; Shaft(i,:)];
    else
        ShaftDist = [ShaftDist; Shaft(i,:)];
    end
end

% Muscle attachments
HeadNeckMA = []; LesserTrocMA = []; ShaftMA = [];  CondylarMA =[];
FemurShaftAxisMA = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxisMA = norm(FemurShaftAxisMA);
for i = 1:size(femurShaftLocRotMA,1)
    itemVector = femurShaftLocRotMA(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxisMA)/magn_FemurShaftAxisMA;
    if item <= 0.12*(magn_FemurShaftAxisMA/16)
        HeadNeckMA= [HeadNeckMA; femurShaftLocRotMA(i,:)];
    elseif item  < 1.45*(magn_FemurShaftAxisMA/16) && item > 0.12*(magn_FemurShaftAxisMA/16)
        LesserTrocMA  = [LesserTrocMA;femurShaftLocRotMA(i,:)];
    elseif item < 14*(magn_FemurShaftAxisMA/16) && item > (magn_FemurShaftAxisMA/16) % limit for the shaft %0.395
        ShaftMA = [ShaftMA; femurShaftLocRotMA(i,:)];
    else
        CondylarMA = [CondylarMA; femurShaftLocRotMA(i,:)];
    end
end
% Divide the shaft into proximal and distalt part
ShaftProxMA = []; ShaftDistMA = [];
FemurShaftAxisMA = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxisMA = norm(FemurShaftAxisMA);
for i = 1:size(ShaftMA,1)
    itemVector = ShaftMA(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxisMA)/magn_FemurShaftAxisMA;
    if item <= 0.5*(magn_FemurShaftAxis/2)
        ShaftProxMA= [ShaftProxMA; ShaftMA(i,:)];
    else
        ShaftDistMA = [ShaftDistMA; ShaftMA(i,:)];
    end
end

% The markers
HeadNeckMarkers = []; LesserTrocMarkers = []; ShaftMarkers= [];  CondylarMarkers =[];
FemurShaftAxisMarkers = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxisMarkers = norm(FemurShaftAxisMarkers);
for i = 1:size(femurShaftLocRotMarkers,1)
    itemVector = femurShaftLocRotMarkers(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxisMarkers)/magn_FemurShaftAxisMarkers;
    if item <= 0.12*(magn_FemurShaftAxisMarkers/16)
        HeadNeckMarkers= [HeadNeckMarkers; femurShaftLocRotMarkers(i,:)];
    elseif item  < 1.45*(magn_FemurShaftAxisMarkers/16) && item > 0.12*(magn_FemurShaftAxisMarkers/16)
        LesserTrocMarkers  = [LesserTrocMarkers;femurShaftLocRotMarkers(i,:)];
    elseif item < 14*(magn_FemurShaftAxisMarkers/16) && item > (magn_FemurShaftAxisMarkers/16) % limit for the shaft %0.395
        ShaftMarkers = [ShaftMarkers; femurShaftLocRotMarkers(i,:)];
    else
        CondylarMarkers = [CondylarMarkers; femurShaftLocRotMarkers(i,:)];
    end
end
% Divide the shaft into proximal and distalt part
ShaftProxMarkers = []; ShaftDistMarkers = [];
FemurShaftAxisMarkers = SEL_epiShaftRot - SEL_pointShaftRot; %vector from bottom to top
magn_FemurShaftAxisMarkers = norm(FemurShaftAxisMarkers);
for i = 1:size(ShaftMarkers,1)
    itemVector = ShaftMarkers(i,:)-SEL_pointShaftRot; % vector from each point to the max point
    %the projection of vector each vector on the largest vector
    item = dot(itemVector,FemurShaftAxisMarkers)/magn_FemurShaftAxisMarkers;
    if item <= 0.5*(magn_FemurShaftAxisMarkers/2)
        ShaftProxMarkers= [ShaftProxMarkers; ShaftMarkers(i,:)];
    else
        ShaftDistMarkers = [ShaftDistMarkers; ShaftMarkers(i,:)];
    end
end

% figure
% scatter3(HeadNeck(:,1),HeadNeck(:,2),HeadNeck(:,3),'black'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% % scatter3(HeadNeckMA(:,1),HeadNeckMA(:,2),HeadNeckMA(:,3),'red');
% % scatter3(HeadNeckMarkers(:,1),HeadNeckMarkers(:,2),HeadNeckMarkers(:,3),'red');
% scatter3(LesserTroc(:,1),LesserTroc(:,2),LesserTroc(:,3),'blue');
% % scatter3(LesserTrocMA(:,1),LesserTrocMA(:,2),LesserTrocMA(:,3),'red');
% % scatter3(LesserTrocMarkers(:,1),LesserTrocMarkers(:,2),LesserTrocMarkers(:,3),'red');
% scatter3(Shaft(:,1),Shaft(:,2),Shaft(:,3),'black')
% scatter3(ShaftMA(:,1),ShaftMA(:,2),ShaftMA(:,3),'red')
% % scatter3(ShaftMarkers(:,1),ShaftMarkers(:,2),ShaftMarkers(:,3),'red')
% scatter3(Condylar(:,1),Condylar(:,2),Condylar(:,3),'green')
% % scatter3(CondylarMA(:,1),CondylarMA(:,2),CondylarMA(:,3),'red')
% % scatter3(CondylarMarkers(:,1),CondylarMarkers(:,2),CondylarMarkers(:,3),'red')
% % scatter3(SEL_pointShaftRot(:,1),SEL_pointShaftRot(:,2),SEL_pointShaftRot(:,3),'blue');


% figure
% scatter3(ShaftProx(:,1),ShaftProx(:,2),ShaftProx(:,3),'black'); hold on; axis equal; xlabel('x');ylabel('y');zlabel('z')
% % scatter3(ShaftProxMA(:,1),ShaftProxMA(:,2),ShaftProxMA(:,3),'blue');
% % scatter3(ShaftProxMarkers(:,1),ShaftProxMarkers(:,2),ShaftProxMarkers(:,3),'blue');
% scatter3(ShaftDist(:,1),ShaftDist(:,2),ShaftDist(:,3),'red');
% % scatter3(ShaftDistMA(:,1),ShaftDistMA(:,2),ShaftDistMA(:,3),'blue');
% % scatter3(ShaftDistMarkers(:,1),ShaftDistMarkers(:,2),ShaftDistMarkers(:,3),'blue');

%
innerBox = [HeadNeck];
innerBoxMA = [HeadNeckMA]; % the top part of the femur (femoral head and greater SEL_point)
innerBoxMarker = [HeadNeckMarkers];
middleBox = [LesserTroc;ShaftProx]; % the lesser SEL_point and proximal part of the femur
middleBoxMA = [LesserTrocMA; ShaftProxMA];
middleBoxMarker = [LesserTrocMA; ShaftProxMA];
outerBox = [HeadNeck; LesserTroc; Shaft]; % everything except for the condylar
outerBox_less = [ShaftDist;Condylar]; % everything apart form inner and middle box
% rest_Bone_sizeTest = [Shaft_distal; Condyl_NewAxis];
% rest_marker = [ShaftMarker_distal];
%%
% figure('position', [0, 50, 500, 950])
% scatter3(femurShaftLocRot(:,1),femurShaftLocRot(:,2), femurShaftLocRot(:,3),10,'black'); hold on %the femur with the new axis
% scatter3(innerBox(:,1),innerBox(:,2), innerBox(:,3),25,'r', 'Linewidth',2); hold on % red dot at the origin
% scatter3(middleBox(:,1),middleBox(:,2), middleBox(:,3),25,'b', 'Linewidth',2); hold on
% scatter3(outerBox(:,1),outerBox(:,2), outerBox(:,3),40,'g', 'Linewidth',2); hold on
% axis equal; set(gca,'FontSize',16); view(30,-10); grid on; xlabel('x'); ylabel('y'); zlabel('z')

% check the size of everything if it is correct
% femur = size(femur_start)
% femurRot = size(femurShaftLocRot)
% MuscleAttachments = size(femurMuscle_start)
% MARot = size(femurShaftLocRotMA)
% Markers = size(markerFemur_start)
% MarkersRot = size(femurShaftLocRotMarkers)

