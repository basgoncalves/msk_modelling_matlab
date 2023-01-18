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

function [Tibia_c, Tibia_pp, Tibia_na, Calcn_c, Calcn_pp, Calcn_na,...
    Toes_c, Toes_pp, Toes_na, Femur_c, Femur_pp, Femur_na,muscle_names] = get_muscle_attachments (dataModel, answerLeg)
%%
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;

CalcnMA = ['calcn_' lower(answerLeg)];
ToesMA = ['toes_' lower(answerLeg)];
TibiaMA = ['tibia_' lower(answerLeg)];
FemurMA = ['femur_' lower(answerLeg)];

% find the muscle attachments and create a matrix with the muscles on the tibia, talus, calcn, toes
% XX_names  = name of muscles; 
% XX_c      = coordinates of muscle attachements
% XX_pp     = path points
% XX_na     = number of attachments
Toes_names  = {}; Toes_c  = []; Toes_pp  = {}; Toes_na  = [];
Calcn_names = {}; Calcn_c = []; Calcn_pp = {}; Calcn_na = [];
Tibia_names = {}; Tibia_c = []; Tibia_pp = {}; Tibia_na = [];
Femur_names = {}; Femur_c = []; Femur_pp = {}; Femur_na = [];

muscles_with_attachments = {};
location_attachments = {};
type_paths = {'PathPoint', 'ConditionalPathPoint', 'MovingPathPoint'};
for iType = 1:length(type_paths)
    type_path = type_paths{iType};

    for iMuscle = 1:size(muscles,2)
        muscles_with_attachments{iMuscle,1}   = muscles{1,iMuscle}.Attributes.name;
        location_attachments{iMuscle,1}       = muscles{1,iMuscle}.Attributes.name;

        try
            allocate_muscle_paths
        end
    end
end

muscle_names = struct;
muscle_names.Toes  = Toes_names;
muscle_names.Calcn = Calcn_names;
muscle_names.Tibia = Tibia_names;
muscle_names.Femur = Femur_names;

%%====================================== callback functions ==================================% 
    function allocate_muscle_paths

        [muscles_with_attachments,location_attachments] = ...
            find_muscle_attachements(muscles_with_attachments,location_attachments);
        try
            [Tibia_c,Tibia_na,Tibia_pp,Tibia_names] = ...
                find_muscle_path(type_path,TibiaMA,Tibia_c,Tibia_na,Tibia_pp,Tibia_names);
        end

        try
            [Calcn_c,Calcn_na,Calcn_pp,Calcn_names] = ...
                find_muscle_path(type_path,CalcnMA,Calcn_c,Calcn_na,Calcn_pp,Calcn_names);
        end

        try
            [Toes_c,Toes_na,Toes_pp,Toes_names]     = ...
                find_muscle_path(type_path,ToesMA,Toes_c,Toes_na,Toes_pp,Toes_names);
        end

        try
            [Femur_c,Femur_na,Femur_pp,Femur_names] = ...
                find_muscle_path(type_path,FemurMA,Femur_c,Femur_na,Femur_pp,Femur_names);
        end
    end
%=============================================================================================%
    function [muscles_with_attachments,location_attachments] = ...
                find_muscle_attachements(muscles_with_attachments,location_attachments)

         MuscleAttachments = muscles{1,iMuscle}.GeometryPath.PathPointSet.objects.(type_path);

         if size(MuscleAttachments,2) == 1
            body = strtrim(regexprep(MuscleAttachments.socket_parent_frame.Text,'/bodyset/',''));
            muscles_with_attachments{iMuscle,2}  = body;
            location_attachments{iMuscle,2} = str2num(MuscleAttachments.location.Text);

        else
            for ii = 1:size(MuscleAttachments,2)
                body = strtrim(regexprep(MuscleAttachments{1,ii}.socket_parent_frame.Text,'/bodyset/',''));
                muscles_with_attachments{iMuscle,1+ii}  = body;
                location_attachments{iMuscle,1+ii} = str2num(MuscleAttachments{1,ii}.location.Text);
            end
        end
        emptyCells = cellfun(@isempty,muscles_with_attachments(iMuscle,:));
        muscles_with_attachments(iMuscle,emptyCells) = {'-'};

    end
%=============================================================================================%
    function [location,number_attachments,cell_attachments,muscles_name] = find_muscle_path...
            (type_path, body_name,location,number_attachments,cell_attachments,muscles_name)

        MuscleAttachments = muscles{1,iMuscle}.GeometryPath.PathPointSet.objects.(type_path);

        [~,col_contains_body] = find(contains(muscles_with_attachments(iMuscle,:),body_name));
        
        % just here for debuging (clear when code works perfectly)
        if contains(body_name,'calc') && ~isempty(col_contains_body)
            a=1; 
        end
      
        % if there is more than one muscle attachment find the one that contains the curent body
        if size(MuscleAttachments,2) > 1 
            for ii = 1:size(MuscleAttachments,2)
               if contains(MuscleAttachments{ii}.socket_parent_frame.Text, body_name)
                    MuscleAttachments = MuscleAttachments{ii};
                    break
               end
            end
        end


        if contains(MuscleAttachments.socket_parent_frame.Text, body_name)
            for t = col_contains_body
                muscles_name        = [muscles_name; muscles_with_attachments{iMuscle,1}];
                location            = [location; location_attachments{iMuscle,t}];
                number_attachments  = [number_attachments; iMuscle];

                % to be used in 'Model.muscles.GeometryPath.PathPointSet.objects.(1).pathPoint{1,%d}'
                pathPoint           = sprintf('%s{1,%d}',type_path,t-1);
                cell_attachments    = [cell_attachments;pathPoint];
            end
        end
    end

end
