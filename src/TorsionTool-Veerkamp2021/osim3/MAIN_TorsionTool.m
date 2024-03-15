%-------------------------------------------------------------------------%
% Copyright (c) 2021 % Kirsten Veerkamp, Hans Kainz, Bryce A. Killen,     %
%    Hulda J�nasd�ttir, Marjolein M. van der Krogt     		              %
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
%%%  main script to create opensim model with personalised geometries   %%%
% Give the subject-specific femoral anteversion (AV) and neck-shaft (NS) angles,
% 	as well as the tibial torsion (TT) angles, as input for the right and left leg.
% 	Lines which require these inputs are indicated by a % at the end of the line.
% The final model with personalised torsions is saved in the DEFORMED_MODEL
% 	folder, and is called FINAL_PERSONALISEDTORSIONS.osim.
% 	The adjusted markerset can also be found in this folder.
% 
% note1: The angle definitions for AV and TT are as follows:
% 	- AV: positive: femoral anteversion; negative: femoral retroversion.
% 	- TT: positive: external rotation; negative: internal rotation.
% note2: Adjust the MarkerSet.xml in the main folder to your marker set,
% 	when using markers for the greater trochanter (when adjusting
% 	femur) and/or when using markers on the feet (when adjusting tibia).
% note3: If you only wish to adjust the femoral geometry (and not the tibial
% 	torsion), set the input to the tibial torsion to 0 degrees (=default
% 	tibial torsion in generic femur).
% ----------------------------------------------------------------------- %

clear; clc; close all;                                                                                              % clean workspace (use restoredefaultpath if needed) by Basilio Goncalves
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
ToolDir  = fileparts(activeFile.Filename);                                                                          
addpath(genpath(ToolDir));                     
cd(ToolDir);

% clear all;close all
% mfile_name = mfilename('fullpath');
% [pathstr,name,ext] = fileparts(mfile_name);
% cd(pathstr);
% addpath(genpath(pwd))

%% right femur 
model = 'gait2392_genericsimpl.osim'; 
markerset = 'MarkerSet.xml'; 

deform_bone = 'F'; 
which_leg = 'R'; 
angle_AV_right = 18; % left anteversion angle (in degrees) - default 17.6
angle_NS_right = 123; % left neck-shaft angle (in degrees) - default 123.3
deformed_model = ['rightNSA' num2str(angle_NS_right) '_rightAVA' num2str(angle_AV_right) ];

make_PEmodel( model, deformed_model, markerset, deform_bone, which_leg, angle_AV_right, angle_NS_right);

%% left femur
model = [deformed_model '.osim']; 
markerset = [deformed_model '_' markerset]; 

deform_bone = 'F'; 
which_leg = 'L'; 
angle_AV_left = 18; % left anteversion angle (in degrees) - default 17.6
angle_NS_left = 123; % left neck-shaft angle (in degrees) - default 123.3
deformed_model = [ 'leftNSA' num2str(angle_NS_left) '_leftAVA' num2str(angle_AV_left)]; 
make_PEmodel( model, deformed_model, markerset, deform_bone, which_leg, angle_AV_left, angle_NS_left);

%% right tibia
% model = [deformed_model '.osim']; 
% markerset = [deformed_model '_' markerset]; 

model = 'gait2392_genericsimpl.osim'; 
markerset = 'MarkerSet.xml'; 

deformed_model = 'RT15'; 
deform_bone = 'T'; 
which_leg = 'R';
angle_TT_right = -30; % right tibial torsion angle (in degrees) % generic = 0 degrees
deformed_model = [ 'rightTT' num2str(angle_TT_right) ];

make_PEmodel( model, deformed_model, markerset, deform_bone, which_leg, angle_TT_right);

%% left tibia
model = [deformed_model '.osim']; 
markerset = [deformed_model '_' markerset]; 

deformed_model = 'LT5';
deform_bone = 'T';
which_leg = 'L'; 
angle_TT_left = 0; % left tibial torsion angle (in degrees) %
deformed_model = [ 'leftTT' num2str(angle_TT_left) ];

make_PEmodel( model, deformed_model, markerset, deform_bone, which_leg, angle_TT_left);

