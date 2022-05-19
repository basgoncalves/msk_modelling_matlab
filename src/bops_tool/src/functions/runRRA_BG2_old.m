function [outputFile] = runRRA_BG2(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, XMLTemplate, setupFiles, varargin)
% Function to run Residual Reduction Analysis for a single trial
% Input - 'osimModel' - string which is the filename (including path) of the
%                OSIM file (model file)
%         'coordinates_file' - desired kinematics MOT file for ID
%         'forces_file' - filename string of the XML file containing GRF
%         information
%   XMLTemplate (used until problems with API will be solved)
%   lowpassfcut (optional)
%         'RRATaskFile' - filename string of the Tasks XML file
%         'RRAForceFile' - filename string of the Actuator XML file
%         'RRAConstraintsFile' - File containing the constraints on the
%               controls. (No longer required)
%         'RRAControlsFile' - File containing the controls output by RRA.
%               These can be used to place constraints on the residuals
%               during CMC. (No longer required)
%
% will need functions - BG June 2020
%   OrganiseFAI
%   convertPathToLinux
%   relativepath
%   xml_read
%   btk_loadc3d
%   combineForcePlates_multiple
%   GCOS
%
% Notes:
%   * If RRA time window is defined as for example, 3.41-3.64s, the algorithm
%   runs during 3.41-3.639. Don't know why! 
%   RRArms window RRA and IK do not agree. RRA final = 3.6390 instead of 3.6400
%   Also, in the very last 0.1 second the sample frequency increases exponentially   
%   see ExampleData ..\residualReductionAnalysis\RunA1\RRA_10 and ...\RRA11
% 
% cutting tasks = from foot contact – 0.1 sec until foot off + 0.1 sec
% running tasks = max pelvis position (late swing) to max pelvis position (early swing) 
% SJ            =  1 sec before take-off (zero force level);



%%
import org.opensim.modeling.*
fp = filesep;
% Make copy of generic RRA tool setup to edit
rraXML = [];
rraTool=RRATool(XMLTemplate, 0);

%Set the model
rraTool.setModel(osimModel);
ModelFilename = char(osimModel.getDocumentFileName());
ModelFilename = convertPathToLinux(relativepath(ModelFilename,results_directory));
rraTool.setModelFilename(ModelFilename);
[~,trialName,~] = fileparts(fileparts(coordinates_file));
rraTool.setName(trialName)

rraTool.setReplaceForceSet(true);

rraTool.setResultsDir(convertPathToLinux(results_directory));
rraTool.setOutputPrecision(16)

for ii = 1:length(setupFiles)
    setupFiles{ii} = convertPathToLinux(relativepath(setupFiles{ii},results_directory));
end

% Setup files needed to run RRA
RRAForceSetFile = setupFiles{1};
RRATaskFile = setupFiles{2};
RRAConstraintsFile = setupFiles{3};

% Get mot data to determine time range (might have to be grf data
motData = Storage(coordinates_file);
grfData = Storage(GRFmot_file);
DirElaborated = fileparts(fileparts(fileparts(coordinates_file)));
DirC3D = strrep(DirElaborated,'ElaboratedData', 'InputData');
OrganiseFAI

%% Define times to perform analysis over - BG
% Get initial and intial time
IKdata = importdata ([DirIK fp trialName fp 'IK.mot']);
data = btk_loadc3d([DirC3D fp trialName '.c3d']);
fs_grf = data.fp_data.Info.frequency;
fs_markers = data.marker_data.Info.frequency;
fs_ratio = fs_grf/fs_markers;
if contains (trialName, 'run','IgnoreCase',1) && contains(trialName,'1')
    
    fileDir = [DirC3D fp trialName '.c3d'];
    GCtype = 2;     % from toe off to toe off (1 = foot contatc to foot contact; 2 = Foot-off to foot off )
    [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running (fileDir,TestedLeg,GCtype);
    cd([DirIK fp trialName])
    save ('GaitCycle','GaitCycle')

    final_time = GaitCycle.TO_time(2); 
    
    % find the peaks of veritcal displacement of the pelvis located immediately 
    % before and after the foot strike
    motion = 'pelvis_ty';
    [IKdata,T] = importIK(DirElaborated,trialName,motion);
    final_frame = find(T == final_time);
    [~,idPeaks] = findpeaks(IKdata);
    Pymax_after =idPeaks (min(find(idPeaks>final_frame)));  % frame with max Pelvis vertical BEFORE foot contact
    Pymax_before =idPeaks (max(find(idPeaks<final_frame))); % frame with max Pelvis vertical AFTER foot contact
    % find time for the determined frames
    initial_time = T(Pymax_before); 
    final_time = T(Pymax_after);
    
elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'2')
    TestedLeg = {'R'};
    fileDir = [DirC3D fp trialName '.c3d'];
    GCtype = 2;     % from toe off to toe off (1 = foot contatc to foot contact
    [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running (fileDir,TestedLeg,GCtype);
    initial_time = GaitCycle.FC_time - 0.1; 
    final_time = GaitCycle.TO_time + 0.1;
    
elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'3')
    TestedLeg = {'L'};
    fileDir = [DirC3D fp trialName '.c3d'];
    GCtype = 2;     % from toe off to toe off (1 = foot contatc to foot contact
    [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running (fileDir,TestedLeg,GCtype);
    initial_time = GaitCycle.FC_time - 0.1; 
    final_time = GaitCycle.TO_time + 0.1;
elseif contains(trialName,'SJ','IgnoreCase',1) 
   % add a "buffer zone" (min = 0.01 sec) - see notes*  
   vert = data.fp_data.FP_data(3).channels.Force_Fz3;
   [flight,idx] = find(vert==0);
   initial_time = (flight(1)-fs_grf)/fs_grf ; 
   final_time = motData.getLastTime(); 
elseif contains(trialName,'SquatNorm','IgnoreCase',1) 
    % check the point where the pelvis velocity goes below 0.001 m/s
    % check 0.5 sec bfore 
    Vy = diff(IKdata.data(:,6));
    time = (find(Vy< -0.001)-fs_markers/2)/fs_markers;
    initial_time = time(1);
    final_time = motData.getLastTime(); 
else
   initial_time = motData.getFirstTime(); 
   final_time = motData.getLastTime(); 
end

rraTool.setInitialTime(initial_time);
rraTool.setFinalTime(final_time);

%% Set optimiser settings and efine filepaths 
rraTool.setSolveForEquilibrium(false)
rraTool.setMaximumNumberOfSteps(20000)
%analyzeTool.setMaxDT(1e-005)
rraTool.setMaxDT(1)
rraTool.setMinDT(1e-008)
rraTool.setErrorTolerance(1e-005)

% Coordinates and external loads files
coordinates_file = convertPathToLinux(relativepath(coordinates_file,results_directory));
rraTool.setDesiredKinematicsFileName(coordinates_file);

external_loads_file = convertPathToLinux(relativepath(external_loads_file,results_directory));
rraTool.setExternalLoadsFileName(external_loads_file);

% Set actuators (force set) file
forceSet = ArrayStr();
forceSet.append(RRAForceSetFile);
rraTool.setForceSetFiles(forceSet);
rraTool.setLowpassCutoffFrequency(6); %the default value is -1.0, so no filtering

% define other input files
RRATaskFile = convertPathToLinux(relativepath(RRATaskFile,results_directory));
rraTool.setTaskSetFileName(RRATaskFile);
% rraTool.setConstraintsFileName(RRAConstraintsFile);

%% Save the settings in the Setup folder
setupFileDir=[results_directory];

% Define setup file name and output model name
setupFile='RRA_setup.xml';
[~ ,ModelName] = fileparts(char(osimModel.getDocumentFileName));

outputFile =[ModelName '_rra'];
outputModel = [results_directory fp outputFile '.osim'];
outputModel = convertPathToLinux(relativepath(outputModel,results_directory));

rraTool.setOutputModelFileName(outputModel);
rraTool.print([setupFileDir fp setupFile]);

%% change COM adjustments time window - BG
if contains(trialName,'SquatNorm','IgnoreCase',1) || contains(trialName,'SJ','IgnoreCase',1)
    initial_time = initial_time;
else
    
    acq = xml_read([DirC3D fp 'acquisition.xml']);
    
    % match name and number from acquisition file
    idx = find(strcmp({acq.Trials.Trial.Type},trialName(1:end-1)));
    idx = idx(find([acq.Trials.Trial(idx).RepetitionNumber] == str2double(trialName(end)))); % match number
    
    % find region where there is GRF in the forceplates where the foot hits the
    % plate
    FPN = find(contains({acq.Trials.Trial(idx).StancesOnForcePlatforms.StanceOnFP.leg},TestedLeg));
    idx =[];
    data = btk_loadc3d([DirC3D fp trialName '.c3d']);
    for pp = 1:length(FPN)
        Fz = data.fp_data.GRF_data(FPN(pp)).F(:,3); % vert GRF for the tested leg
        idx = unique([idx; find(Fz)]);
    end
    
    % find the time where FP and motio overlap
    fs_marker = data.marker_data.Info.frequency;
    fs_grf = data.fp_data.Info(1).frequency;
    fs_ratio = fs_grf/fs_marker;
    x = round(downsample(find(Fz),10)./fs_ratio);     % find frames where the force is present
    frameTime = 1/fs_marker;
    timeWindow = (x+data.marker_data.First_Frame)./fs_marker;
    
    initial_time = timeWindow(1);
end

% update setup xml 
RRA = xml_read ([setupFileDir fp setupFile]);
RRA.RRATool.initial_time_for_com_adjustment = initial_time;
RRA.RRATool.final_time_for_com_adjustment = RRA.RRATool.final_time;
% tranform these from double to string
RRA.RRATool.defaults.CMC_Joint.active = ['false ' 'false ' 'false'];
RRA.RRATool.defaults.PointActuator.point = ['0 ' '0 ' '0'];
RRA.RRATool.defaults.PointActuator.direction = ['-1 ' '0 ' '0'];
RRA.RRATool.defaults.TorqueActuator.axis = ['-1 ' '-0 ' '-0'];

root = 'OpenSimDocument';
xml_write([setupFileDir fp setupFile], RRA,root);

%% Run
disp('')
disp('')
disp('RRA window from TO to TO with mass ajusted during stance')
disp('Running residual reduction algorithm...')
disp('')

% run RRA and print log
fileout = [setupFileDir fp setupFile];
cd(fileparts(fileout))
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

% [~,itr] = fileparts(fileparts(fileout));
% motion = 'pelvis_ty'
% compareIKwithRRA (DirElaborated,trialName,motion,itr)

disp('')
disp('')
disp('Out and err log files printed')
disp('')




