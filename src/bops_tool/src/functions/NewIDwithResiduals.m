% see also findLine
%   Residuals = rms of the moments and forces
%   Logic = run ID (Default = 1), Don't run ID (~= 1)

function [Residuals,MassTorso,COMTorso,IDdata,Labels,IKdata,MassAdj] = ...
    NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic)

fp = filesep;

% load setup id xml
setupXML = xml_read(IDSetupXML);

% osim model directory
setupXML.InverseDynamicsTool.model_file = model_file;

% kinematics
setupXML.InverseDynamicsTool.coordinates_file = KinematicsDir;
        
% output inverse dynamics
outputfile = ['inverse_dynamics' sufix '.sto'];
setupXML.InverseDynamicsTool.output_gen_force_file = outputfile;
DirOutID = [fileparts(fileparts(IDSetupXML)) fp outputfile];

% write xml
IDxmlPath = strrep(IDSetupXML, '.xml', [sufix '.xml']);
root = 'OpenSimDocument';
Pref.StructItem = false;
xml_write(IDxmlPath, setupXML, root,Pref);

% run ID
if ~exist('Logic','var') || Logic == 1
    import org.opensim.modeling.*
    cd(fileparts(IDxmlPath))     
    [~,~] = dos(['id -S ' IDxmlPath],'-echo');
end

% import residuals
cd(fileparts(DirOutID))
id = importdata (DirOutID);
Residuals = rms(id.data(:,2:7));
[IDdata,Labels] = findData(id.data,id.colheaders,moments,2);
del = find(contains(Labels,'beta'));
IDdata (:,del) =[];
Labels(:,del) = [];


% % import IK
ik = importdata (KinematicsDir);
[IKdata,Labels] = findData(ik.data,ik.colheaders,moments,2);
% delete beta columns
del = find(contains(Labels,'beta'));
IKdata (:,del) =[];
Labels(:,del) = [];

Model_1 =  importdata(model_file);
[m,ln] = findLine (Model_1,'<Body name="torso">',[0:2]);

MassTorso = str2double(m{2}{1}(12:end-7));
com = str2double(m{3}{2});
com (end+1) = str2double(m{3}{3});
com (end+1) = str2double(m{3}{4}(1:end-14));
COMTorso = com; 

% find the mass adjustments
[DirIK,trialName] =fileparts(fileparts(KinematicsDir));
DirRRA = strrep(fileparts(DirIK),'inverseKinematics','residualReductionAnalysis');
RRAlog = importdata([DirRRA fp 'RRA' fp trialName fp 'Log' fp 'out.log'],' ', 100000);
[m,ln] = findLine(RRAlog,'Total mass change',0);
MassAdj = str2double(m{end}{end});