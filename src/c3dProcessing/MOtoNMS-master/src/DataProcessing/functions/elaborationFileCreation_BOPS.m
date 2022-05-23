function [] = elaborationFileCreation_BOPS(varargin)
% Function to generate elaboration.xml file

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
%
% Adapted Basilio Goncalves (2019)
% Added Functions:
%

%% -------------------------Initial Settings-------------------------------
%create a cell from char values read from acquisition.xml for the selection
%of Markers to be written in the trc file
%needed for trcMarkersIndexes computation within case nargin>3

bops = load_setup_bops;
subject = load_subject_settings;

acquisitionInfo         =   xml_read([subject.directories.acquisitionXML]);
oldElaboration          =   xml_read(bops.directories.templates.elaborationXML);
MarkersSet              =   textscan(acquisitionInfo.MarkersProtocol.MarkersSetDynamicTrials, '%s','delimiter', ' ');
MarkersSet              =   MarkersSet{1};

% --------------------------Trials Selection-------------------------------
trialList               =   subject.trials.trialList;
dynamicTrials           =   subject.trials.dynamicTrials;
maxEMGTrials            =   subject.trials.maxEMGTrials;

fcut                    =   bops.filters;

if nargin>2                                                                                                         % Definition of Lists Initial Values
    
    oldParameters       =   parametersGeneration(oldElaboration);
    
    trialsIndexes       =   findIndexes(dynamicTrials,oldParameters.trialList);                                    % find indexes for the listdlg command
    trcMarkersIndexes   =   findIndexes(MarkersSet,oldParameters.trcMarkersList);
    
    InitialValue.Trials                     =   trialsIndexes;
    InitialValue.WindowsSelection.Method    =   oldParameters.WindowsSelection.Method;
    InitialValue.MarkersList                =   trcMarkersIndexes;
    
    if isfield(oldParameters,'OutputFileFormats')
        if isfield(oldParameters.OutputFileFormats,'MarkerTrajectories')
            InitialValue.OutputFileFormats.MarkerTrajectories   =   oldParameters.OutputFileFormats.MarkerTrajectories;
        else
            InitialValue.OutputFileFormats.MarkerTrajectories   =   '.trc';
        end
        
        if isfield(oldParameters.OutputFileFormats,'GRF')
            InitialValue.OutputFileFormats.GRF = oldParameters.OutputFileFormats.GRF;
        else
            InitialValue.OutputFileFormats.GRF = '.mot';
        end
        
        if isfield(oldParameters.OutputFileFormats,'EMG')
            InitialValue.OutputFileFormats.EMG =  oldParameters.OutputFileFormats.EMG;
        else
            InitialValue.OutputFileFormats.EMG = '.mot';
        end
    else
        
        InitialValue.OutputFileFormats.MarkerTrajectories ='.trc';                                                  % Default file formats
        InitialValue.OutputFileFormats.GRF = '.mot';
        InitialValue.OutputFileFormats.EMG = '.mot';
    end
    
else
    InitialValue.Trials=[];
    InitialValue.MarkersList=[];
    InitialValue.WindowsSelection.Method='.';
    
    InitialValue.OutputFileFormats.MarkerTrajectories='.trc';                                                       % Output file formats: default file formats
    InitialValue.OutputFileFormats.GRF='.mot';
    InitialValue.OutputFileFormats.EMG='.mot';
end

%% ----------------------- EMGs settings -----------------------
if isfield(acquisitionInfo,'EMGs')                                                                                  % there are EMGs --> they will be processed
    if nargin>2                                                                                                     % Definition of EMGs Lists Initial Values
        emgMaxTrialsIndexes         =   findIndexes(maxEMGTrials,oldParameters.MaxEmgTrialsList);
        InitialValue.emgMaxTrials   =   emgMaxTrialsIndexes;
    else
        InitialValue.emgMaxTrials   =   [];
    end
    InstrumentedLeg                 =   acquisitionInfo.EMGs.Protocol.InstrumentedLeg;                              % Leg Definition (required for Analysis Window Definition Method)
    EMGfound=1;
    
else
    EMGfound=0;
    InstrumentedLeg='None';
    
end

oldemglabels = {oldElaboration.EMGsSelection.EMGs.EMG.C3DLabel};
c3dFilePathAndName = [subject.directories.Input fp trialList{1} '.c3d'];
[~, AnalogData, ~, ~, ~, ~] = getInfoFromC3D(c3dFilePathAndName);
EMGlabels = sort(AnalogData.Labels);

if any(contains(EMGlabels,oldemglabels)~=1)
    [indx,~] = listdlg('PromptString','select EMG input signals','ListString',EMGlabels); 
    EMGlabels = EMGlabels(indx);
end

EMG = struct;
for i = 1:length(EMGlabels)
    EMG(i).C3DLabel = EMGlabels{i};
    EMG(i).OutputLabel = acquisitionInfo.EMGs.Channels.Channel(i).Muscle;
end
oldElaboration.EMGsSelection.EMGs.EMG = EMG;
oldElaboration.EMGsSelection.EMGSet = acquisitionInfo.EMGs.Protocol.Name;

Pref.StructItem     = false;                                                                                        % update template if needed to avoid asking again
Pref.ItemName       = 'TrialWindow';
xml_write(bops.directories.templates.elaborationXML,oldElaboration,'elaboration',Pref);
%--------------------------------------------------------------------------
%% ------------------------FCUTs Definition--------------------------------

trialsTypeList = trialsTypeIdentification(trialList);

%--------------------Definition of Default Values--------------------------
num_lines = 1;
options.Resize='on';
options.WindowStyle='modal';

if (nargin>2 && isfield(oldParameters,'fcut'))
    
    oldTrialsTypeList = trialsTypeIdentification(oldParameters.trialList);
    
    if isfield(oldParameters.fcut,'m')
        def_m = getDefValuesForFiltering(trialsTypeList,oldTrialsTypeList, oldParameters.fcut.m);
    end
    
    if isfield(oldParameters.fcut,'f')
        def_f=getDefValuesForFiltering(trialsTypeList,oldTrialsTypeList, oldParameters.fcut.f);
    end
    
    if isfield(oldParameters.fcut,'cop')
        def_cop=getDefValuesForFiltering(trialsTypeList, oldTrialsTypeList, oldParameters.fcut.cop);
    end
end

%--------------------------MARKERS Filtering-------------------------------

% Markers Filter cut off frequency
if isfield (fcut,'Markers')
    m_fcut = repmat({fcut.Markers},1,length(trialsTypeList));
end

%-------------------------FORCES Filtering---------------------------------
if isfield (fcut,'Force')
    f_fcut = repmat({fcut.Force},1,length(trialsTypeList));
end

%-------------------------COP Filtering------------------------------------
%Ask for COP Filter cut off frequency if Force Plates are of type 1
% Forceplate types = http://www2.projects.science.uu.nl/umpm/c3dformat_ug.pdf
for i=1: size(acquisitionInfo.Laboratory.ForcePlatformsList.ForcePlatform,2)
    FPsType(i)=acquisitionInfo.Laboratory.ForcePlatformsList.ForcePlatform(i).Type;
end

if  FPsType==1  %check both FPs
    
    fcCopChoice = questdlg('Do you want to filter COP?', ...
        'COP Filtering', ...
        'Yes','No','Yes');
    
    if strcmp(fcCopChoice,'Yes')==1
        
        dlg_title='Choose Cut Off Frequency for COP Filtering';
        
        for i=1:length(trialsTypeList)
            prompt{i} = trialsTypeList{i};
        end
        
        answer = inputdlg(prompt,dlg_title,num_lines,def_cop,options);
        
        cop_fcut_xType=answer';
        cop_fcut=fromTypeToSingle(trialList,trialsTypeList,cop_fcut_xType);
    end
    
end

%--------------------------------------------------------------------------
%% ------------------Analysis Window Definition Method---------------------

method='Manual';
WindowSelectionProcedure=struct;
WindowSelectionProcedure.(method).TrialWindow(1).TrialName = '';                                                    
WindowSelectionProcedure.(method).TrialWindow(1).StartFrame = 1;
WindowSelectionProcedure.(method).TrialWindow(1).EndFrame= 10;
disp(' ')
disp('finding events for the elaboration xml...')
disp(' ')
TrialString = [];
count = 1;

for tt = 1:length(dynamicTrials)                                                                    
    trialName = dynamicTrials{tt};
    [~,FrameWindow,~] = TimeWindow_BOPS(trialName);
    if isempty(FrameWindow) || length(FrameWindow)<2
        continue
    end
    TrialString = [TrialString trialName ' '];
    WindowSelectionProcedure.(method).TrialWindow(count).TrialName      = trialName;
    WindowSelectionProcedure.(method).TrialWindow(count).StartFrame     = FrameWindow(1);
    WindowSelectionProcedure.(method).TrialWindow(count).EndFrame       = FrameWindow(2);                         
    count = count+1;
end

if isempty(TrialString)
    TrialString = struct;
end

%% ---------------Markers Interpolation ------------------------
%Fix by default: the value can be changed manuallly in the elaboration.xml
if (nargin>2 && isfield(oldParameters,'MarkersInterpolation'))
    MaxGapSize_default=oldParameters.interpolationMaxGapSize;
else
    referenceValue=15; %fix considering a VideoFrameRate of 60 Hz
    MaxGapSize_default=referenceValue/60*acquisitionInfo.VideoFrameRate;
end

%Filtering Parameters
if (exist('m_fcut','var') || exist('f_fcut','var'))
    for i=1:length(trialList)
        Filtering.Trial(i).Name=trialList{i};
        if  exist('m_fcut','var')
            Filtering.Trial(i).Fcut.Markers = m_fcut{1};
        end
        if exist('f_fcut','var')
            Filtering.Trial(i).Fcut.Forces = f_fcut{1};
        end
        if exist('cop_fcut','var')
            Filtering.Trial(i).Fcut.CenterOfPressure = cop_fcut{1};
        end
    end
end

% Markers List for .trc file (Delete unused markers)
MarkersList=MarkersSet(:);
for tt = 1:length(dynamicTrials)
    MarkersList = deleteMissingMarkers(subject.directories.Input,dynamicTrials{tt},MarkersList);
end

MarkersStrig=[];
for i=1:length(MarkersList)
    MarkersStrig=[MarkersStrig MarkersList{i} ' '];
end

%--------------------------------------------------------------------------
%% -------------------------- EMGs Selection ------------------------------
%if EMG signals have been acquired

EMGMaxTrials=[];
if true(EMGfound)
    % ----------------------Trials for EMG MAX computation---------------------
    for i=1:length(maxEMGTrials)
        EMGMaxTrials=[EMGMaxTrials maxEMGTrials{i} ' '];
    end
end
%% ------------------Elaboration structure definition------------------
elaboration = struct;
elaboration.FolderName                          = relativepath(subject.directories.Input,bops.directories.mainData);
elaboration.Trials                              = TrialString;
elaboration.Markers                             = MarkersStrig;
elaboration.MarkersInterpolation.MaxGapSize     = MaxGapSize_default;
elaboration.WindowSelectionProcedure            = WindowSelectionProcedure;
elaboration.Filtering                           = Filtering;
elaboration.EMGMaxTrials                        = EMGMaxTrials;
elaboration.EMGsSelection                       = oldElaboration.EMGsSelection;
elaboration.EMGOffset                           = bops.emg.offset; 
elaboration.OutputFileFormats                   = InitialValue.OutputFileFormats;

%---------------------Elaboration.xml writting-----------------------------
Pref.StructItem     = false;  %to not have arrays of structs with 'item' notation
Pref.ItemName       = 'TrialWindow';
xml_write([subject.directories.elaborationXML],elaboration,'elaboration',Pref);

save_to_base(1)

disp ('elaboration.xml created')