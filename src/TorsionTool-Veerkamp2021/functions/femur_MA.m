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

function [femurMuscle, femurPlace1, femurNR] = femur_MA(dataModel, answerLeg, rightbone)

%% Find the muscles in the model
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;
%Identify the left and right leg
if strcmp(answerLeg, rightbone) == 1;
    femurMA = 'femur_r';
else
    femurMA = 'femur_l';
end

femurMuscle =[];
femurPlace1 = {};
femurNR = [];
for i = 1:size(muscles,2)
    % The attachments are found depending on how many types of attachments there are for each muscle, the for loop is devided into 3 part.
    AttachmentSize = size(struct2cell(dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,i}.GeometryPath.PathPointSet.objects),1);
    % if the muscle only has pathpoints
    if AttachmentSize == 1
        MuscleAttachments1_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        for ii = 1:size(MuscleAttachments1_femur,2)
            CompareStrings1_femur = strcmp(femurMA, MuscleAttachments1_femur{1,ii}.body.Text);
            if CompareStrings1_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments1_femur{1,ii}.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('PathPoint{1,%d}',ii);
                femurPlace1 = [femurPlace1;place1];
            end
        end
        % if the muscle has pathpoints and conditional path points
    elseif AttachmentSize ==2
        % The muscle attachemtns of the type pathpoint
        MuscleAttachments1_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        for ii = 1:size(MuscleAttachments1_femur,2)
            CompareStrings1_femur = strcmp(femurMA, MuscleAttachments1_femur{1,ii}.body.Text);
            if CompareStrings1_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments1_femur{1,ii}.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('PathPoint{1,%d}',ii);
                femurPlace1 = [femurPlace1;place1];
            end
        end
        % The muscle attachment of the type conditional path point
        MuscleAttachments2_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.ConditionalPathPoint;
        if size(MuscleAttachments2_femur) == 1;
            CompareStrings2_femur = strcmp(femurMA, MuscleAttachments2_femur.body.Text);
            if CompareStrings2_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments2_femur.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('ConditionalPathPoint');
                femurPlace1 = [femurPlace1;place1];
            end
        else
            for ii = 1:size(MuscleAttachments2_femur,2)
                CompareStrings2_femur = strcmp(femurMA, MuscleAttachments2_femur{1,ii}.body.Text);
                if CompareStrings2_femur == 1;
                    femurMuscle = [femurMuscle; str2num(MuscleAttachments2_femur{1,ii}.location.Text)];
                    femurNR = [femurNR; i];
                    place1 = sprintf('ConditionalPathPoint{1,%d}',ii);
                    femurPlace1 = [femurPlace1;place1];
                end
            end
        end
        % if the msucle has pathpoints, conditional path point and moving
        % path point
    elseif AttachmentSize == 3
        %The muscle attachments of the type pathpoint
        MuscleAttachments1_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        % for the muscle that only have one pathpoint
        if size(MuscleAttachments1_femur) == 1;
            CompareStrings1_femur = strcmp(femurMA, MuscleAttachments1_femur.body.Text);
            if CompareStrings1_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments1_femur.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('PathPoint');
                femurPlace1 = [femurPlace1;place1];
            end
        % for the muscle that have more than one pathpoint
        else
            for ii = 1:size(MuscleAttachments1_femur,2)
                CompareStrings1_femur = strcmp(femurMA, MuscleAttachments1_femur{1,ii}.body.Text);
                if CompareStrings1_femur == 1;
                    femurMuscle = [femurMuscle; str2num(MuscleAttachments1_femur{1,ii}.location.Text)];
                    femurNR = [femurNR; i];
                    place1 = sprintf('PathPoint{1,%d}',ii);
                    femurPlace1 = [femurPlace1;place1];
                end
            end
        end
        %The muscle attachments of the type conditional path point
        MuscleAttachments2_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.ConditionalPathPoint;
        %The muscles that only have one conditional path point
        if size(MuscleAttachments2_femur) == 1
            CompareStrings2_femur = strcmp(femurMA, MuscleAttachments2_femur.body.Text);
            if CompareStrings2_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments2_femur.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('ConditionalPathPoint');
                femurPlace1 = [femurPlace1;place1];
            end   
        % The muscle that have more than one conditional path point
        else
            for ii = 1:size(MuscleAttachments2_femur,2)
                CompareStrings2_femur = strcmp(femurMA, MuscleAttachments2_femur{1,ii}.body.Text);
                if CompareStrings2_femur == 1;
                    femurMuscle = [femurMuscle; str2num(MuscleAttachments2_femur{1,ii}.location.Text)];
                    femurNR = [femurNR; i];
                    place1 = sprintf('ConditionalPathPoint{1,%d}',ii);
                    femurPlace1 = [femurPlace1;place1];
                end
            end
        end
        % The muscle attachments of the type moveing path points
        MuscleAttachments3_femur = muscles{1,i}.GeometryPath.PathPointSet.objects.MovingPathPoint;
        % The muscles with one moveing pathpoint 
        if size(MuscleAttachments3_femur) == 1
            CompareStrings3_femur = strcmp(femurMA, MuscleAttachments3_femur.body.Text);
            if CompareStrings3_femur == 1;
                femurMuscle = [femurMuscle; str2num(MuscleAttachments3_femur.location.Text)];
                femurNR = [femurNR; i];
                place1 = sprintf('MovingPathPoint');
                femurPlace1 = [femurPlace1;place1];
            end
        % The muscles with more than one moving path point 
        else
            for ii = 1:size(MuscleAttachments3_femur,2)
                CompareStrings3_femur = strcmp(femurMA, MuscleAttachments3_femur{1,ii}.body.Text);
                if CompareStrings3_femur == 1;
                    femurMuscle = [femurMuscle; str2num(MuscleAttachments3_femur{1,ii}.location.Text)];
                    femurNR = [femurNR; i];
                    place1 = sprintf('MovingPathPoint{1,%d}',ii);
                    femurPlace1 = [femurPlace1;place1];
                end
            end
        end
    end
end
disp('The muscle attachments have been rotated')