% Setup Inverse kinematiks Basilio Goncalves 2019

function osimFiles = InverseKinematics_FAI (Dir, Temp, trialName,Logic)

fp = filesep;
warning off
accuracy = 10*10.^-7;



TimeWindow = TimeWindow_FatFAIS(Dir,trialName);
DirIKtrial = [Dir.IK fp trialName]; mkdir(DirIKtrial); cd(DirIKtrial)
[osimFiles] = getosimfilesFAI(Dir,trialName,[Dir.IK fp trialName]);
if Logic==2 && exist(osimFiles.IKresults); return; end
% Check if files needed exists
ElaborationXML = xml_read([Dir.dynamicElaborations fp 'elaboration.xml']);
usedMarkers = regexp(ElaborationXML.Markers,' ','split')';

copyfile(osimFiles.coordinates,DirIKtrial)
copyfile(osimFiles.externalforces,DirIKtrial)

%% Edit xml file
IK = xml_read(Temp.IKSetup);
IK.InverseKinematicsTool.COMMENT = {};
IK.InverseKinematicsTool.ATTRIBUTE.name = trialName;
IK.InverseKinematicsTool.time_range = TimeWindow; 
IK.InverseKinematicsTool.marker_file = osimFiles.IKcoordinates;
IK.InverseKinematicsTool.model_file = osimFiles.LinearScaledModel;
IK.InverseKinematicsTool.output_motion_file = osimFiles.IKresults;
IK.InverseKinematicsTool.results_directory = osimFiles.IK;
IK.InverseKinematicsTool.accuracy = accuracy;

%% delete unused markers
xmlMarkers = IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask;
for m = 1: length (xmlMarkers)
    nameMarker = xmlMarkers(m).ATTRIBUTE.name;
    if  isempty(find(strcmp(nameMarker, usedMarkers), 1))
        xmlMarkers(m).apply = 'false';
    end
end
IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask= xmlMarkers;

%% write xml and save gait cycle events
cd(DirIKtrial)
root = 'OpenSimDocument';
Pref.StructItem = false;
xml_write(osimFiles.IKsetup, IK, root,Pref);

%% run IK
import org.opensim.modeling.*
dos(['ik -S ' osimFiles.IKsetup],'-echo')
