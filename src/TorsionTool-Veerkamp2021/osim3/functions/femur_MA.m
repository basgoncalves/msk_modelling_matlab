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
% The muscle attachments for the femur are put in one matrix.
% ----------------------------------------------------------------------- %

function [femurMuscle, femurPlace1, femurNR] = femur_MA(dataModel,answerLeg)
%%
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;

femurMA = ['femur_' lower(answerLeg)];

% find the muscle attachments and create a matrix with the muscles on femur
femurMuscle = []; femurPlace1 = {}; femurNR = [];

muscles_with_attachments = {};
location_attachments = {};
for i = 1:size(muscles,2)
    muscles_with_attachments{i,1}   = muscles{1,i}.Attributes.name;
    location_attachments{i,1}       = muscles{1,i}.Attributes.name;

    MuscleAttachments1 = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;

    if size(MuscleAttachments1) == 1
        body = strtrim(MuscleAttachments1.body.Text);
        muscles_with_attachments{i,2}  = body;
        location_attachments{i,2} = str2num(MuscleAttachments1.location.Text);

    else
        for ii = 1:size(MuscleAttachments1,2)
            body = strtrim(MuscleAttachments1{1,ii}.body.Text);
            muscles_with_attachments{i,1+ii}  = body;
            location_attachments{i,1+ii} = str2num(MuscleAttachments1{1,ii}.location.Text);
        end
    end
    emptyCells = cellfun(@isempty,muscles_with_attachments(i,:));
    muscles_with_attachments(i,emptyCells) = {'-'};

    [~,Cells] = find(contains(muscles_with_attachments(i,:),femurMA));                                              % femur
    for t = Cells
        femurMuscle    = [femurMuscle; location_attachments{i,t}];
        femurNR         = [femurNR; i];
        pathPoint       = sprintf('PathPoint{1,%d}',t);
        femurPlace1     = [femurPlace1;pathPoint];
    end
end


