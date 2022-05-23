

function SubjectInfo=getDemographicsFAI(DirMocap,Subject)

fp = filesep;
warning on
% check if an excel with the participant data exists (demographics and other data)
Matfile = dir([DirMocap fp 'demographics.mat']);
XLXSfile = dir([DirMocap fp 'ParticipantData and Labelling.xlsx']);
if exist([DirMocap fp 'demographics.mat']) && Matfile.datenum  > XLXSfile.datenum
    load([DirMocap fp 'demographics.mat'])
else
    cmdmsg(['Updating demographics mat '])
    demographics = importParticipantData([DirMocap fp 'ParticipantData and Labelling.xlsx'], 'Demographics');
end

labelsDemographics = demographics(2,:);
SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(1:end,SubjectCol);
cd(DirMocap)
save demographics demographics labelsDemographics SubjectCodes
SubjectInfo = struct;

if nargin<2; return; end

SubjectRow = find(strcmp(SubjectCodes,Subject));
if isempty(SubjectRow)
    warning ('Demographics for subject "%s" do not exist',Subject)
    return
end

% create subject info struct
SubjectInfo.ID = demographics{SubjectRow,strcmp(labelsDemographics,'Subject')};
SubjectInfo.Row = SubjectRow-2;
SubjectInfo.Age = demographics{SubjectRow,strcmp(labelsDemographics,'Age')};
SubjectInfo.Sex = demographics{SubjectRow,strcmp(labelsDemographics,'Sex')};
SubjectInfo.DateOfTesting = demographics{SubjectRow,strcmp(labelsDemographics,'Date')};
SubjectInfo.Height = demographics{SubjectRow,strcmp(labelsDemographics,'Height')};
SubjectInfo.Weight = demographics{SubjectRow,strcmp(labelsDemographics,'Weight')};
SubjectInfo.TestedLeg = demographics{SubjectRow,strcmp(labelsDemographics,'Measured Leg')};
if contains(SubjectInfo.TestedLeg,'R'); SubjectInfo.ContralateralLeg = 'L';
else; SubjectInfo.ContralateralLeg = 'R'; end
SubjectInfo.DominantLeg = demographics{SubjectRow,strcmp(labelsDemographics,'Dominant Leg ')};
SubjectInfo.Group = demographics{SubjectRow,strcmp(labelsDemographics,'Group')};
SubjectInfo.AlphaAngle = demographics{SubjectRow,strcmp(labelsDemographics,{'Alpha angle'})};
SubjectInfo.Nruns = demographics{SubjectRow,strcmp(labelsDemographics,'Nr Rounds')};
SubjectInfo.RunningPhase = demographics{SubjectRow,strcmp(labelsDemographics,'RunningPhase')};
SubjectInfo.Intramuscular = demographics{SubjectRow,strcmp(labelsDemographics,'Intramuscular')};
SubjectInfo.LegLength = demographics{SubjectRow,strcmp(labelsDemographics,'Leg Length (GT - LMAL)')};
SubjectInfo.ThighLength = demographics{SubjectRow,strcmp(labelsDemographics,'Thigh Length')};
SubjectInfo.GT2Knee = demographics{SubjectRow,strcmp(labelsDemographics,'GT - Knee pad')}/100;
SubjectInfo.GT2Ankle = demographics{SubjectRow,strcmp(labelsDemographics,'GT - Ankle pad')}/100;
SubjectInfo.Pat2Ankle = demographics{SubjectRow,strcmp(labelsDemographics,'Pat-Ankle pad')}/100;

