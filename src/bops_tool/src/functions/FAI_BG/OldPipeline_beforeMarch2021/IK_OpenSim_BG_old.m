% Setup Inverse kinematiks Basilio Goncalves 2019

function [IK,IKxmlPath,DirTemplate_xml,C3DTrialName,model_file] = IK_OpenSim_BG_old (DirC3D,DirTemplate_xml,C3DTrialName,model_file,accuracy,AnalysisType)


OrganiseFAI                 % Script to create directories (if DirC3D

IKPath = DirIK;
mkdir (IKPath);
%% Check if old xml exists
if exist('DirTemplate_xml')==0 || exist(DirTemplate_xml)~=2 || isempty(DirTemplate_xml)
    [filename,path] = uigetfile([filesep '*.xml'],'Select template IK.xml file to load', pwd);
    DirTemplate_xml = [path filename];
end
%% Check if c3d exists
cd(DirC3D)
if ~exist('C3DTrialName') || ~contains(class(C3DTrialName),'char') || isempty(C3DTrialName)
    [C3DTrialName,~] = uigetfile...
        ([DirC3D filesep '*.c3d'],'Select your .c3d file to load', pwd);
end

if ~contains (C3DTrialName, '.c3d')
    TrialName = C3DTrialName;
    C3DTrialName =[C3DTrialName '.c3d'];
else
    TrialName = regexprep(C3DTrialName, '.c3d','');
end

%% Load c3d
filename = [DirC3D filesep C3DTrialName];
data = btk_loadc3d(filename);          %callback
fs= data.marker_data.Info.frequency;
%% change the name of the TRC file to matach location of the static .TRC
data.TRC_Filename = ([DirElaborated filesep 'dynamicElaborations' filesep...
    TrialName filesep TrialName '.trc']);
data.GRF_Filename = ([DirElaborated filesep 'dynamicElaborations' filesep...
    TrialName filesep TrialName '.mot']);
%%  load the used markers from the elaboration XML
ElaborationXML = xml_read([ElaborationFilePath filesep 'elaboration.xml']);
usedMarkers=regexp(ElaborationXML.Markers,' ','split')';

oldIKSetup = xml_read(DirTemplate_xml);

%% Get the model
if ~exist('model_file') || ~isfile(model_file)|| isempty(model_file)
    cd(DirElaborated)
    [modelFile,modelFilePath,~] = ...
        uigetfile('*.osim','Choose the the scaled .osim model file to be used.');
    model_file = [modelFilePath modelFile];
    osimModel = Model(model_file);
    osimModel.initSystem();
end

%% accuracy options (default from 10e-12 to 10e-2)
if ~exist('accuracy')
    % create a list of accuracies between 10e-12 to 10e-2
    ExpList =10*10.^((-13:-3));
    AccuracyLists={};
    for ll = 1: length (ExpList)
        ac = num2str(ExpList(ll));
        AccuracyLists{ll} =ac;
    end
    [idx,~] = listdlg('PromptString',{'Choose the varibales to plot kinematics'},'ListString',AccuracyLists);
    
    accuracy =str2num(AccuracyLists {idx});
end

%% Gait cycle (made from acceletations, may need editing)

[foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running (filename,TestedLeg,GaitCycleType);

%% Edit xml file
IK = oldIKSetup;
ResultsDir =[IKPath filesep TrialName];

IK.InverseKinematicsTool.marker_file = data.TRC_Filename;
IK.InverseKinematicsTool.model_file = model_file;
IK.InverseKinematicsTool.output_motion_file = [ResultsDir filesep 'IK.mot'];
IK.InverseKinematicsTool.results_directory = ResultsDir;
mkdir (ResultsDir);
IK.InverseKinematicsTool.accuracy = accuracy;

% find the minimal and maximal frame index that contains all marker and use
% those to crop the trial. OPENSIM does not work with NANs created in the
% TRC when the markers are not visible
markers = usedMarkers;
initialFrame = 1;

[Nrow, ~]= size(data.marker_data.Markers.(markers{1}));
finalFrame = Nrow;
Threshold = 0.8;

%% find first row with at least 80% markers visible
for FirstRow = 1:Nrow
    emptyRows = 0;
    for m = 1: length (markers)
        if data.marker_data.Markers.(markers{m})(FirstRow,1)==0         %check if row is empty
            emptyRows = emptyRows +1;   
        end
    end  
    if emptyRows < (1- Threshold)*length (markers)
        initialFrame = FirstRow;
        break
    end
end

%% find last row with at least 80% markers visible
for LastRow = FirstRow:Nrow
    emptyRows = 0;
    for m = 1: length (markers)
        if data.marker_data.Markers.(markers{m})(LastRow,1)==0              %check if row is empty
            emptyRows = emptyRows +1;    
        end
    end 
    if emptyRows > Threshold*length (markers)
        finalFrame = LastRow;
        break
    end
end

%% Calculate time window for openSim
OpenSimOffset = data.marker_data.First_Frame;
initialFrame = initialFrame+3;                     % add and remove 2 frames from the where cropping the trial
finalFrame = finalFrame-3;
time_range = [(initialFrame+OpenSimOffset)/fs (finalFrame+OpenSimOffset)/fs];
IK.InverseKinematicsTool.time_range = time_range;

GaitCycle.FirstFrameC3D = data.marker_data.First_Frame;
GaitCycle.FirstFrameOpenSim = time_range(1)*fs;
GaitCycle.FinalFrameOpenSim = time_range(2)*fs;
%% delete unused markers
xmlMarkers = oldIKSetup.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask;
deltedMarkers={};
for m = 1: length (xmlMarkers)
    nameMarker = xmlMarkers(m).ATTRIBUTE.name;
    if  isempty(find(strcmp(nameMarker, usedMarkers), 1))
        xmlMarkers(m).apply = 'false';
        deltedMarkers{end+1} = nameMarker;
    end
end
IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask= xmlMarkers;

%% write xml and save gait cycle events
root = 'OpenSimDocument';
fileout = ['setup_IK.xml'];
IKxmlPath = [ResultsDir filesep fileout];

cd(ResultsDir)
Pref.StructItem = false;

xml_write(IKxmlPath, IK, root,Pref);
TrialSave = sprintf('GaitCycle');
save (TrialSave,'GaitCycle')

%% Run openSimAPI

% generate onverse kinematic analysis
if ~exist('AnalysisType')|| AnalysisType==1

    import org.opensim.modeling.*
    
    cd(fileparts(IKxmlPath))
    [~,log_mes] = dos(['ik -S ' IKxmlPath],'-echo');
    
    %Save the log file in a Log folder for each trial
    fid = fopen([ResultsDir fp 'out.log'],'w+');
    fprintf(fid,'%s\n', log_mes);
    fclose(fid);
    
    disp([TrialName ' IK Done.']);
end

