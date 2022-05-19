%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               MOtoNMS                                   %
%                MATLAB MOTION DATA ELABORATION TOOLBOX                   %
%                 FOR NEUROMUSCULOSKELETAL APPLICATIONS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% runDataProcessing.m: Data Processing main function

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
% adapted by Basilio Goncalves 2022
%%

function []=runDataProcessing_BOPS

elaborationFileCreation_BOPS;                                                                                       % create elaboration xml

h = waitbar(0,'Elaborating data...Please wait!');

%% -----------------------PROCESSING SETTING-------------------------------
% Acquisition info loading, folders paths and parameters generation
%--------------------------------------------------------------------------
bops = load_setup_bops;
subject = load_subject_settings;

ElaborationFilePath = subject.directories.dynamicElaborations;
[foldersPath,parameters]= DataProcessingSettings(ElaborationFilePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                      OPENSIM Files Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Parameters List: Ri-nomination 
trialsList=parameters.trialsList; 
maxGapSize=parameters.interpolationMaxGapSize;

if isfield(parameters,'fcut')
    fcut=parameters.fcut;
end

fcut.emgbp = bops.filters.EMGbp;
fcut.emglp = bops.filters.EMGlp;

WindowsSelection=parameters.WindowsSelection;
StancesOnFP=parameters.StancesOnFP;

trcMarkersList=parameters.trcMarkersList;

globalToOpenSimRotations=parameters.globalToOpenSimRotations;
FPtoGlobalRotations=parameters.FPtoGlobalRotations;

motionDirections=parameters.motionDirection;

if isfield(parameters,'OutputFileFormats')
    MarkerOFileFormat=parameters.OutputFileFormats.MarkerTrajectories;
    GRFOFileFormat=parameters.OutputFileFormats.GRF;
else
    MarkerOFileFormat='.trc'; %set default output format
    GRFOFileFormat='.mot';
end
    
%Create Trails Output Dir
foldersPath.trialOutput= mkOutputDir(foldersPath.elaboration,trialsList);

%% ------------------------------------------------------------------------
%                            DATA LOADING 
%                   .mat data from SessionData Folder
%--------------------------------------------------------------------------
%loadMatData includes check for markers unit (if 'mm' ok else convert)
%Frames contains indication of first and last frame of labeled data, that
%must be the same for Markers and Analog Data and depends on the tracking
%process
%MarkersLabels MUST be the same for all dynamic trials BUT the order change
%according to the tracking process. Therefore, it's necessary to load them 
%for each trial to corretly select markers   
[MarkersRawData, MarkersLabels, Frames]=loadMatData(foldersPath.sessionData, trialsList, 'Markers');
FPRawData=loadMatData(foldersPath.sessionData, trialsList, 'FPdata');

% delete unused markers
for m = flip(1: length(trcMarkersList))         % loop through marker list TRC
    marker = trcMarkersList{m};                 
    for t = 1 : length (MarkersLabels)          % loop through trials
        if isempty(find(strcmp(marker, MarkersLabels{t}), 1))
            trcMarkersList(m)=[];
            break
        end                  
    end 
end

%Loading FrameRates
load([foldersPath.sessionData 'Rates.mat']) 

VideoFrameRate=Rates.VideoFrameRate;
AnalogFrameRate=Rates.AnalogFrameRate;

%Loading ForcePlatformInfo
load([foldersPath.sessionData 'ForcePlatformInfo.mat'])
nFP=length(ForcePlatformInfo);

if isfield(parameters,'platesPad')
    padsThickness=parameters.platesPad;
else
    padsThickness=zeros(1,nFP);
end

%Loading AllTrialsName
load([foldersPath.sessionData 'trialsName.mat'])

%Loading All Markers Labels (Raw)
%NOTE: the order change according to the tracking process, so it might be
%useful to know the markers used in the acquisition session but it can't be 
%used to select markers for each trial
%load([foldersPath.sessionData 'dMLabels.mat'])

disp('Data have been loaded from mat files')         

%% ------------------------------------------------------------------------
%                     Preparing Data for Filtering
%--------------------------------------------------------------------------

%-------------------------Markers Selection--------------------------------
%markers to be written in the trc file: only those are processed
for k=1:length(trialsList)
    markerstrc{k} = selectingMarkers(trcMarkersList,MarkersLabels{k},MarkersRawData{k});
end
%-----------Check for markers data missing and Interpolation--------------

[MarkersNan,index]=replaceMissingWithNaNs(markerstrc); 
 
[interpData,note] = DataInterpolation(MarkersNan, index, maxGapSize);                                               %if there are no missing markers, it doesn't interpolate
 
writeInterpolationNote(note,foldersPath.trialOutput);

[Forces,Moments,COP]= AnalogDataSplit(FPRawData,ForcePlatformInfo);

waitbar(1/7);    

%% ------------------------------------------------------------------------
%                         DATA FILTERING 
%--------------------------------------------------------------------------
%filter parameters: only fcut can change, order and type of filter is fixed
%Output: structure with filtered data from all selected trials

%----------------------------Markers---------------------------------------
if (exist('fcut','var') && isfield(fcut,'m'))
   filtMarkers=DataFiltering(interpData,VideoFrameRate,fcut.m,index);
else
    filtMarkers=interpData;
end
 
%----------------------------Analog Data-----------------------------------
checkFPsType(ForcePlatformInfo)
%assumptions: 
% -FPs can be of different types ONLY if type 1 is not included (i.e. there 
%can be FPs of type 2,3,4 together OR all of type 1).
%Data from FP of type 1 require a different elaboration, but at this point
%data from all the FPs are grouped togheter so that it is not possible to
%process them differently without changing the main structure of the code.

switch ForcePlatformInfo{1}.type   %assumption: FPs are of the same type
    
    case {2,3,4}
        if (exist('fcut','var') && isfield(fcut,'f'))
            filtForces=DataFiltering(Forces,AnalogFrameRate,fcut.f);
            filtMoments=DataFiltering(Moments,AnalogFrameRate,fcut.f);
        else
            filtForces=Forces;
            filtMoments=Moments;
        end
        [ForcesThr,MomentsThr]=FzThresholding(filtForces,filtMoments);                                              % In this case, COP have to be computed Necessary Thresholding for COP computation
        
        for k=1:length(filtMoments)
            for i=1:nFP
                COP{k}(:,:,i)=computeCOP(ForcesThr{k}(:,:,i),MomentsThr{k}(:,:,i),ForcePlatformInfo{i},padsThickness(i));
            end
        end
        
        filtCOP=COP; %not necessary to filter the computed cop
        
    case 1                                                                                                          % Padova type: it returns Px & Py
        
        if (exist('fcut','var'))
            if isfield(fcut,'f')
                filtForces=filteringDataFPtype1(Forces,AnalogFrameRate,fcut.f,'Forces');
                filtMoments=filteringDataFPtype1(Moments,AnalogFrameRate,fcut.f,'Moments');
            else
                filtForces=Forces;
                filtMoments=Moments;
            end
            
            if isfield(fcut,'cop')
                filtCOP=filteringDataFPtype1(COP,AnalogFrameRate,fcut.cop,'COP');
            else
                filtCOP=COP;
            end
            
        else
            filtForces=Forces;
            filtMoments=Moments;
            filtCOP=COP;
        end
        [ForcesThr,MomentsThr]=FzThresholding(filtForces,filtMoments);                                              % Threasholding also here for uniformity among the two cases
end

disp('Data have been filtered')
clear MarkersRawData ForcesRawData AnalogRawData                                                                    % For next steps, only filtered data are kept                                                  
waitbar(2/7);   
%% ------------------------------------------------------------------------
%                      START/STOP COMPUTATION
%--------------------------------------------------------------------------
%Different AnalysisWindow computation methods may be implemented according to the application
% To select the AnalysisWindow, noise Thresholded Forces are used
AnalysisWindow=AnalysisWindowSelection(WindowsSelection,StancesOnFP,filtForces,Frames,Rates);

saveAnalysisWindow(foldersPath.trialOutput,AnalysisWindow)

%% ------------------------------------------------------------------------
%                        DATA WINDOW SELECTION
%--------------------------------------------------------------------------
[MarkersFiltered,Mtime]=selectionData(filtMarkers,AnalysisWindow,VideoFrameRate);                                   % [MarkersFiltered,Mtime]=selectionData(filtMarkersCorrected,AnalysisWindow,VideoFrameRate);
[ForcesFiltered,~]      = selectionData(ForcesThr,AnalysisWindow,AnalogFrameRate);
[MomentsFiltered,~]     = selectionData(MomentsThr,AnalysisWindow,AnalogFrameRate);
[COPFiltered,Ftime]     = selectionData(filtCOP,AnalysisWindow,AnalogFrameRate);

%% ------------------------------------------------------------------------
%                     SAVING Filtered Selected Data
%--------------------------------------------------------------------------
disp('Saving filtered data (markers,forces,moments,COP)...')
saveFilteredData(foldersPath.trialOutput, Mtime, MarkersFiltered,'Markers')
saveFilteredData(foldersPath.trialOutput, Ftime, ForcesFiltered,'Forces')
saveFilteredData(foldersPath.trialOutput, Ftime, MomentsFiltered,'Moments')
saveFilteredData(foldersPath.trialOutput, Ftime, COPFiltered,'COP')
waitbar(3/7);   

%% ------------------------------------------------------------------------
%                           WRITE TRC
%--------------------------------------------------------------------------

if strcmp(MarkerOFileFormat, '.trc')
    for k=1:length(trialsList)
        
        FullFileName=[foldersPath.trialOutput{k} 'markers.trc'];
       
        rotatedMarkers{k}=RotateCS(MarkersFiltered{k},globalToOpenSimRotations);

        
        markersMotionDirRotOpenSim{k}=rotatingMotionDirection(motionDirections{k},rotatedMarkers{k});               %accounting for the possibility of different directions of motion
        
        CompleteMarkersData=[Mtime{k} markersMotionDirRotOpenSim{k}];                                               %createtrc(MarkersFiltered{k},Mtime{k},trcMarkersList,globalToOpenSimRotations,VideoFrameRate,FullFileName)

        writetrc(CompleteMarkersData,trcMarkersList,VideoFrameRate,FullFileName)
        
    end
else
    disp(' ')
    error('ErrorTests:convertTest', ...
        ['----------------------------------------------------------------\n'...
        'WARNING: WRONG Marker Trajectories Output File Format!\nOnly .trc is'...
        'available in the current version. Please, check it in your elaboration.xml file'])
end

waitbar(4/7);   
%% ------------------------------------------------------------------------
%                           WRITE MOT
%--------------------------------------------------------------------------

for k=1:length(trialsList)
    
    globalMOTdata{k}=[];
    
    for i=1:nFP
        
        Torques{k}(:,:,i)= computeTorque(ForcesFiltered{k}(:,:,i),MomentsFiltered{k}(:,:,i), COPFiltered{k}(:,:,i), ForcePlatformInfo{i});
        
        globalForces{k}(:,:,i)= RotateCS (ForcesFiltered{k}(:,:,i),FPtoGlobalRotations(i));
        globalTorques{k}(:,:,i)= RotateCS (Torques{k}(:,:,i),FPtoGlobalRotations(i));
        globalCOP{k}(:,:,i) = convertCOPToGlobal(COPFiltered{k}(:,:,i),FPtoGlobalRotations(i),ForcePlatformInfo{i});
        
        globalMOTdata{k}=[globalMOTdata{k} globalForces{k}(:,:,i) globalCOP{k}(:,:,i) ];        
    end
    
    for i=1:nFP
        
        globalMOTdata{k}=[globalMOTdata{k} globalTorques{k}(:,:,i) ];      
    end
        
    MOTdataOpenSim{k}=RotateCS (globalMOTdata{k},globalToOpenSimRotations);                                         % Rotation for OpenSim  
    MOTrotDataOpenSim{k}=rotatingMotionDirection(motionDirections{k},MOTdataOpenSim{k});                            % accounting for the possibility of different directions of motion
    
    if strcmp(GRFOFileFormat, '.mot')
        FullFileName=[foldersPath.trialOutput{k} 'grf.mot'];                                                        % Write MOT
        writeMot(MOTrotDataOpenSim{k},Ftime{k},FullFileName)
        
    else
        error('ErrorTests:convertTest', ...
            ['----------------------------------------------------------------\n'...
            'WARNING: WRONG GRF Output File Format!\nOnly .mot is available in the'...
            'current version. Please, check it in your elaboration.xml file'])
    end    
end

waitbar(5/7);

save_to_base(1)                                                                                                     % save_to_base() copies all variables in the calling function to the base
% workspace. This makes it possible to examine this function internal
% variables from the Matlab command prompt after the calling function
% terminates. Uncomment the following command if you want to activate it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           EMG PROGESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(parameters,'EMGsSelected')
    
    disp(' ')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('             EMG PROCESSING                    ')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
     
    EMGsSelected_OutputLabels= parameters.EMGsSelected.OutputLabels;
    EMGsSelected_C3DLabels= parameters.EMGsSelected.C3DLabels;
    EMGOffset=parameters.EMGOffset;
    MaxEmgTrialsList=parameters.MaxEmgTrialsList;
    
    if isfield(parameters,'OutputFileFormats')
        EMGOFileFormat=parameters.OutputFileFormats.EMG;
    else
        EMGOFileFormat='.mot';                                                                                      % default EMG output file format
    end
    
    foldersPath.maxemg=[foldersPath.elaboration filesep 'maxemg'];
    mkdir(foldersPath.maxemg)
    
    [AnalogRawData,AnalogDataLabels,aFrames,aUnits]=loadMatData(foldersPath.sessionData,trialsList,'AnalogData');   % Loading Analog Raw Data from the choosen trials with the corresponding labels
    
    if isequal(parameters.MaxEmgTrialsList,parameters.trialsList)                                                   % Loading Analog Raw Data for EMG Max Computation from the trials list
        AnalogRawForMax=AnalogRawData;
        AnalogLabelsForMax=AnalogDataLabels;
    else
        [AnalogRawForMax, AnalogLabelsForMax]=loadMatData(foldersPath.sessionData, MaxEmgTrialsList, 'AnalogData');
    end
      
    
    if (isempty(AnalogRawData)==0 && isempty(AnalogDataLabels)==0)                                                  % If there are EMGs --> processing
    %% --------------------------------------------------------------------
    %                   EMGs EXTRACTION and MUSCLES SELECTION
    %                   EMGs Arrangement for the Output file
    %----------------------------------------------------------------------
             
        for k=1:length(trialsList)
            EMGselectionIndexes{k}          = findIndexes(AnalogDataLabels{k},EMGsSelected_C3DLabels);
            EMGsSelected{k}                 = AnalogRawData{k}(:,EMGselectionIndexes{k});
            EMGsUnits{k}                    = aUnits{k}(EMGselectionIndexes{k});
        end
        
        for k=1:length(MaxEmgTrialsList)            
            EMGselectionIndexesForMax{k}    = findIndexes(AnalogLabelsForMax{k},EMGsSelected_C3DLabels);
            EMGsSelectedForMax{k}           = AnalogRawForMax{k}(:,EMGselectionIndexesForMax{k});
        end
        
        %% ------------------------------------------------------------------------
        %                       EMG FILTERING: ENVELOPE
        %--------------------------------------------------------------------------
        EMGsEnvelope=EMGFiltering(EMGsSelected,AnalogFrameRate,fcut.emgbp,fcut.emglp);                               %fcut for EMG assumed fixed (6Hz)
        
        EMGsEnvelopeForMax=EMGFiltering(EMGsSelectedForMax,AnalogFrameRate,fcut.emgbp,fcut.emglp);
        
        %% ------------------------------------------------------------------------
        %                      EMG ANALYSIS WINDOW SELECTION
        %--------------------------------------------------------------------------
        AnalysisWindowEMG =AnalysisWindow;                                                                          % add the EMG offset to the window selection of the EMG
        for k = 1:length(AnalysisWindowEMG)
            if AnalysisWindowEMG{1,k}.startFrame-EMGOffset*AnalysisWindowEMG{1,k}.rate < 0
                cprintf('yellow', [trialsList{k} ' doesn''t have enough buffer for EMG offset \n' ])
            else
                AnalysisWindowEMG{1,k}.startFrame =  AnalysisWindowEMG{1,k}.startFrame-EMGOffset*AnalysisWindowEMG{1,k}.rate;
            end
        end

        [EMGsFiltered,EMGtime]  = selectionData(EMGsEnvelope,AnalysisWindowEMG,AnalogFrameRate,0);
        EMGsForMax              = EMGsEnvelopeForMax; 
        %% ------------------------------------------------------------------------
        %                        COMPUTE MAX EMG VALUES
        %--------------------------------------------------------------------------
        [MaxEMG_aframes, numMaxEMG_trials,MaxEMGvalues]=computeMaxEMGvalues(EMGsForMax);
        
        disp('Max values for selected emg signals have been computed')        
        sMaxEMG_trials=MaxEmgTrialsList(numMaxEMG_trials);        
        MaxEMG_time=MaxEMG_aframes/AnalogFrameRate;

        printMaxEMGvalues(foldersPath.maxemg, EMGsSelected_C3DLabels, MaxEMGvalues, sMaxEMG_trials, MaxEMG_time);   % print maxemg.txt
        
        disp('Printed maxemg.txt')
        waitbar(6/7);
        
        %% ------------------------------------------------------------------------
        %                            NORMALIZE EMG
        %--------------------------------------------------------------------------
        NormEMG=normalizeEMG(EMGsFiltered,MaxEMGvalues);
        
        %% ------------------------------------------------------------------------
        %                          SAVING and PLOTTING
        %--------------------------------------------------------------------------
        MaxEMGstruct.values         = MaxEMGvalues;                                                                           % storing all info related to max EMGs in a struct
        MaxEMGstruct.muscles        = EMGsSelected_C3DLabels;
        MaxEMGstruct.aframes        = MaxEMG_aframes;
        MaxEMGstruct.time           = MaxEMG_time;
        MaxEMGstruct.trials         = numMaxEMG_trials;
        MaxEMGstruct.trialNames     = sMaxEMG_trials;        
        % ------------------------------------------------------------------------
        %                            PRINT emg.txt
        %--------------------------------------------------------------------------
        availableFileFormats=['.txt', ' .sto', ' .mot'];
        
        switch EMGOFileFormat
            
            case '.txt'
                for k=1:length(trialsList)  
                    printEMGtxt(foldersPath.trialOutput{k},EMGtime{k},NormEMG{k},EMGsSelected_OutputLabels);
                end
                        
            case {'.sto','.mot'}   
                for k=1:length(trialsList)        
                    printEMGmot(foldersPath.trialOutput{k},EMGtime{k},NormEMG{k},EMGsSelected_OutputLabels, EMGOFileFormat);
                end
            
            otherwise
                error('ErrorTests:convertTest', ...
                    ['----------------------------------------------------------------\n'...
                    'WARNING: EMG Output File Format not Available!\nChoose among: ['...
                    availableFileFormats ']. Please, check it in your elaboration.xml file'])
        end
        
        disp(['Printed emg' EMGOFileFormat])
        waitbar(7/7);
        close(h)
    else
        waitbar(6/7);
        disp('Check your data and/or your configuration files: No EMG raw data to be processed')
        waitbar(7/7);
        close(h)
    end
else
        waitbar(6/7);
        disp(' ')
        disp('EMGs not collected')
        waitbar(7/7);
        close(h)
end
%% -------------------------------------------------------------------------
disp('-------------------------------------------')
disp('')
disp('Dynamic elaborations finished  successfully')
disp('')
disp('-------------------------------------------')
save_to_base(1)
