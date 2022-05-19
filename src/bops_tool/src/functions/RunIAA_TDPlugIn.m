%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Setup and run induced acceleration analysis 
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%   
%INPUT
%-------------------------------------------------------------------------
%OUTPUT
%

function results_directory = RunIAA_TDPlugIn(DirIAA,model_file,coordinates_file,ActuatorXML,GRFxml,kinetics_file,force_file,TemplateSetupIAA)

    
fp = filesep;
root = 'OpenSimDocument'; % setting for saving XML files
Pref.StructItem = false;

[~,trialName] = fileparts(DirIAA);
cd(DirIAA)
results_directory = relativepath([DirIAA fp 'IndAccPI_Results'],DirIAA);
DirElaborated = DirUp(DirIAA,2);
DirC3D = strrep(DirElaborated, 'ElaboratedData', 'InputData');
TestedLeg = findLeg(DirElaborated,trialName);

%load acq file 
AcqXML = xml_read([DirC3D fp 'acquisition.xml']);

%load SetupIAA
SetupXML = xml_read(TemplateSetupIAA);

%Set the model
SetupXML.AnalyzeTool.ATTRIBUTE.name = trialName;
SetupXML.AnalyzeTool.model_file =relativepath(model_file,DirIAA) ;
SetupXML.AnalyzeTool.output_precision = 20;

% results directory 
SetupXML.AnalyzeTool.results_directory = results_directory;

% coordinates 
SetupXML.AnalyzeTool.coordinates_file = relativepath(coordinates_file,DirIAA);

% external loads files 
% XML =  xml_read(GRFxml);
% XML.ExternalLoads.external_loads_model_kinematics_file = relativepath(coordinates_file,DirIAA);
% XML.ExternalLoads.datafile = relativepath(kinetics_file,DirIAA);
% xml_write(GRFxml, XML, root,Pref);
SetupXML.AnalyzeTool.external_loads_file = relativepath(GRFxml,DirIAA);

%actuators
SetupXML.AnalyzeTool.force_set_files = relativepath(ActuatorXML,DirIAA);

%force file
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.forces_file = relativepath(force_file,DirIAA);
[kinetics_file,~,FT] = deleteForceIAA(kinetics_file,AcqXML,GRFxml,kinetics_file);
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.kinetics_file = relativepath(kinetics_file,DirIAA);

% weights IndAcc
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.weights = '1000 100 10';

% time window (based on the time in SO file)
[TimeWindow, ~,FootContact] = TimeWindow_FatFAIS(DirC3D,trialName,TestedLeg);
SetupXML.AnalyzeTool.initial_time = FootContact.time;
SetupXML.AnalyzeTool.final_time = FT; %FT = final time with some force measured;


%% write xml 
IAAxmlPath = [DirIAA fp 'setup_IAA.xml'];
xml_write(IAAxmlPath, SetupXML, root,Pref);

%% Run IAA
% 
import org.opensim.modeling.*
cd(fileparts(IAAxmlPath))

% % dos(['analyze -S ' SetupIAA])
% % T.Dorn's plug in
% force_file = CombineSOandCEINMS(CEINMS_trialDir,SOdir,0);
dos(['analyze -L IndAccPI -S ' IAAxmlPath])
% 
movefile([DirIAA '\out.log'],[results_directory '\out.log'])
movefile([DirIAA '\err.log'],[results_directory '\err.log'])

