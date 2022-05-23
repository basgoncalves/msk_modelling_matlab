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

function results_directory = InducedAccelerationAnalysis...
(DirIAA, model_file,IKfile,GRFxmlDir,TemplateSetupIAA,BodyNames)

    
fp = filesep;
[~,TrialName] = fileparts(fileparts(fileparts(IKfile)));
DirMA = [fileparts(DirIAA) fp 'muscleAnalysis'];
DirRRA = fileparts(GRFxmlDir);
DirCEINMS_exe = [fileparts(DirIAA) fp 'ceinms' fp 'execution'];
DirStOpt = [fileparts(DirIAA) fp 'StaticOpt'];
ForceFile = [DirStOpt fp TrialName fp '_StaticOptimization_force.sto'];
ActivationStOpt = [fileparts(DirIAA) fp 'StaticOpt' fp TrialName fp '_StaticOptimization_activation.sto'];
XML_ma = xml_read([DirMA fp TrialName fp 'Setup' fp 'setup_MA.xml']);
XML_grf = xml_read(GRFxmlDir);
load([fileparts(TemplateSetupIAA) fp 'CMC_states.mat']);

results_directory = [DirIAA fp TrialName];
mkdir(results_directory)
    
% load tempalte for set up IAA
SetupXML = xml_read(TemplateSetupIAA);

% edit the XML to match the current trial
SetupXML.AnalyzeTool.ATTRIBUTE.name = TrialName;

[States,colheaders] = createStatesIAA (DirRRA, DirMA, DirStOpt, DirCEINMS_exe, TrialName);

StatesDir =[DirIAA fp TrialName fp 'states.sto'];
write_sto_file_IAA(States, StatesDir,colheaders,CMC_states)
SetupXML.AnalyzeTool.states_file = StatesDir;


% GRF xml
copyfile(GRFxmlDir,[results_directory fp 'grf.xml']);
SetupXML.AnalyzeTool.external_loads_file = [results_directory fp 'grf.xml'];
SetupXML.AnalyzeTool.external_loads_model_kinematics_file = IKfile;

%Kinematics file 
SetupXML.AnalyzeTool.coordinates_file = IKfile;

% controls XML (same as used for CMC and RRA)
% copyfile([fileparts(GRFxml) fp TrialName '_controls.xml'],[results_directory fp 'Control.xml'])
% SetupXML.AnalyzeTool.ControllerSet.objects.ControlSetController.controls_file = [results_directory fp 'Control.xml'];

% actuators XML
SetupXML.AnalyzeTool.force_set_files = [fileparts(GRFxmlDir) fp 'RRA_Actuators_FAI.xml'];

% results directory 
SetupXML.AnalyzeTool.results_directory = results_directory;

% time for analysis 
SetupXML.AnalyzeTool.initial_time = XML_ma.AnalyzeTool.initial_time;
SetupXML.AnalyzeTool.final_time = XML_ma.AnalyzeTool.final_time;

% SetupXML.AnalyzeTool.AnalysisSet.objects.InducedAccelerations.start_time = XML_ma.AnalyzeTool.initial_time;
% SetupXML.AnalyzeTool.AnalysisSet.objects.InducedAccelerations.end_time = XML_ma.AnalyzeTool.final_time;

%model file 
SetupXML.AnalyzeTool.model_file = model_file;

%Body names
% SetupXML.AnalyzeTool.AnalysisSet.objects.InducedAccelerations.body_names = BodyNames;

% Dorn Plug in settings
% [MedialAnkle_R LateralAnkle_R LateralToes_R MedialToes_R CentralToes_R MedialAnkle_L LateralAnkle_L LateralToes_L MedialToes_L CentralToes_L]>
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.kinetics_file = XML_grf.ExternalLoads.datafile;
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.forces_file = ForceFile;
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.weights = [1000 100 1];
SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.footpoint_markers = 'RMMAL RLMAL RMT1 RMT5 RMT2 LMMAL LLMAL LMT1 LMT5 LMT2';

%% write xml 
root = 'OpenSimDocument';
fileout = ['setup_IAA.xml'];
IAAxmlPath = [results_directory fp fileout];
Pref.StructItem = false;
xml_write(IAAxmlPath, SetupXML, root,Pref);


%% Run IAA

import org.opensim.modeling.*
cd(results_directory)
SetupIAA = [results_directory fp 'Setup_IAA.xml'];

dos(['analyze -S ' SetupIAA])
% T.Dorn's plug in
dos(['analyze -L IndAccPI -S ' SetupIAA])



