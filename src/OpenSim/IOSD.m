% IOSD
% import data open sim

%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
function [OSIMdata,ext] = IOSD (DirElaborated, TrialName, Analysis)

fp = filesep;

if exist('DirElaborated')
    cd(DirElaborated)
end

if nargin <3
    [File,FilePath,FileIndex] = ...
        uigetfile('*.*','Select OpenSim Results');
    Dirfile = [FilePath File];
elseif contains(Analysis, 'grf','IgnoreCase',1)
    DirC3D = strrep(DirElaborated,'ElaboratedData', 'InputData');
    Dirfile = [DirC3D fp TrialName '.c3d'];
elseif contains(Analysis, 'ik','IgnoreCase',1)
    Dirfile = [DirElaborated fp 'inverseKinematics' fp TrialName fp 'ik.mot'];
elseif contains(Analysis, 'id','IgnoreCase',1)
    Dirfile = [DirElaborated fp 'inverseDynamics' fp TrialName fp 'inverse_dynamics.sto'];
    
    
elseif contains(Analysis, 'ma','IgnoreCase',1)
    Folder = [DirElaborated fp 'muscleAnalysis' fp TrialName];
    files = dir([Folder fp '*.sto']);
    files = {files.name};
    
    Dirfile = [Folder fp files{idx}];

elseif contains(Analysis, 'rra','IgnoreCase',1)
    
    Folder = [DirElaborated fp 'residualReductionAnalysis' fp TrialName];
    files = dir([Folder fp '*.sto']);
    files = {files.name};
    [idx,~] = listdlg('PromptString',{'Please choose the file name to open'},'ListString',files);
    
    Dirfile = [Folder fp files{idx}];
    
end



[Folder,TrialName,ext]=fileparts(Dirfile);
Parts = split(Dirfile,filesep);
SubjectIDX = find(contains(split(Dirfile,filesep),{'ElaboratedData','InputData'}))+1;
NewSubject = Parts{SubjectIDX};

TrialName = erase(TrialName,'_inverse_dynamics');
TrialName = erase(TrialName,'_IK');
TrialName = erase(TrialName,['_' NewSubject]);
TrialName = erase(TrialName,'_setup_IK');
TrialName = erase(TrialName,'_grf');


if exist('OSIMdata')
    OSIMdata_old = OSIMdata;
    openvar('OSIMdata_old')
end

if contains (ext,'.xml')
    OSIMdata = xml_read(Dirfile);
elseif contains (ext,'.mot')
    OSIMdata = importdata(Dirfile);
elseif contains (ext,'.c3d')
    OSIMdata = btk_loadc3d(Dirfile);
else
    OSIMdata = importdata(Dirfile);
end

fprintf ('Data loaded from %s \n',Dirfile)
