%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               MOtoNMS                                   %
%                MATLAB MOTION DATA ELABORATION TOOLBOX                   %
%                 FOR NEUROMUSCULOSKELETAL APPLICATIONS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AcquisitionInterface.m
% GUI for acquisition.xml file generation.

% The file is part of matlab MOtion data elaboration TOolbox for
% NeuroMusculoSkeletal applications (MOtoNMS).
% Copyright (C) 2012-2014 Alice Mantoan, Monica Reggiani
%
% MOtoNMS is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
%
% Matlab MOtion data elaboration TOolbox for NeuroMusculoSkeletal applications
% is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with MOtoNMS.  If not, see <http://www.gnu.org/licenses/>.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>
%
% ADAPTED Basilio Goncalves 2019
%
%
% see setupbopstool

%%

function [] = AcquisitionInterface_BOPS

bops    = load_setup_bops;
subject = load_subject_settings;
setupSubject;

if bops.current.rerun == 0 && isfile(subject.directories.acquisitionXML)
    return 
end

Pref.StructItem = false;                                                                                            % xml preferences
Pref.ItemName   = 'Muscle';
Pref.CellItem   = false;

trialNames                                              = subject.trials.names'; 
c3dFilePathAndName                                      = [subject.directories.Input fp trialNames{1} '.c3d'];
[Markers, AnalogData, FPdata, ~, ForcePlatformInfo, ~]  = getInfoFromC3D(c3dFilePathAndName);
    
FPsampleRate            = FPdata.Rate;
VideosampleRate         = Markers.Rate;
AnalogDatasampleRate    = AnalogData.Rate;
newAcquisition          = xml_read(bops.directories.templates.acquisitionXML);

%% -----------------------------------------------------------------------%
%                               STAFF                                     %
%-------------------------------------------------------------------------%
newAcquisition.Staff.PersonInCharge='';
newAcquisition.Staff.Operators.Name=''; %char needed if answer is empty({[]})

%% -----------------------------------------------------------------------%
%                               SUBJECT                                   %
%-------------------------------------------------------------------------%

newAcquisition.Subject.Code         = subject.subjectInfo.ID;
newAcquisition.Subject.Age          = subject.subjectInfo.Age;
newAcquisition.Subject.Weight       = subject.subjectInfo.Mass_kg;
newAcquisition.Subject.Height       = subject.subjectInfo.Height_cm;
newAcquisition.Subject.Leg          = subject.subjectInfo.InstrumentedSide;
newAcquisition.AcquisitionDate      = subject.subjectInfo.DateOfTesting;
newAcquisition.VideoFrameRate       = VideosampleRate;
newAcquisition.Subject.Pathology    = subject.subjectInfo.Group;

%% -----------------------------------------------------------------------%
%                               LABORATORY                                %
%-------------------------------------------------------------------------%

NForceplates_bopsSetting = length(bops.Laboratory.FP);
NForceplates = length(ForcePlatformInfo);

if NForceplates_bopsSetting ~= NForceplates
   winopen(bops.directories.setupbopsXML)
   msgbox('please confirm the number of forcplates in the setup file matches the number of FP recorded')
   return
end


for ii=1:NForceplates
    
    FProt           = bops.Laboratory.FP(ii).rotationToGlobal;
    RotDirections   = fields(FProt);
    
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FrameRate    = FPsampleRate;
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).Type         = ForcePlatformInfo{ii}.type;
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).PadTickness  = ForcePlatformInfo{ii}.type;
    
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FPtoGlobalRotations.Rot(1).Axis = RotDirections{1};
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FPtoGlobalRotations.Rot(1).Degrees = FProt.(RotDirections{1});
    
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FPtoGlobalRotations.Rot(2).Axis = RotDirections{2};
    newAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FPtoGlobalRotations.Rot(2).Degrees = FProt.(RotDirections{2});
    
end

CS = [bops.Laboratory.APdirection bops.Laboratory.Vdirection bops.Laboratory.MLdirecrion];
newAcquisition.Laboratory.CoordinateSystemOrientation = CS;
%% -----------------------------------------------------------------------%
%                           EMGs SYSTEMS                                  %
%-------------------------------------------------------------------------%

newAcquisition.EMGs.Systems.System(1).Rate=AnalogDatasampleRate;
newAcquisition.EMGs.Protocol.MuscleList = bops.emg;
newAcquisition.EMGs.Channels.Channel = struct;
for i = 1:length(bops.emg.Muscle)
    newAcquisition.EMGs.Channels.Channel(i).ID = i;
    newAcquisition.EMGs.Channels.Channel(i).Muscle = bops.emg.Muscle(i);
end
%% -----------------------------------------------------------------------%
%                              TRIALS                                     %
%-------------------------------------------------------------------------%
leg         = subject.subjectInfo.InstrumentedSide;
UsedTrials  = subject.trials.names;
AcqTrial    = struct;
count       = 1;

[XML,markerSet]                                         = createMarkersXML (bops.directories.templates.Model);
newAcquisition.MarkersProtocol.Name                     = XML.Name;
newAcquisition.MarkersProtocol.MarkersSetStaticTrials   = XML.MarkersSetStaticTrials;
newAcquisition.MarkersProtocol.MarkersSetDynamicTrials  = XML.MarkersSetDynamicTrials;
markerSet                                               = strsplit(markerSet,' ');
sortedMarkers                                           = sort(markerSet);

rewrite   = 0;
if ~isfield(newAcquisition.MarkersProtocol,'motionDirectionMarkers') || ...                                         % if they don't exist select motion direction markers                                                                                                
        isempty (newAcquisition.MarkersProtocol.motionDirectionMarkers)
    [indx,~] = listdlg('PromptString','Select motion direction markers','ListString',sortedMarkers );                                                      
    motionDirectionMarkers = char(join(sortedMarkers (indx),' '));
    newAcquisition.MarkersProtocol.motionDirectionMarkers = motionDirectionMarkers;
    rewrite   = 1; 
end

if ~isfield(newAcquisition.MarkersProtocol,'rightFootMarkers') || ... 
        isempty (newAcquisition.MarkersProtocol.rightFootMarkers)                                                        % if they don't exist select motion direction markers                                                                                                
    [indx,~] = listdlg('PromptString','Select right foot markers','ListString',sortedMarkers );                                                      
    rightFootMarkers = char(join(sortedMarkers (indx),' '));
    newAcquisition.MarkersProtocol.rightFootMarkers = rightFootMarkers;
    rewrite   = 1;
end 

if ~isfield(newAcquisition.MarkersProtocol,'leftFootMarkers') || ... 
        isempty (newAcquisition.MarkersProtocol.leftFootMarkers)                                                        % if they don't exist select motion direction markers                                                                                                
    [indx,~] = listdlg('PromptString','Select left foot markers','ListString',sortedMarkers );                                                      
    leftFootMarkers = char(join(sortedMarkers (indx),' '));
    newAcquisition.MarkersProtocol.leftFootMarkers = leftFootMarkers;
    rewrite   = 1;
end 

if rewrite == 1
    xml_write(bops.directories.templates.acquisitionXML,newAcquisition,'acquisition',Pref);
end

motionDirectionMarkers  = newAcquisition.MarkersProtocol.motionDirectionMarkers;
rightFootMarkers        = newAcquisition.MarkersProtocol.rightFootMarkers;
leftFootMarkers         = newAcquisition.MarkersProtocol.leftFootMarkers;


trialTypes = {bops.Trials.trial.Type};                                                                              % find gait events
for k = 1:length(UsedTrials)
    
    trialName = UsedTrials{k};
%      [~,trialNumber] = getTrialType(trialName);
    if sum(contains(UsedTrials,trialName,'IgnoreCase',true))>0
        
        c3dFilePathAndName = [subject.directories.Input fp trialName '.c3d'];
        [Markers, ~, ~, ~, ~, ~] = getInfoFromC3D(c3dFilePathAndName);
        
        if isempty(contains(Markers.Labels,markerSet))
             fprintf('data not labeled for trial %s \n', trialName)
             continue
        end
        
        for i = 1:length(trialTypes)                                                                                % define motion direction relative to the lab CS
            if contains(trialName,trialTypes{i}) == 1
               motionDirection = bops.Trials.trial(i).MotionDirection;
               
               if isequal(motionDirection,'auto')
                   motionDirection = determineMotionDirection(c3dFilePathAndName, motionDirectionMarkers);          % if "auto" use the markers to detect the orientation
               end
               break
            end
        end

        AcqTrial(count).Type = trialName;
        AcqTrial(count).RepetitionNumber = '';
        AcqTrial(count).MotionDirection = motionDirection;
        StanceOnFP = findGaitCycle_Events(c3dFilePathAndName,trialName,rightFootMarkers,leftFootMarkers);
        AcqTrial(count).StancesOnForcePlatforms.StanceOnFP = StanceOnFP;
        count = count+1; 
    end
end

Trials.Trial=AcqTrial;


%% -----------------------------------------------------------------------%
%                         ACQUISITION STRUCT                              %
%-------------------------------------------------------------------------%
ATTRIBUTE.xmlns_COLON_xsi='http://www.w3.org/2001/XMLSchema';

acquisition.Laboratory                      = newAcquisition.Laboratory;
acquisition.Staff                           = newAcquisition.Staff;
acquisition.Subject                         = newAcquisition.Subject;
acquisition.AcquisitionDate                 = newAcquisition.AcquisitionDate;
acquisition.VideoFrameRate                  = newAcquisition.VideoFrameRate;
acquisition.MarkersProtocol                 = newAcquisition.MarkersProtocol;
acquisition.EMGs.Protocol.InstrumentedLeg   = subject.subjectInfo.InstrumentedSide;
acquisition.EMGs                            = newAcquisition.EMGs;
acquisition.Trials                          = Trials;
acquisition.ATTRIBUTE                       = ATTRIBUTE;

%% -----------------------------------------------------------------------%
%                     acquisition.xml WRITING                             %
%-------------------------------------------------------------------------%

Pref.StructItem=false;                                                                                              % to avoid arrays of structs with 'item' notation
Pref.ItemName='Muscle';
Pref.CellItem=false;

xml_write(subject.directories.acquisitionXML,acquisition,'acquisition',Pref);

disp('Any missing information will prevent .xml validation with its .xsd');

disp('================================================================')
disp('                       Acquisition finished')
disp('================================================================')
save_to_base(1)    %Allow to copy variables in the workspace

