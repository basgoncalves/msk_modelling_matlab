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

function [TibiaMuscles, TibiaPlace1, TibiaNR, CalcnMuscles, CalcnPlace1, CalcnNR, ToesMuscles, ToesPlace1, ToesNR ] = tibia_MA(dataModel, answerLeg, rightbone)
%%
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;
if strcmp(answerLeg, rightbone) == 1;
    CalcnMA = 'calcn_r';
    ToesMA = 'toes_r';
    TibiaMA = 'tibia_r';
else
    CalcnMA = 'calcn_l';
    ToesMA = 'toes_l';
    TibiaMA = 'tibia_l';
end
% find the muscle attachments and create a matrix with the muscles on the tibia, talus, calcn, toes
CalcnMuscles = []; CalcnPlace1 = {}; CalcnNR = [];
ToesMuscles = []; ToesPlace1 = {}; ToesNR = [];
TibiaMuscles = []; TibiaPlace1 = {}; TibiaNR = [];
%No muscle attachments on the talus
for i = 1:size(muscles,2)
    AttachmentSize = size(struct2cell(dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle{1,i}.GeometryPath.PathPointSet.objects),1);
    if AttachmentSize == 1
        MuscleAttachments1 = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        if (i == 28 )||(i == 71)
            CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_calcn == 1;
                CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                CalcnNR = [CalcnNR; i];
                place1 = sprintf('PathPoint');
                CalcnPlace1 = [CalcnPlace1;place1];
            end
            CompareStrings_toes = strcmp(ToesMA, MuscleAttachments1.body.Text);
            if CompareStrings_toes == 1;
                ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                ToesNR = [ToesNR; i];
                place1_toes = sprintf('PathPoint');
                ToesPlace1 = [ToesPlace1;place1_toes];
            end
            CompareStrings_tibia = strcmp(TibiaMA, MuscleAttachments1.body.Text);
            if CompareStrings_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('PathPoint');
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
        else
            for ii = 1:size(MuscleAttachments1,2)
                CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_calcn == 1;
                    CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    CalcnNR = [CalcnNR; i];
                    place1 = sprintf('PathPoint{1,%d}',ii);
                    CalcnPlace1 = [CalcnPlace1;place1];
                end
                CompareStrings_toes = strcmp(ToesMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_toes == 1;
                    ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    ToesNR = [ToesNR; i];
                    place1_toes = sprintf('PathPoint{1,%d}',ii);
                    ToesPlace1 = [ToesPlace1;place1_toes];
                end
                CompareStrings_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_tibia == 1;
                    TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    TibiaNR = [TibiaNR; i];
                    place1_tibia = sprintf('PathPoint{1,%d}',ii);
                    TibiaPlace1 = [TibiaPlace1;place1_tibia];
                end
            end
        end
    elseif AttachmentSize ==2
        MuscleAttachments1 = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        if size(MuscleAttachments1) == 1; %(i == 28 )||(i == 71)
            CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_calcn == 1;
                CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                CalcnNR = [CalcnNR; i];
                place1 = sprinf('PathPoint');
                CalcnPlace1 = [CalcnPlace1;place1];
            end
            CompareStrings_toes = strcmp(ToesMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_toes == 1;
                ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                ToesNR = [ToesNR; i];
                place1_toes = sprintf('PathPoint');
                ToesPlace1 = [ToesPlace1;place1_toes];
            end
            CompareStrings_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('PathPoint');
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
        else
            for ii = 1:size(MuscleAttachments1,2)
                CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_calcn == 1;
                    CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    CalcnNR = [CalcnNR; i];
                    place1 = sprintf('PathPoint{1,%d}',ii);
                    CalcnPlace1 = [CalcnPlace1;place1];
                end
                CompareStrings_toes = strcmp(ToesMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_toes == 1;
                    ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    ToesNR = [ToesNR; i];
                    place1_toes = sprintf('PathPoint{1,%d}',ii);
                    ToesPlace1 = [ToesPlace1;place1_toes];
                end
                CompareStrings_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_tibia == 1;
                    TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    TibiaNR = [TibiaNR; i];
                    place1_tibia = sprintf('PathPoint{1,%d}',ii);
                    TibiaPlace1 = [TibiaPlace1;place1_tibia];
                end
                
            end
        end
        MuscleAttachments2 = muscles{1,i}.GeometryPath.PathPointSet.objects.ConditionalPathPoint;
        if size(MuscleAttachments2) == 1;%(i == 29)
            CompareStrings2_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments2.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings2_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments2.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('ConditionalPathPoint');
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
            
        else
            for ii = 1:size(MuscleAttachments2,2)
                CompareStrings2_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments2{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings2_tibia == 1;
                    TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments2{1,ii}.location.Text)];
                    TibiaNR = [TibiaNR; i];
                    place1_tibia = sprintf('ConditionalPathPoint{1,%d}',ii);
                    TibiaPlace1 = [TibiaPlace1;place1_tibia];
                end
            end
        end
    elseif AttachmentSize ==3
        MuscleAttachments1 = muscles{1,i}.GeometryPath.PathPointSet.objects.PathPoint;
        if (i == 28 )||(i == 71)
            CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_calcn == 1;
                CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                CalcnNR = [CalcnNR; i];
                place1 = sprinf('PathPoint');
                CalcnPlace1 = [CalcnPlace1;place1];
            end
            CompareStrings_toes = strcmp(ToesMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_toes == 1;
                ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                ToesNR = [ToesNR; i];
                place1_toes = sprintf('PathPoint');
                ToesPlace1 = [ToesPlace1;place1_toes];
            end
            CompareStrings_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments1.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1.PathPoint.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('PathPoint');
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
        else
            for ii = 1:size(MuscleAttachments1,2)
                CompareStrings_calcn = strcmp(CalcnMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_calcn == 1;
                    CalcnMuscles = [CalcnMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    CalcnNR = [CalcnNR; i];
                    place1 = sprinf('PathPoint{i,%d}',ii);
                    CalcnPlace1 = [CalcnPlace1;place1];
                end
                CompareStrings_toes = strcmp(ToesMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_toes == 1;
                    ToesMuscles = [ToesMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    ToesNR = [ToesNR; i];
                    place1_toes = sprintf('PathPoint{1,%d}',ii);
                    ToesPlace1 = [ToesPlace1;place1_toes];
                end
                CompareStrings_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments1{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                if CompareStrings_tibia == 1;
                    TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments1{1,ii}.location.Text)];
                    TibiaNR = [TibiaNR; i];
                    place1_tibia = sprintf('PathPoint{1,%d}',ii);
                    TibiaPlace1 = [TibiaPlace1;place1_tibia];
                end
            end
        end
        MuscleAttachments2 = muscles{1,i}.GeometryPath.PathPointSet.objects.ConditionalPathPoint;
        if (i == 29)||(i == 31)||(i == 72)||(i == 74)
            CompareStrings2_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments2{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings2_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments2{1,ii}.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('ConditionalPathPoint{1,%d}',ii);
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
        else
            CompareStrings2_tibia = strcmp(TibiaMA, regexprep(MuscleAttachments2.socket_parent_frame.Text,'/bodyset/',''));
            if CompareStrings2_tibia == 1;
                TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments2.location.Text)];
                TibiaNR = [TibiaNR; i];
                place1_tibia = sprintf('ConditionalPathPoint');
                TibiaPlace1 = [TibiaPlace1;place1_tibia];
            end
        end
        MuscleAttachments3 = muscles{1,i}.GeometryPath.PathPointSet.objects.MovingPathPoint;
        CompareStrings3 = strcmp(TibiaMA, regexprep(MuscleAttachments3.socket_parent_frame.Text,'/bodyset/',''));
        if CompareStrings3 == 1;
            TibiaMuscles = [TibiaMuscles; str2num(MuscleAttachments3.location.Text)];
            TibiaNR = [TibiaNR; i];
            place1_tibia = sprintf('MovingPathPoint');
            TibiaPlace1 = [TibiaPlace1;place1_tibia];
        end
    end
end