%% Description - Goncalves, BM (2019)
% plot Inverse kinematics results from OpenSim
%
%Select folder that contains individual
% CALLBACK FUNTIONS
%   mmfn = make my figure nice
%   findData
%   combineForcePlates_multiple
%   fullscreenFig
%INPUT
%   DirIDResults
%   DirC3D
%   TestedLeg: 1 = Right, 2 = Left
%   GaitCycleType:  1 = Foot Strike to Foot strike, 2 = Toe off to Toe off
%   JointMotions: 
%-------------------------------------------------------------------------
%OUTPUT

%--------------------------------------------------------------------------

function [IDresults,IDresultsNormalized,GC,BadTrials,Labels] = OSimMoments (DirIDResults,TestedLeg,JointMotions,MassKG,Height)
%% Organise directories
if nargin <1
    DirIDResults = uigetdir(cd,'Select directory of the Inverse dynamics results form openSim');
end

Slashes   = strfind(DirIDResults,'\');
SplitNames = split(DirIDResults, filesep);
IdxElaboratedSession = find(contains(SplitNames,'ElaboratedData'));             % in which position in the directory is "Elaborated Data"
DirElaborated = DirIDResults(1:Slashes(IdxElaboratedSession+2)-1);
DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');

mydir  = DirC3D;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);                      % Subject dir
idcs   = strfind(SubjFolder,'\');   
Subject = SubjFolder(idcs(end)+1:end);                  % subject ID

DirIKResults = [DirElaborated filesep 'inverseKinematics' filesep 'Results'];

DirIK = split(DirIKResults,filesep);
DirIK = erase(DirIKResults,DirIK{end});

%% parameters to extract 

if ~exist('TestedLeg')
    definput = {'1 = Right', '2 = Left'};
    [idx,~] = listdlg('PromptString',{'Please choose the tested leg (1 = Right, 2 = Left)'},'ListString',definput);
    TestedLeg = idx;
elseif contains(TestedLeg,'R','IgnoreCase',true)
    TestedLeg=1;
elseif contains(TestedLeg,'L','IgnoreCase',true)
    TestedLeg=2;
end

FilesID = dir([DirIDResults filesep '*.sto']);
FilesIK = dir([DirIKResults filesep '*.mot']);

if isempty(FilesID)
    error('Inverse Dynamics results directory dos not contain any .sto file')
elseif isempty(FilesIK)
    error('Inverse Kinematics results directory dos not contain any .mot file')
end


if ~exist('JointMotions') || isempty('JointMotions')
    OSIMdata = importdata([DirIDResults filesep FilesID(1).name]);
    VariablesOsim = OSIMdata.colheaders;
    [idx,~] = listdlg('PromptString',{'Choose the varibales to plot kinematics'},'ListString',VariablesOsim);
    JointMotions = VariablesOsim (idx);
end


oldChar='_';
newChar='-';
FilesID = replaceCharacters (oldChar,newChar,FilesID);    % Replace chanrarcters and reorganise alphabetically
FilesIK = replaceCharacters (oldChar,newChar,FilesIK);    % Replace chanrarcters and reorganise alphabetically

%% Create output variables

cd(DirIDResults)


% IK results in seconds
IDresults = struct;

% IK results time normalised
IDresultsNormalized = struct;

Labels = {};
%% Loop through all the kinematic variables

for pp = 1: length(JointMotions)
    
    MomentName = erase (JointMotions{pp},'_moment');
    HeelStrike = [];
    IDresults.(MomentName)=[];
    IDresultsNormalized.(MomentName)=[];
    loops = size(FilesID,1);
    BadTrials=[];
  % loop through all the trials in the results folder
    for ff = 1:loops
        
        if ~contains (FilesID(ff).name, '_inverse_dynamics.sto')
            error ('edit the script and change the sufix used for IK trials (e.g Run_baselineA1_inverse_dynamics.sto  = "_inverse_dynamics.sto")')
        end
  
        CurrentTrial = erase(FilesID(ff).name, '_inverse_dynamics.sto');
        
        %samplignfrequency from C3D data
        C3Ddata = btk_loadc3d([DirC3D filesep CurrentTrial '.c3d']);
        fs = C3Ddata.marker_data.Info.frequency;
        fs_grf = C3Ddata.fp_data.Info.frequency;
        C3Ddata = combineForcePlates_multiple(C3Ddata);
        GRFz = C3Ddata.fp_data.GRF_data.F(:,3);
 
        % GaitCycle
        IKData = importdata ([FilesIK(ff).folder filesep FilesIK(ff).name]);
        GC.(CurrentTrial) = FindOSimGC (DirIK,CurrentTrial);
        
        if length(GC.(CurrentTrial))<2 || GC.(CurrentTrial)(1) < 1
            fprintf('no gait cycle data for %s \n', CurrentTrial)
            GC= rmfield(GC,CurrentTrial);
            BadTrials(end+1)=ff;
            continue
        end

       
        
        % load moments 
        IDData = importdata ([FilesID(ff).folder filesep FilesID(ff).name]); 
  
        LabelsIK = IDData.colheaders;
        IDData = IDData.data;
        [MomentData,SelectedLabels,IDxData] = findData (IDData,LabelsIK,JointMotions{pp});            % callback function
        
        

%% Cut and plot data based on the gait cycle  
            

        if GC.(CurrentTrial)(2) > length(MomentData)
            fprintf('gait cycle wrongly computed %s \n', CurrentTrial)
            BadTrials(end+1)=ff;
            continue
        end
       
        % crop data
        MomentData_cut  = MomentData(GC.(CurrentTrial)(1):GC.(CurrentTrial)(2),:);


        % flip moment 
%         MomentData_flipped = FlipOSimMoment (MomentData_cut, JointMotions{pp});
        
    
%         % calculate the 98th percentile of the vertical GRF frequency to
%         % filter the moments - Edwards et al. (2011)
%         cuttoff = FrequPercentile (GRFz,98,fs_grf);
%         MomentData_cut = matfiltfilt(1/fs, cuttoff, 1, MomentData_cut);
        

        Nrows = length(MomentData_cut);
        IDresults.(MomentName)(1:Nrows,end+1) = MomentData_cut;
        
        if ~exist('MassKG')
            answer = inputdlg('please type the body weight of the participant in KG');
            MassKG = str2num(answer{1});
        end
        
        %if Height exists too normalise to Height and Weight
        if exist('Height')
            MassKG = MassKG*Height;
        end
        
        % time and bodyweight normalised normalize data
        MomentData_Norm = TimeNorm(MomentData_cut,fs)/MassKG;
        IDresultsNormalized.(MomentName)(1:101,end+1) = MomentData_Norm;
        
        NormalizedGC = GC.(CurrentTrial)-GC.(CurrentTrial)(1);
        HeelStrike(end+1) = NormalizedGC(3)*100/NormalizedGC(2);
        
        if HeelStrike(end)> 80
            warning('Heel Strike for trial %s not well calculated',CurrentTrial)
        end
  
    end
    
    % make zeros = NaN 
    IDresults.(MomentName)(IDresults.(MomentName)==0)=NaN;
    
    
    GC.PercentageHeelStrike = HeelStrike;
    FilesID(BadTrials) = [];

end


Labels = erase({FilesID.name},'_inverse_dynamics.sto');


