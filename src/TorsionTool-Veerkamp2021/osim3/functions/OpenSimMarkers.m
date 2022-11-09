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
% Find the markers attached to the femur & tibia in the marker setup
% --------------------------------------------------------------------


function [markerCalcn, markerTibia, markerCalcnNR, markerTibiaNR, markerFemur, markerFemurNR] = OpenSimMarkers(markerset, answerLeg, rightbone)

%find the markers for each bone for the lower extremities
markerSize = size(markerset.OpenSimDocument.MarkerSet.objects.Marker,2);
markerCalcn = []; markerTibia = []; markerCalcnNR = []; markerTibiaNR = []; markerFemur = []; markerFemurNR = [];
if strcmp(answerLeg, rightbone) == 1;
    for i = 1:markerSize
        bonepart = markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.body.Text;
        if strcmp(bonepart, ' calcn_r ') == 1
            markerCalcn = [markerCalcn; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerCalcnNR = [markerCalcnNR; i];
        elseif strcmp(bonepart, ' tibia_r ') == 1
            markerTibia = [markerTibia; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerTibiaNR = [markerTibiaNR; i];
        elseif strcmp(bonepart, ' femur_r ') == 1
            markerFemur = [markerFemur; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerFemurNR = [markerFemurNR; i];
        end
    end
else
    for i = 1:markerSize
        bonepart = markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.body.Text;
        if strcmp(bonepart, ' calcn_l ') == 1
            markerCalcn = [markerCalcn; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerCalcnNR = [markerCalcnNR; i];
        elseif strcmp(bonepart, ' tibia_l ') == 1
            markerTibia = [markerTibia; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerTibiaNR = [markerTibiaNR; i];
        elseif strcmp(bonepart, ' femur_l ') == 1
            markerFemur = [markerFemur; str2num(markerset.OpenSimDocument.MarkerSet.objects.Marker{1,i}.location.Text)];
            markerFemurNR = [markerFemurNR; i];
        end
    end
end





