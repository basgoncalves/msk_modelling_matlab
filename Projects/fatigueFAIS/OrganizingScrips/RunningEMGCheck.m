%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   FindGaitCycle_Running
%   LoadResults_BG
%   findData
%   getMP
%   mmfn
%   TimeNorm
%   fullscreenFig
%
%INPUT
%   CEINMSdir = [char] directory of the your ceinms dta for one subject
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms'
%-------------------------------------------------------------------------
%OUTPUT
%  G = Group data with angles, moments and 
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% RunningEMGCheck

function RunningEMGCheck(SubjectFoldersElaborated, sessionName)


fp = filesep;
LW = 2;     % line width
FS = 15;     % font size
fs = 200;   %sampling frequency
set(0,'DefaultAxesFontName', 'Consolas')

%% Default settiong and directories

if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end
if ~exist('Logic')
    Logic = 1;
end

%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;


%% loop through all participants 
for ff = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},fp);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    
    OrganiseFAI     % generates directories and other necessary files
  
    if ~exist([DirID]) || length(dir([DirID]))<3
        continue
    end
    
    if exist([DirC3D fp 'BadTrials.mat'])
        
        disp('')
        disp(['Data is fine for ' Subject])
        disp('')
        continue
    end
    
    
    Strials = getstrials(DynamicTrials); % 
     
    TrialList = DynamicTrials;
    f = checkEMGdata_dynamic (DirC3D,muscleString,TrialList);
    uiwait(f)
end

% 
% TT= strrep(SubjectFoldersElaborated,[DirMocap fp 'ElaboratedData' fp],'');
% plotLine_BG(G.angles.hip_flexion,[],{'Gait cycle %'},TT,1)

