
% splitGroupsFAI
function [Subjects,Groups,Weights,Intra] = splitGroupsFAI(DirDemorgraphics,Study)

cd(DirDemorgraphics);
warning on
getDemographicsFAI(DirDemorgraphics);
load(['demographics.mat']);

labelsDemographics = demographics(2,:);

SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(1:end,SubjectCol);
WeightCol = find(strcmp(labelsDemographics,'Weight'));
WeightGroup = demographics(1:end,WeightCol);

lastRow = find(contains(SubjectCodes,{'Mean'}));

Studyrows = find(contains(demographics(1:lastRow-1,strcmp(labelsDemographics,Study)),{'Yes'}));

GroupCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Group'));
CONrows = find(contains(GroupCodes,{'CON'}));
CONrows = intersect(CONrows,Studyrows);

CAMrows = find(contains(GroupCodes,{'FAIM'}));
CAMrows = intersect(CAMrows,Studyrows);

FAISrows = find(contains(GroupCodes,{'FAIS'}));
FAISrows = intersect(FAISrows,Studyrows);

% devide into groups (CON,FAIS,CAM)
Groups = struct;
Groups.FAIS = SubjectCodes(FAISrows);
Groups.CAM = SubjectCodes(CAMrows);
Groups.Control = SubjectCodes(CONrows);

Subjects=sort([Groups.FAIS; Groups.CAM; Groups.Control]);

% Groups.PAIN = SubjectCodes(find(contains(GroupCodes,{'PAIN'})));

% get weight for the different groups
Weights = struct;
Weights.FAIS = WeightGroup(FAISrows);
Weights.CAM = WeightGroup(CAMrows);
Weights.Control = WeightGroup(CONrows);

%Get intramuscular groups
IntraGroup = demographics(Studyrows,strcmp(labelsDemographics,'Intramuscular'));
Intra = struct;
Intra.Yes = find(contains(IntraGroup,{'YES'}));
Intra.No = find(contains(IntraGroup,{'NO'}));