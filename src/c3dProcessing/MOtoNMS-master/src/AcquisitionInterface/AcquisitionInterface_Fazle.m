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
%   subjectDemoGraphics = cell vector with any needed demographics
%
%   Labels = cell vector with the names of each of the cells in
%   "subjectDemoGraphics"
%
%   Adapted Fazle Rabi 2019 

%%

function [] = AcquisitionInterface_Fazle(oldAcquisition,subjectDemoGraphics,subjectDemoLabels,c3dPath,DynamicTrials)


% Dataset folder

if nargin < 4
c3dPath = uigetdir(cd,'Select your .c3d folder');
end

c3dFiles = dir ([c3dPath filesep '*.c3d']);
dataDir = sprintf ('%s\\%s',c3dFiles(1).folder,c3dFiles(1).name);
data = btk_loadc3d(dataDir);
FPsampleRate = data.fp_data.Info(1).frequency;
VideosampleRate = data.marker_data.Info(1).frequency;

%% -----------------------------------------------------------------------%
%                               STAFF                                     %
%-------------------------------------------------------------------------%
oldAcquisition.Staff.PersonInCharge='GD&FR';
oldAcquisition.Staff.Operators.Name='GD'; %char needed if answer is empty({[]})

%% -----------------------------------------------------------------------%
%                               SUBJECT                                   %
%-------------------------------------------------------------------------% 

% oldAcquisition.Subject.FirstName=char(answer{1});
% 
% oldAcquisition.Subject.LastName=char(answer{2});


oldAcquisition.Subject.Code = subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Subject')};
oldAcquisition.Subject.Age = subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Age')};
oldAcquisition.Subject.Weight = subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Weight')};
oldAcquisition.Subject.Height = subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Height')};
oldAcquisition.AcquisitionDate = subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Date')};
oldAcquisition.VideoFrameRate =VideosampleRate;

% 
% idx = find(strcmp(Labels,'Subject'));
% oldAcquisition.Subject.FootSize = subjectDemoGraphics{1,idx};
% 
% idx = find(strcmp(Labels,'Group'));
% oldAcquisition.Subject.Pathology = subjectDemoGraphics{1,idx};

%% -----------------------------------------------------------------------%
%                               LABORATORY                                %
%-------------------------------------------------------------------------%

NForceplates = length(oldAcquisition.Laboratory.ForcePlatformsList.ForcePlatform);
for ii=1:NForceplates
oldAcquisition.Laboratory.ForcePlatformsList.ForcePlatform(ii).FrameRate;% = FrameRate;
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
        oldAcquisition.EMGs.Systems.System(k).Rate;%=FPsampleRate;
    end
        

%% -----------------------------------------------------------------------%
%                              TRIALS                                     %
%-------------------------------------------------------------------------%
%Trials Name
nTrials=length(c3dFiles);
NForceplates = length(oldAcquisition.Laboratory.ForcePlatformsList.ForcePlatform);

%Def values
if nargin>0
%     def_String=setTrialsStancesFromFile(nTrials,NForceplates, oldAcquisition);
    if isfield(oldAcquisition.Trials.Trial,'MotionDirection')==1
        def_motionDirection=setMotionDirectionFromFile(nTrials,oldAcquisition);
    else
        def_motionDirection=setMotionDirectionFromFile(nTrials);
    end
else
%     def_String=setTrialsStancesFromFile(nTrials, NForceplates);
    def_motionDirection=setMotionDirectionFromFile(nTrials);
end

nRep{1}='1';
nRep{2}='2';
nRep{3}='3';
nRep{4}='4';
nRep{5}='5';
nRep{6}='6';
nRep{7}='7';
nRep{8}='8';
nRep{9}='9';
nRep{10}='0';

Trial=struct;
count=1;
for k=1:length(c3dFiles)
    
    ind=[];
    %Name correction/check: after standadization it will not be necessary
    trialsName{k} = regexprep(regexprep((regexprep(c3dFiles(k).name, ' ' , '')), '-',''), '.c3d', '');
    
    for i=1:length(nRep)
        c=strfind(trialsName{k},nRep{i});
        ind=[ind c];
    end
    
    %Trials TYPE and REPETITION
    
    for t = 1:length(DynamicTrials)
        if contains (trialsName{k},DynamicTrials{t})
            Trial(count).Type=trialsName{k}(1:ind-1);
            Trial(count).RepetitionNumber=trialsName{k}(ind:end);
            %motion direction
            
            dataDir = sprintf ('%s\\%s',c3dFiles(k).folder,c3dFiles(k).name);
            data = btk_loadc3d(dataDir);
          
             [events,motionDirection] = findHeelStrike_Running_multiple(data, 'backward',2);
           
            
            Trial(count).MotionDirection = motionDirection;
            
            for f = 1: NForceplates
                StanceOnFP(f).Forceplatform = f;
             
                    if ~isempty(events.forceplateEvents(f).HSLeft)
                        StanceOnFP(f).leg ='Left';
                    elseif ~isempty(events.forceplateEvents(f).HSRight)
                        StanceOnFP(f).leg ='Right';
                    else
                        StanceOnFP(f).leg ='-';
                    end
                
            end
            Trial(count).StancesOnForcePlatforms.StanceOnFP = StanceOnFP;
            count = count+1;
        
        end
    end
    
    
end

Trials.Trial=Trial;


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

%acquisition.EMGSystems.Number=nEMGSystem;
if nEMGSystem>0
    acquisition.EMGs=oldAcquisition.EMGs;
end

% if contains (subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Measured Leg')}, 'L') 
%     acquisition.EMGs.Protocol.InstrumentedLeg = 'Left';
% elseif contains (subjectDemoGraphics{1,strcmp(subjectDemoLabels,'Measured Leg')}, 'R')
    acquisition.EMGs.Protocol.InstrumentedLeg = 'Right'; 
%  end

acquisition.Trials=Trials;
acquisition.ATTRIBUTE=ATTRIBUTE;

%% -----------------------------------------------------------------------%
%                     acquisition.xml WRITING                             %
%-------------------------------------------------------------------------%
cd(c3dPath)
Pref.StructItem=false;  %to not have arrays of structs with 'item' notation
Pref.ItemName='Muscle';
Pref.CellItem=false;

xml_write([c3dPath filesep 'acquisition.xml'],acquisition,'acquisition',Pref);

disp('Any missing information will prevent .xml validation with its .xsd');

save_to_base(1)    %Allow to copy variables in the workspace

