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
% make model with personalised torsions
%   inputs:
% answerModel = %i.e. gait2392_simbody.osim
% deformed_model = % string
% answerMarkerset =  % string
% which_leg = % string (L or R)
% angle = % in degrees
function [ ready ] = make_PEmodel( answerModel, deformed_model, answerMarkerSet, deform_bone, which_leg, angle, angle_NS)


% the path to save the deformed model
place = [cd '\DEFORMED_MODEL\'];

% what model you want to deform
if strcmp(which_leg, 'R') == 1 &&  strcmp(deform_bone, 'F') == 1;
        answerModel_tmp = [ answerModel];
        answerMarkerSet_tmp = [ answerMarkerSet];
else
    answerModel_tmp = [place answerModel];
    answerMarkerSet_tmp = [place answerMarkerSet];
end
dataModel = xml2struct(answerModel_tmp);

% what you want to name the deformed model
answerNameModel = deformed_model;

% the marker set for this model.
markerset = xml2struct(answerMarkerSet_tmp);
answerLegFemur = which_leg;
answerDegFemur = angle;

bone = 'T';
if strcmp(deform_bone, bone) == 1; % Rotation of the tibia
    % Ask the user if they want to rotate the left or right leg.
    
    answerLegTibia = which_leg;
    % Ask the user how large the torsion angle is.
    
    answerDegTibia = angle;
    rightboneTibia = 'R';
    if strcmp(answerLegTibia, rightboneTibia) == 1;
        %Right torsion angle is defined for the rotation
        TT_angle = -(answerDegTibia*(pi/180));
        % the geometry of the right calcn, talus and toes is imported
        dataTibia = xml2struct('tibia/tibia.xml');
        dataCalcn = xml2struct('calcn/foot.xml');
        dataTalus = xml2struct('talus/talus.xml');
        dataToes = xml2struct('toes/bofoot.xml');
    else
        %The left torsion angle is defined for the rotation
        TT_angle = answerDegTibia*(pi/180);
        % the geometry of the left calcn, talus and toes are imported
        dataTibia = xml2struct('tibia/l_tibia.xml');
        dataCalcn = xml2struct('calcn/l_foot.xml');
        dataTalus = xml2struct('talus/l_talus.xml');
        dataToes = xml2struct('toes/l_bofoot.xml');
    end
    % the script for the rotation of the tibia is called
    tibia(dataModel, markerset, answerLegTibia, rightboneTibia, TT_angle,...
        answerNameModel, answerMarkerSet, dataTibia, dataCalcn, dataTalus,...
        dataToes, place)
    %rotation of the femur
else
    
    % femoral anteversion
    if strcmp(answerLegFemur, 'R') == 1; % Rotation of the right foot
        FA_preAngle = 17.6;
        NS_preAngle = 123.3;
        % The added anteversion angle is definded
        angleCorrection = answerDegFemur - FA_preAngle;
        FA_angle = -(angleCorrection*(pi/180));
        NS_angle = -((angle_NS-NS_preAngle)*(pi/180));
        % The geomerty of the right femur is imported
        dataFemur = xml2struct('femur/femur.xml');
    else % Rotation of the left foot
        FA_preAngle = 17.6;
        NS_preAngle = 123.3;
        % The added anteversion angle is definded
        angleCorrection = answerDegFemur - FA_preAngle;
        FA_angle = angleCorrection*(pi/180);
        NS_angle = ((angle_NS-NS_preAngle)*(pi/180));
        % The geometry of the left femur is imported
        dataFemur = xml2struct('femur/l_femur.xml');
    end
    % the script for the rotation of the femur is called.
    femur_ns(dataModel, markerset, answerLegFemur, 'R', FA_angle, NS_angle,...
        answerNameModel,answerMarkerSet, dataFemur, place);
    
    
    
end
