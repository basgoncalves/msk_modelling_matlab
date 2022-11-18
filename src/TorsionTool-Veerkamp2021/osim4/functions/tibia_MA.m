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
% The muscle attachments for the tibia are put in one matrix.
% ----------------------------------------------------------------------- %

function [TibiaMuscles, TibiaPlace, TibiaNR, CalcnMuscles, CalcnPlace, CalcnNR, ToesMuscles, ToesPlace, ToesNR ] = tibia_MA(dataModel, answerLeg)
%%
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;

CalcnMA = ['calcn_' lower(answerLeg)];
ToesMA = ['toes_' lower(answerLeg)];
TibiaMA = ['tibia_' lower(answerLeg)];
FemurMA = ['femur_' lower(answerLeg)];

% find the muscle attachments and create a matrix with the muscles on the tibia, talus, calcn, toes
% Muscles = coordinates of muscle attachements
% Place = path points
% NR = number of attachments
ToesMuscles = []; ToesPlace = {}; ToesNR = [];
CalcnMuscles = []; CalcnPlace = {}; CalcnNR = [];
TibiaMuscles = []; TibiaPlace = {}; TibiaNR = [];
FemurMuscle = []; FemurPlace1 = {}; FemurNR = [];

muscles_with_attachments = {};
location_attachments = {};
for i = 1:size(muscles,2)
    muscles_with_attachments{i,1}   = muscles{1,i}.Attributes.name;
    location_attachments{i,1}       = muscles{1,i}.Attributes.name;

     MuscleAttachments = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;

    if size(MuscleAttachments,2) == 1
        body = strtrim(regexprep(MuscleAttachments.socket_parent_frame.Text,'/bodyset/',''));
        muscles_with_attachments{i,2}  = body;
        location_attachments{i,2} = str2num(MuscleAttachments.location.Text);

    else
        for ii = 1:size(MuscleAttachments,2)
            body = strtrim(regexprep(MuscleAttachments{1,ii}.socket_parent_frame.Text,'/bodyset/',''));   
            muscles_with_attachments{i,1+ii}  = body;
            location_attachments{i,1+ii} = str2num(MuscleAttachments{1,ii}.location.Text);
        end
    end
    emptyCells = cellfun(@isempty,muscles_with_attachments(i,:));
    muscles_with_attachments(i,emptyCells) = {'-'};

    [TibiaMuscles,TibiaNR,TibiaPlace] = find_muscle_path(TibiaMA,TibiaMuscles,TibiaNR,TibiaPlace);
    [CalcnMuscles,CalcnNR,CalcnPlace] = find_muscle_path(CalcnMA,CalcnMuscles,CalcnNR,CalcnPlace);
    [ToesMuscles,ToesNR,ToesPlace] = find_muscle_path(ToesMA,ToesMuscles,ToesNR,ToesPlace);
    [FemurMuscle,FemurNR,FemurPlace1] = find_muscle_path(FemurMA,FemurMuscle,FemurNR,FemurPlace1);
end


    function [location,number_attachments,name_attachments] = find_muscle_path(body_name,location,number_attachments,name_attachments)

        [~,Cells] = find(contains(muscles_with_attachments(i,:),body_name));                                         % Tibia
        for t = Cells
            location            = [location; location_attachments{i,t}];
            number_attachments  = [number_attachments; i];
            pathPoint           = sprintf('PathPoint{1,%d}',t);
            name_attachments    = [name_attachments;pathPoint];
        end
    end

end
