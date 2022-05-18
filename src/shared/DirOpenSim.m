%

function [AllDir,C3dFiles,demographics] = DirOpenSim(DirC3D)

if nargin >0
    cd(DirC3D)
else
    DirC3D = uigetdir('','Select InputFolder  with .c3d files');
end

% get files in c3d folder
cd(DirC3D);
folderC3D = sprintf('%s\\%s',DirC3D,'*.c3d');
C3dFiles = dir(folderC3D);
AllDir.DirC3D = DirC3D;

mydir  = pwd;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);                      % Subject dir
C3DFolderName = mydir(idcs(end)+1:end);                 % C3D folder name 

idcs   = strfind(SubjFolder,'\');   
DirInput = SubjFolder(1:idcs(end)-1);                   % InputData dir
[~,name,~] = fileparts(DirInput);
if ~contains(name,'InputData')

    error('InputData folder does not exist or is in the wrong order\n%s',...
        'Format should be: ..\MainPath\InputData\Subject\Session\*.c3d');
end
Subject = SubjFolder(idcs(end)+1:end);                  % subject ID

idcs   = strfind(DirInput,'\');
DirMocap = DirInput(1:idcs(end)-1);                     % Mocap dir
AllDir.DirMocap=DirMocap;

idcs   = strfind(DirMocap,'\');
AllDir.DirFigure = sprintf('%s\\Figures', DirMocap(1:idcs(end)-1));

AllDir.DirElaborated = ([DirMocap,filesep,'ElaboratedData',filesep,...
    Subject,filesep,C3DFolderName]);                    %location of elaboration.xml file. 

ElaborationFilePath = ([DirMocap,filesep,'ElaboratedData',filesep,...
    Subject,filesep,C3DFolderName,'\dynamicElaborations']); %location of elaboration.xml file.
mkdir (ElaborationFilePath);

AllDir.DirResults = ([DirMocap filesep 'Results']);

AllDir.DirWoodway = ([erase(DirMocap,'\MocapData') filesep...
    '\WoodwayTreadmill_data' filesep Subject]);

cd(DirMocap)

% check if participant had intramuscular EMG based on Participant information data
if exist('ParticipantData and Labelling.xlsx')
demographics = importParticipantData('ParticipantData and Labelling.xlsx', 'Demographics');
labelsDemographics = demographics(2,:);
SubjectCol = find(strcmp(labelsDemographics,'Subject'));
SubjectCodes = demographics(1:end,SubjectCol);
SubjectRow = find(strcmp(SubjectCodes,Subject));
SubjectsDemogr = demographics(SubjectRow,:);

else 
demographics = struct;
disp('demographics not found')
end
clear mydir idcs