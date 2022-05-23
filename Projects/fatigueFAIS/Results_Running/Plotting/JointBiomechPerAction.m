%% Description - Goncalves, BM (2019)
% plot Kniematics, Kinetics and Power for single trial
%
%INPUT
%   DirElaborated = [1xN char]
%                   Directory of the elaborated data (including the session)
%                   as a result of MOToNMS
%
%   Joint =         [1XN char] (optional)
%                   Name of the joint to plot (e.g. 'ankle')
%
%   TrialNames =     [NX1 cell] (optional)
%                   Each cell is the name of trial
%
%   Motion =        [1X1 double] (optional)
%                   1= sagital plane; 2 = frontal plane; 3 = transverse plane
%
%   StartFS =       [1X1 char] (optional)
%                   Would you like to invert data based on gait evcents?
%                   'Yes' = crop after foot contact and place it at the beginning
%                   'No' = do not crop data
%
%% Start Fucntion
function [DirElaborated,Joint,TrialNames,FootContact,Angle,Moment,AngVel,Power,PosWork,NegWork] = JointBiomechPerAction...
    (DirElaborated,Joint,TrialNames,StartFS)
%% create directories

LRFAI           % load results results FAI

DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');
OrganiseFAI                                                     % organise directories
cd(DirElaborated)

if ~exist('Joint') || sum(contains(fields(IDresults),Joint))~=1
    Variables = fields(IDresults);
    % select only one Joint
    [idx,~] = listdlg('PromptString',{'Choose the joint to plot'},'ListString',Variables,'SelectionMode','single');
    Joint = Variables (idx);
elseif sum(contains(fields(IDresults),Joint))==1
    Variables = fields(IDresults);
    Joint = Variables(contains(fields(IDresults),Joint));
end

if ~exist('TrialNames') || isempty(TrialNames)||...
        sum(contains(Labels,TrialNames))~=length (TrialNames)
    Variables = Labels;
    [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
    TrialNames = Variables (idx);
end

if ~exist('StartFS')
    StartFS = questdlg('Would you like to invert data based on gait evcents?');
end


% sample frequency
data = btk_loadc3d([DirC3D filesep TrialNames{1} '.c3d']);
fs = data.marker_data.Info.frequency;



%% Toeoff-to-toeoff

[Angle,SelectedLabels,IDxData] = findData (IKresults.(Joint{1}),Labels,TrialNames);

[Moment,SelectedLabels,IDxData] = findData (IDresults.(Joint{1}),Labels,TrialNames);

[AngVel,SelectedLabels,IDxData] = findData (AngularVelocity.(Joint{1}),Labels,TrialNames);

[Power,SelectedLabels,IDxData] = findData (JointPowers.(Joint{1}),Labels,TrialNames);

[PosWork,SelectedLabels,IDxData] = findData (JointPosWork.(Joint{1}),Labels,TrialNames);

[NegWork,SelectedLabels,IDxData] = findData (JointNegWork.(Joint{1}),Labels,TrialNames);

[FootContact,SelectedLabels,IDxData] = findData (GaitCycle.PercentageHeelStrike,Labels,TrialNames);

for ii = 1:length(TrialNames)
    Nrows = length(Angle(~isnan(Angle(:,ii))));         % length of each column without NaN
    FootContact(ii) = round(FootContact(ii)/100*Nrows);
    
end
%% Foot strike-to-foot strike
if contains(StartFS,'Yes','IgnoreCase',true)
    
    Moment = SwapSections(Moment,FootContact,1,fs);
    Angle = SwapSections(Angle,FootContact,1,fs);
    AngVel = calcVelocity (Angle,fs);
    Power = Moment.*AngVel;
    for FC = 1:length(FootContact)
        NoNanData = Moment (:,FC);
        NoNanData = NoNanData(~isnan(NoNanData));
        FootContact(FC) = length(NoNanData)-FootContact(FC);
        
    end
end

