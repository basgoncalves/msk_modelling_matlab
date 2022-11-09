
function [TibiaMuscles, TibiaPlace1, TibiaNR, CalcnMuscles, CalcnPlace1, CalcnNR, ToesMuscles, ToesPlace1, ToesNR ] = tibia_MA(dataModel, answerLeg)
%%
muscles = dataModel.OpenSimDocument.Model.ForceSet.objects.Thelen2003Muscle;

CalcnMA = ['calcn_' lower(answerLeg)];
ToesMA = ['toes_' lower(answerLeg)];
TibiaMA = ['tibia_' lower(answerLeg)];

% find the muscle attachments and create a matrix with the muscles on the tibia, talus, calcn, toes
CalcnMuscles = []; CalcnPlace1 = {}; CalcnNR = [];
ToesMuscles = []; ToesPlace1 = {}; ToesNR = [];
TibiaMuscles = []; TibiaPlace1 = {}; TibiaNR = [];

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


    [~,ToesCells] = find(contains(muscles_with_attachments(i,:),ToesMA));                                           % Toes
    for t = ToesCells
        ToesMuscles     = [ToesMuscles; location_attachments{i,t}];
        ToesNR          = [ToesNR; i];
        pathPoint       = sprintf('PathPoint{1,%d}',t);
        ToesPlace1      = [ToesPlace1;pathPoint];
    end

    [~,CalcnCells] = find(contains(muscles_with_attachments(i,:),CalcnMA));                                         % Calcn
    for t = CalcnCells
        CalcnMuscles    = [CalcnMuscles; location_attachments{i,t}];
        CalcnNR         = [CalcnNR; i];
        pathPoint       = sprintf('PathPoint{1,%d}',t);
        CalcnPlace1     = [CalcnPlace1;pathPoint];
    end

    [~,TibiaCells] = find(contains(muscles_with_attachments(i,:),TibiaMA));                                         % Tibia
    for t = TibiaCells
        TibiaMuscles    = [TibiaMuscles; location_attachments{i,t}];
        TibiaNR         = [TibiaNR; i];
        pathPoint       = sprintf('PathPoint{1,%d}',t);
        TibiaPlace1     = [TibiaPlace1;pathPoint];
    end

end


