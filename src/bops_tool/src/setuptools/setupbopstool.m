% code to setup the processing pipeline using OpenSim API as part of the
% MSKmodelling pipeline containing all the required tools and template files
%
% SetupMode: 0 = New project; 1 = continue current project; -1 = current
% project folder doesnt exist
% by Basilio Goncalves, basilio.goncalves7@gmail.com

function [bops_settings] = setupbopstool

fp = filesep;
[bops_settings,answer] = check_bops_setup;
og_bopsSetup = bops_settings;                                                                                       % use the og to compare with the updated at the end of the fucntion

setupDir    = fileparts(mfilename('fullpath'));
dataDir     = char(importdata([setupDir fp 'data_directory.dat']));

if isempty(answer); disp('user canceled setup bops'); return; end

create_copy_of_templates_on_project_folder(dataDir)

bops_settings = define_bops_directories(bops_settings);

if ~isequal(og_bopsSetup,bops_settings)                                                                             % save new xml if original bops is different from the new one
    xml_write(bops_settings.directories.setupbopsXML,bops_settings,'bops',bops_settings.xmlPref);
    % winopen(bops_settings.setupbopsXML)
end

%% ------------------------------------------------  FUNCTIONS ---------------------------------------------------%
function [bops,answer] = check_bops_setup
% if data folder doesnt exist ask user to select new one
setupDir    = [fileparts(mfilename('fullpath')) fp 'data_directory.dat'];
bopsDir     = fileparts(fileparts(setupDir));
dataDir     = char(importdata(setupDir));

if isempty(dataDir) || isequal(dataDir,char(0))                                                                     % if data dir does not exist
    answer = 'Select new project folder';

elseif ~exist([dataDir fp 'bopsSettings.xml'])   
    prompt = [dataDir ' does not contain BopsSettings.xml. Do you want to continue with this project folder?'];     % if bopsSettings does not exist in current project
    answer = questdlg(prompt,'choice','Select new project folder','Continue this project folder','Continue');

else
    prompt = ['Do you want to continue with this project folder? ' dataDir];                                        % check if you want to continue with current project or select new one
    answer = questdlg(prompt,'choice','Select new project folder',...
        'Continue this project with new settings','Continue this project folder','Continue');

end

if isequal(answer,'Select new project folder')                                                                      % select a new folder if needed
    prompt = 'Select your data folder';
    dataDir = uigetdir(bopsDir,prompt);
    writematrix(dataDir,setupDir);
end


setupfileDir = [dataDir fp 'bopsSettings.xml'];
try xml_read(setupfileDir);                                                                                         % try to load "setup.xml"
catch; copy_from_templates('bopsSettings.xml');
end

bops = load_setup_bops;                                                                                             % load bops settings
cd(bops.directories.bops)
masterDir = fileparts(fileparts(bops.directories.bops));
bops.directories.masterProcessing = masterDir;
addpath(genpath(masterDir))                                                                                         % add to path all the folders and subfolders in "MasterDir"

try
    steps = fields(bops.ProcessingSteps);
catch
    og_bops = xml_read([bops.directories.bops fp 'Templates\bopsSettings.xml']);
    bops.ProcessingSteps = og_bops.ProcessingSteps;
    steps = fields(bops.ProcessingSteps);
end

values = logical(cell2mat(struct2cell(bops.ProcessingSteps)));

string_processing = '';
for i = 1:length(steps)
    string_processing = sprintf('%s \n %s - %s ',string_processing,steps{i},num2str(values(i)));
end

if  isequal(answer,'Select new project folder') || isequal(answer,'Continue this project with new settings')
    [OutValues,~] = BopsCheckbox(steps,values,'Which steps of the pipeline do you want to run?');             	    % Setup analysis
    for i = 1:length(steps)
        bops.ProcessingSteps.(steps{i}) = OutValues(i);
    end
end
%----------------------------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------------------------%
function create_copy_of_templates_on_project_folder(dataDir)

if ~isfile([dataDir fp 'bopsSettings.xml'])                                                                         % check if bopsSettings.xml exist
    copy_from_templates('bopsSettings.xml')
end

if ~isfile([dataDir fp 'subjectinfo.csv'])                                                                          % check if subjectinfo.csv exist
    copy_from_templates('subjectinfo.csv');
end

if ~isfile([dataDir fp 'events.csv'])                                                                               % check if events.csv exist
    copy_from_templates('events.csv');
end

if ~isfile([dataDir fp 'Models.csv'])                                                                               % check if Models.csv exist
    copy_from_templates('Models.csv');
end

if ~isfolder([dataDir fp 'templates'])                                                                              % check if templates folder exist
    copy_from_templates('1-ProjectTemplate','templates');
end
%----------------------------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------------------------%
function copy_from_templates(filename,fileout)

if nargin < 2
    fileout = filename;
end
setupDir    = fileparts(mfilename('fullpath'));
dataDir     = char(importdata([setupDir fp 'data_directory.dat']));
templateDir = [fileparts(fileparts(setupDir)) fp 'Templates'];

source = [templateDir fp filename];
destin = [dataDir fp fileout];
copyfile(source,destin)
%----------------------------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------------------------%
function bops_settings = define_bops_directories(bops_settings)

Dir = bops_settings.directories;
Dir.osimMatlab          = ['C:' fp 'OpenSim ' num2str(bops_settings.osimVersion) fp 'Resources\Code\Matlab\Utilities'];
Dir.mainData            = fileparts(Dir.setupbopsXML);
Dir.subjectInfoCSV      = [Dir.mainData fp 'subjectinfo.csv'];
Dir.eventsCSV           = [Dir.mainData  fp 'events.csv'];
Dir.modelsCSV           = [Dir.mainData  fp 'Models.csv'];
Dir.CEINMSexe           = [DirUp(Dir.bops,2) fp 'src\Ceinms\CEINMS_2'];                                             % add CEINMS 2 directory
Dir.InputData           = [Dir.mainData fp 'InputData'];
Dir.ElaboratedData      = [Dir.mainData fp 'ElaboratedData'];

Dir.Results = [Dir.mainData fp 'Results'];

templateDir                  = [Dir.mainData fp 'templates'];
Dir.templatesDir             = templateDir;
Dir.templates                = struct;                                                                              % Directory with template setup files for this project
Dir.templates.acquisitionXML = [templateDir fp 'acquisition.xml'];                                                  % MOtoNMS (see https://scfbm.biomedcentral.com/articles/10.1186/s13029-015-0044-4)
Dir.templates.elaborationXML = [templateDir fp 'elaboration.xml'];

Dir.templates.Model     = [templateDir fp bops_settings.dataStructure.OSIMModelName '.osim'];                       %OpenSim
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

bops_settings.directories = Dir;
bops_settings = ConvertLogicToString(bops_settings);
%----------------------------------------------------------------------------------------------------------------%
