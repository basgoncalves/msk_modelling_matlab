% code to setup the processing pipeline using OpenSim API
% for this to work the DataProcessing_Master package must be dowloaded
% which contains all the required tools and template files
% please check
%
% MasterDir = diretory for the "DataProcessing_master" pipeline
%
% by Basilio Goncalves, basilio.goncalves7@gmail.com

function [bops] = setupbopstool(UseCurrentSessitngs)

setupDir    = fileparts(mfilename('fullpath'));
dataDir     = char(importdata([setupDir fp 'data_directory.dat']));
templateDir = [fileparts(fileparts(setupDir)) fp 'Templates'];


if nargin < 1
   UseCurrentSessitngs = 0; 
end

if isfolder(dataDir) && UseCurrentSessitngs == 0
    answer = questdlg(sprintf('do you want to use data directory: \n %s',dataDir));
else
    answer = 'Yes';
end

if ~isfolder(dataDir) || isequal(answer,'No')                                                                       % check data folder
    dataDir = uigetdir(fileparts(dataDir)); 
    writematrix(dataDir,[setupDir fp 'data_directory.dat'])
end

if ~isfile([dataDir fp 'bopsSettings.xml'])                                                                         % check if bopsSettings.xml exist
    source = [templateDir fp 'bopsSettings.xml'];
    destin = [dataDir fp 'bopsSettings.xml'];
    copyfile(source,destin)
end

if ~isfile([dataDir fp 'subjectinfo.csv'])                                                                          % check if subjectinfo.csv exist
    source = [templateDir fp 'subjectinfo.csv'];
    destin = [dataDir fp 'subjectinfo.csv'];
    copyfile(source,destin)
end

if ~isfile([dataDir fp 'events.csv'])                                                                               % check if events.csv exist
    source = [templateDir fp 'events.csv'];
    destin = [dataDir fp 'events.csv'];
    copyfile(source,destin)
end

if ~isfile([dataDir fp 'Models.csv'])                                                                               % check if Models.csv exist
    source = [templateDir fp 'Models.csv'];
    destin = [dataDir fp 'Models.csv'];
    copyfile(source,destin)
end

if ~isfolder([dataDir fp 'templates'])                                                                              % check if templates folder exist
    source = [templateDir fp '1-ProjectTemplate'];
    destin = [dataDir fp 'templates'];
    copyfile(source,destin)
end

bops = load_setup_bops;
og_bopsSetup = bops;                                                                                                % use the og to compare with the updated at the end of the fucntion
cd(bops.directories.bops)    

masterDir = fileparts(fileparts(bops.directories.bops));
bops.directories.masterProcessing = masterDir;

addpath(genpath(masterDir))                                                                                         % add to path all the folders and subfolders in "MasterDir"

if any(structfun(@isempty, bops.dataStructure))                                                                     % check if any project entry is empty
    winopen(setupfileDir);
    msgbox('please fill the empty spaces in the bopsSetup.xml ')
    error('please fill the empty spaces in the bopsSetup.xml ')
end

Dir = bops.directories;
Dir.subjectInfoCSV      = [fileparts(Dir.setupbopsXML) fp 'subjectinfo.csv'];
Dir.eventsCSV           = [fileparts(Dir.setupbopsXML) fp 'events.csv'];
Dir.modelsCSV           = [fileparts(Dir.setupbopsXML) fp 'Models.csv'];
Dir.CEINMSexe           = [masterDir fp 'src\Ceinms\CEINMS_2'];                                                     % add CEINMS 2 directory
Dir.InputData           = [Dir.mainData fp 'InputData'];
Dir.ElaboratedData      = [Dir.mainData fp 'ElaboratedData'];

Dir.Results = [Dir.mainData fp 'Results'];

templateDir                  = [dataDir fp 'templates'];
Dir.templatesDir             = templateDir;   
Dir.templates                = struct;                                                                              % Directory with template setup files for this project
Dir.templates.acquisitionXML = [templateDir fp 'acquisition.xml'];                                                  % MOtoNMS (see https://scfbm.biomedcentral.com/articles/10.1186/s13029-015-0044-4)
Dir.templates.elaborationXML = [templateDir fp 'elaboration.xml'];

Dir.templates.Model     = [templateDir fp bops.dataStructure.OSIMModelName '.osim'];                                %OpenSim
Dir.templates.ScaleTool = [templateDir fp 'ScaleTool.xml'];
Dir.templates.Static    = [templateDir fp 'static.xml'];

Dir.templates.IKSetup = [templateDir fp 'IK_setup.xml'];                                                            % Inverse kinematics
    
Dir.templates.IDSetup = [templateDir fp 'ID_setup.xml'];                                                            % Inverse dynamics
Dir.templates.GRF = [templateDir fp 'ID_externalForces_RL.xml'];

Dir.templates.RRASetup                      = [templateDir fp 'RRA_setup.xml'];                                     % residual reduction analysis
Dir.templates.RRAActuators                  = [templateDir fp 'RRA_actuators.xml'];   
Dir.templates.RRATaks                       = [templateDir fp 'RRA_tasks.xml'];
Dir.templates.RRASetup_actuation_analyze    = [templateDir fp 'RRA_setup_actuation_analyze.xml'];

Dir.templates.MASetup = [templateDir fp 'MA_setup.xml'];                                                            % muscle analysis

Dir.templates.SOSetup       = [templateDir fp 'SO_setup.xml'];                                                      % static optimization 
Dir.templates.SOActuators   = [templateDir fp 'SO_actuators.xml'];

Dir.templates.CMCSetup      = [templateDir fp 'CMC_setup.xml'];                                                     % computed muscle control
Dir.templates.CMCControls   = [templateDir fp 'CMC_ControlConstraints.xml'];
Dir.templates.CMCtasks      = [templateDir fp 'CMC_tasks.xml'];
Dir.templates.CMCactuators  = [templateDir fp 'CMC_actuators.xml'];

Dir.templates.CEINMSuncalibratedmodel = [templateDir fp 'CEINMS_uncalibrated_RL.xml'];                              % CEINMS templates
Dir.templates.CEINMScalibrationCfg = [templateDir fp 'CEINMS_calibrationCfg_RL.xml'];                                       
Dir.templates.CEINMScalibrationCfg_HJCF = [templateDir fp 'CEINMS_calibrationCfg_RL_HJCF.xml'];                                  
Dir.templates.CEINMSexcitationGenerator = [templateDir fp 'CEINMS_excitationGenerator.xml'];
Dir.templates.CEINMSexecutionSetup = [templateDir fp 'CEINMS_executionSetup.xml'];                                               
Dir.templates.CEINMSexecutionCfg = [templateDir fp 'CEINMS_executionCfg.xml'];                                                   
Dir.templates.CEINMScontactmodel = [templateDir fp 'CEINMS_contactOpenSimModel.xml'];                                            

Dir.templates.JRAsetup = [templateDir fp 'JCF_setup.xml'];                                                          % joint reaction analysis                                                     

Dir.templates.IAASetup = [templateDir fp 'IAA_setup.xml'];                                                          % induced acceleration analysis
                                                                                                       
bops.directories = Dir;
bops = ConvertLogicToString(bops);
if ~isequal(og_bopsSetup,bops)                                                                                      % save new xml if original bops is different from the new one
    xml_write(Dir.setupbopsXML,bops,'bops',bops.xmlPref);
end
% winopen(Dir.setupbopsXML)



