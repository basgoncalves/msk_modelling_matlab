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
%INPUT
%

%%

function [] = AcquisitionInterface_BG(Dir,Temp,SubjectInfo,SubjectTrials)

tic
fp = filesep;
data = btk_loadc3d([Dir.Input fp SubjectTrials.Dynamic{1} '.c3d']);
FPsampleRate = data.fp_data.Info(1).frequency;
VideosampleRate = data.marker_data.Info(1).frequency;
oldAcquisition = xml_read(Temp.Acq);

%% -----------------------------------------------------------------------%
%                               STAFF                                     %
%-------------------------------------------------------------------------%
oldAcquisition.Staff.PersonInCharge='BG&EM';
oldAcquisition.Staff.Operators.Name='EM'; %char needed if answer is empty({[]})

%% -----------------------------------------------------------------------%
%                               SUBJECT                                   %
%-------------------------------------------------------------------------%

% oldAcquisition.Subject.FirstName=char(answer{1});
% oldAcquisition.Subject.LastName=char(answer{2});
oldAcquisition.Subject.Code = SubjectInfo.ID;
oldAcquisition.Subject.Age = SubjectInfo.Age;
oldAcquisition.Subject.Weight = SubjectInfo.Weight;
oldAcquisition.Subject.Height = SubjectInfo.Height;
oldAcquisition.Subject.Leg = SubjectInfo.TestedLeg;
oldAcquisition.AcquisitionDate = SubjectInfo.DateOfTesting;
oldAcquisition.VideoFrameRate=VideosampleRate;
oldAcquisition.Subject.Pathology = SubjectInfo.Group;
% oldAcquisition.Subject.FootSize = subjectDemoGraphics{1,idx};


%% -----------------------------------------------------------------------%
%                               LABORATORY                                %
%-------------------------------------------------------------------------%

NForceplates = length(oldAcquisition.Laboratory.ForcePlatformsList.ForcePlatform);
for ii=1:NForceplates
    oldAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FrameRate = FPsampleRate;
end


%% -----------------------------------------------------------------------%
%                           EMGs SYSTEMS                                  %
%-------------------------------------------------------------------------%

nEMGSystem = length(oldAcquisition.EMGs.Systems.System);

if isempty(nEMGSystem)
    m=msgbox('Number Of EMG System MUST be inserted!Try again!','EMG Systems','warn');
    uiwait(m)
    answer = inputdlg(prompt,'Number of EMGs System Used',num_lines,def,options);
    
    nEMGSystem=str2num(answer{1});
end


for k=1:nEMGSystem
    oldAcquisition.EMGs.Systems.System(k).Rate=FPsampleRate;
end


%% -----------------------------------------------------------------------%
%                              TRIALS                                     %
%-------------------------------------------------------------------------%
%Trials Name
c3dFiles = dir([Dir.Input '/*.c3d']);
[~,~,LongLeg,~] = findLeg(Dir.Elaborated,'');
UsedTrials = [SubjectTrials.Dynamic' SubjectTrials.Static];
AcqTrial=struct;
count=1;

% TrialNames to look for when creating acquisition
markerSet = oldAcquisition.MarkersProtocol.MarkersSetStaticTrials;
markerSet = strsplit(markerSet,' ');

for k=1:length(UsedTrials)
    
    trialName = UsedTrials{k}; %regexprep(regexprep((regexprep(c3dFiles(k).name, ' ' , '')), '-',''), '.c3d', '');
     [trialType,trialNumber] = getTrialType(trialName);
    if sum(contains(UsedTrials,trialName,'IgnoreCase',true))>0
        
        data = btk_loadc3d([c3dFiles(k).folder fp trialName '.c3d']);
        if isempty(contains(fieldnames(data.marker_data.Markers),markerSet))
             fprintf('data not labeled for trial %s \n', trialName)
             continue
        end
        
        if contains(trialName,'Run','IgnoreCase',true)
             
            if data.Events.EventNumber==0
                fprintf('no events found for %s \n', trialName)
                continue
            end
            
            AcqTrial(count).Type = trialType;
            AcqTrial(count).RepetitionNumber = trialNumber;
            AcqTrial(count).MotionDirection='backward'; %motion direction
            [~,~,~,StanceOnFP] = findGaitCycle_FAIS(Dir,trialName);
            AcqTrial(count).StancesOnForcePlatforms.StanceOnFP = StanceOnFP;
        elseif contains(trialName,{'walking'},'IgnoreCase',true)
               
            AcqTrial = walkingStepForceplates_FAIS(SubjectInfo.ID,trialType,trialNumber,AcqTrial);
        elseif contains(trialName,{'SJ' 'Squat' 'static'},'IgnoreCase',true)
               
            AcqTrial(count).Type = trialType;
            AcqTrial(count).RepetitionNumber = trialNumber;
            AcqTrial(count).MotionDirection='90right';
            leg = {'-' LongLeg LongLeg '-'};
            Forceplatform = split(cellstr(sprintf('%d ',1:4)),' ')';
            StanceOnFP =  struct('Forceplatform',Forceplatform, 'leg',leg);
            AcqTrial(count).StancesOnForcePlatforms.StanceOnFP = StanceOnFP;
        end
         count = count+1; 
    end
    
end

Trials.Trial=AcqTrial;


%% -----------------------------------------------------------------------%
%                         ACQUISITION STRUCT                              %
%-------------------------------------------------------------------------%
ATTRIBUTE.xmlns_COLON_xsi='http://www.w3.org/2001/XMLSchema';

acquisition.Laboratory=oldAcquisition.Laboratory;
acquisition.Staff=oldAcquisition.Staff;
acquisition.Subject=oldAcquisition.Subject;
acquisition.AcquisitionDate=oldAcquisition.AcquisitionDate;
acquisition.VideoFrameRate=oldAcquisition.VideoFrameRate;
acquisition.MarkersProtocol=oldAcquisition.MarkersProtocol;
acquisition.EMGs.Protocol.InstrumentedLeg = SubjectInfo.TestedLeg;
acquisition.EMGs=oldAcquisition.EMGs;
acquisition.Trials=Trials;
acquisition.ATTRIBUTE=ATTRIBUTE;

%% -----------------------------------------------------------------------%
%                     acquisition.xml WRITING                             %
%-------------------------------------------------------------------------%

Pref.StructItem=false;  %to not have arrays of structs with 'item' notation
Pref.ItemName='Muscle';
Pref.CellItem=false;

xml_write([Dir.Input fp 'acquisition.xml'],acquisition,'acquisition',Pref);

disp('Any missing information will prevent .xml validation with its .xsd');

disp('================================================================')
disp('')
disp('                       Acquisition finished')
disp('')
disp('================================================================')
toc
save_to_base(1)    %Allow to copy variables in the workspace

