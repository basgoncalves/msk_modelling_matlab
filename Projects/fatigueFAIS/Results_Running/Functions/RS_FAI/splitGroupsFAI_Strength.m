
% splitGroupsFAI
function [Groups,Weights,Intra] = splitGroupsFAI_Strength(DirMocap)

cd(DirMocap)
warning on
% check if an excel with the participant data exists (demographics and
% other data)
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
    
   
    STRCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'StrengthData'));
    STRrows = find(contains(STRCodes,{'Yes'}));
    
    GroupCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Group'));
    CONrows = find(contains(GroupCodes,{'CON'}));
    
    GroupCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Group'));
    CAMrows = find(contains(GroupCodes,{'FAIM'}));
  
    GroupCodes = demographics(1:lastRow-1,strcmp(labelsDemographics,'Group'));
    FAISrows = find(contains(GroupCodes,{'FAIS'}));
    
    % devide into groups (CON,FAIS,CAM)
    Groups = struct;
    Groups.FAIS = SubjectCodes(intersect(FAISrows,STRrows));
    Groups.CAM = SubjectCodes(intersect(CAMrows,STRrows));
    Groups.Control = SubjectCodes(intersect(CONrows,STRrows));
    % Groups.PAIN = SubjectCodes(find(contains(GroupCodes,{'PAIN'})));

    % get weight for the different groups 
    Weights = struct;
    Weights.FAIS = WeightGroup(find(contains(GroupCodes,{'FAIS'})));
    Weights.CAM = WeightGroup(find(contains(GroupCodes,{'FAIM'})));
    Weights.Control = WeightGroup(find(contains(GroupCodes,{'CON'})));
    
    %Get intramuscular groups
    Intra = struct;
    Intra.Yes = SubjectCodes(find(contains(IntraGroup,{'YES'})));
    Intra.No = SubjectCodes(find(contains(IntraGroup,{'NO'})));

    
end