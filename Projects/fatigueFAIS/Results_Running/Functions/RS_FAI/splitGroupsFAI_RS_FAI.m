
% splitGroupsFAI
function [Groups,Weights,Intra] = splitGroupsFAI_RS_FAI(DirMocap)

cd(DirMocap)
warning on
% check if an excel with the participant data exists (demographics and other data)
if exist('ParticipantData and Labelling.xlsx')
    demographics = importParticipantData('ParticipantData and Labelling.xlsx', 'Demographics');
    labelsDemographics = demographics(2,:);
    
    SubjectCol = find(strcmp(labelsDemographics,'Subject'));
    SubjectCodes = demographics(1:end,SubjectCol);
    WeightCol = find(strcmp(labelsDemographics,'Weight')); 
    WeightGroup = demographics(1:end,WeightCol);
    IntraCol = find(strcmp(labelsDemographics,'Intramuscular')); 
    IntraGroup = demographics(1:end,IntraCol);
    
    lastRow = find(contains(SubjectCodes,{'Mean'}));
    
   
    P5Codes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Paper 5'));
    P5rows = find(contains(P5Codes,{'Yes'}));
    
    GroupCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Group'));
    CONrows = find(contains(GroupCodes,{'CON'}));
    CONrows = intersect(CONrows,P5rows);
    
    CAMrows = find(contains(GroupCodes,{'FAIM'}));
    CAMrows = intersect(CAMrows,P5rows);
  
    FAISrows = find(contains(GroupCodes,{'FAIS'}));
    FAISrows = intersect(FAISrows,P5rows);
    
    % devide into groups (CON,FAIS,CAM)
    Groups = struct;
    Groups.FAIS = SubjectCodes(FAISrows);
    Groups.CAM = SubjectCodes(CAMrows);
    Groups.Control = SubjectCodes(CONrows);

    % Groups.PAIN = SubjectCodes(find(contains(GroupCodes,{'PAIN'})));

    % get weight for the different groups 
    Weights = struct;
    Weights.FAIS = WeightGroup(FAISrows);
    Weights.CAM = WeightGroup(CAMrows);
    Weights.Control = WeightGroup(CONrows);
    %Get intramuscular groups
    Intra = struct;
    Intra.Yes = SubjectCodes(contains(IntraGroup,{'YES'}));
    Intra.No = SubjectCodes(contains(IntraGroup,{'NO'}));

end