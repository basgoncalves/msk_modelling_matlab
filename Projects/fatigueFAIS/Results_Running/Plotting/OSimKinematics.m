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
%   DirIKResults
%   DirC3D
%   TestedLeg: 1 = Right, 2 = Left
%   GaitCycleType:  1 = Foot Strike to Foot strike, 2 = Toe off to Toe off
%   JointMotions:
%-------------------------------------------------------------------------
%OUTPUT

%--------------------------------------------------------------------------

function [IKresults,IKresultsNormalized,GC,BadTrials,Labels] = OSimKinematics(DirIKResults,TestedLeg,JointMotions)
%% Organise directories
if nargin <1
    DirIKResults = uigetdir(cd,'Select directory of the Kinematics results form openSim');
end

DirC3D = strrep (DirIKResults,'ElaboratedData', 'InputData');
Parts = split(DirC3D,[filesep 'inverseKinematics']);            %devide name at "inverseLinematics"
DirC3D = Parts{1};

DirIK = split(DirIKResults,filesep);
DirIK = erase(DirIKResults,DirIK{end});

%% parameters to extract 

% tested leg
if ~exist('TestedLeg') || isempty('TestedLeg')
    definput = {'1 = Right', '2 = Left'};
    [idx,~] = listdlg('PromptString',{'Please choose the tested leg (1 = Right, 2 = Left)'},'ListString',definput);
    TestedLeg = idx;
elseif contains(TestedLeg,'R','IgnoreCase',true)
    TestedLeg=1;
elseif contains(TestedLeg,'L','IgnoreCase',true)
    TestedLeg=2;
end

% files in the results folder
FilesIK = dir([DirIKResults filesep '*.mot']);
if isempty(FilesIK)
    error('Inverse Kinematics results directory dos not contain any .mot file')
end

% joint motions
if ~exist('JointMotions') || isempty('JointMotions')
    OSIMdata = importdata([DirIKResults filesep FilesIK(1).name]);
    VariablesOsim = OSIMdata.colheaders;
    [idx,~] = listdlg('PromptString',{'Choose the varibales to extract kinematics'},'ListString',VariablesOsim);
    JointMotions = VariablesOsim (idx);
end

oldChar='_';
newChar='-';
FilesIK = replaceCharacters (oldChar,newChar,FilesIK);    % Replace chararcters and reorganise alphabetically

%% Create output variables
cd(DirIKResults)

GC = struct;

% IK results in seconds
IKresults = struct;
% IK results time normalised
IKresultsNormalized = struct;

%% Loop through all the kinematic variables

for pp = 1: length(JointMotions)
    
    HeelStrike =[];
    IKresults.(JointMotions{pp})=[];
    IKresultsNormalized.(JointMotions{pp})=[];
    % loop through all the trials in the results folder
    loops = size(FilesIK,1);
    BadTrials=[];
    for ff = 1:loops
        
        if ~contains (FilesIK(ff).name, '_IK.mot')
            error ('edit the script and change the sufix used for IK trials (e.g Run_baselineA1_IK.mot  = "_IK.mot")')
        end
  
        CurrentTrial = erase(FilesIK(ff).name, '_IK.mot');                 
        %samplignfrequency from C3D data
        C3Ddata = btk_loadc3d([DirC3D filesep CurrentTrial '.c3d']);
        fs = C3Ddata.marker_data.Info.frequency;
        
        IKData = importdata ([FilesIK(ff).folder filesep FilesIK(ff).name]);
        
        % GaitCycle
        GC.(CurrentTrial) = FindOSimGC (DirIK,CurrentTrial);
        
        if length(GC.(CurrentTrial))<2 || GC.(CurrentTrial)(1) < 1
            fprintf('no gait cycle data for %s \n', CurrentTrial)
            GC= rmfield(GC,CurrentTrial);
            BadTrials(end+1)=ff;
            continue
        end
       

        LabelsIK = IKData.colheaders;
        IKData = IKData.data;
        [kinematicData,SelectedLabels,IDxData] = findData (IKData,LabelsIK,JointMotions{pp});            % callback function
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Crop data based on the gait cycle  % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if GC.(CurrentTrial)(2) > length(kinematicData)
            fprintf('gait cycle wrongly computed %s \n', CurrentTrial)
            BadTrials(end+1)=[];
            continue
        end
        
        % crop data
        kinematicData_cut = kinematicData(GC.(CurrentTrial)(1):GC.(CurrentTrial)(2),:);
        kinematicData_cut = kinematicData_cut*(pi/180);                             % in radians 
         
        % flip data  
%         kinematicData_flipped = FlipOSimMoment (kinematicData_cut, JointMotions{pp});

        
        Nrows = length(kinematicData_cut);
        
        IKresults.(JointMotions{pp})(1:Nrows,end+1)= kinematicData_cut;
        
        % time normalize data
        kinematicData_Norm = TimeNorm(kinematicData_cut,fs);
        IKresultsNormalized.(JointMotions{pp})(1:101,end+1) = kinematicData_Norm;
        
        % define heel strike as a percentage of gait cycle
        NormalizedGC = GC.(CurrentTrial)-GC.(CurrentTrial)(1);
        HeelStrike(end+1) = NormalizedGC(3)*100/NormalizedGC(2);
        
        if HeelStrike(end)> 80
            warning('Heel Strike for trial %s not well calculated',CurrentTrial)
        end

    end
    
    % make zeros = NaN 
    IKresults.(JointMotions{pp})(IKresults.(JointMotions{pp})==0)=NaN;
    
    GC.PercentageHeelStrike = HeelStrike;

    FilesIK(BadTrials) = [];
end

Labels = erase({FilesIK.name},'_IK.mot');


