function runRRA_DG(osimModel, coordinates_file, GRFmot_file, external_loads_file, rra_results_directory, XMLTemplate, setupFiles)
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


%%
import org.opensim.modeling.*

% Read in the XML set up template for RRA
RRA = xml_read(XMLTemplate);

% Get mot data to determine time range (might have to be grf data
motData = Storage(coordinates_file);
grfData = Storage(GRFmot_file);

% Get initial and intial time
initial_time    = motData.getFirstTime();
final_time      = motData.getLastTime();

%setup root and InverseKinematicsTool
root = 'OpenSimDocument';
% RRA.RRATool.defaults.CMC_Joint.active =['false ' 'false ' 'false '];
RRA.RRATool.results_directory  = rra_results_directory;
RRA.RRATool.model_file         = osimModel;
RRA.RRATool.initial_time       = initial_time;
RRA.RRATool.final_time         = final_time;

%% Residual reduction analysis
% Coordinates and external loads files 
RRA.RRATool.desired_kinematics_file   = coordinates_file;
RRA.RRATool.external_loads_file       = external_loads_file;
RRA.RRATool.lowpass_cutoff_frequency  = -1;
% Setup files needed to run RRA
RRATaskFile         = setupFiles{2};
RRAForceSetFile     = setupFiles{1};
% define other input files
RRA.RRATool.force_set_files = RRAForceSetFile;
RRA.RRATool.task_set_file   = RRATaskFile;

RRA.RRATool.output_model_file = ([osimModel(1:end-5) '_RRA.osim']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional settings, generally hard coded into the XMLTemplate
% % Set optimiser settings
% RRA.RRATool.solve_for_equilibrium_for_auxiliary_states    = false;
% RRA.RRATool.maximum_number_of_integrator_steps            = 20000;
% RRA.RRATool.maximum_integrator_step_size                  = 1;
% RRA.RRATool.minimum_integrator_step_size                  = 1e-008;
% RRA.RRATool.integrator_error_tolerance                    = 1e-005;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set up the output xml file
fileout = [rra_results_directory ('\Setup_RRA.xml')];

Pref.StructItem = false;

xml_write(fileout, RRA, root, Pref);

%CALL THE RRA TOOL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,log_mes]=dos(['rra -S  ', fileout],'-echo');

rraTool=RRATool(fileout);

command = ['rra -S' fileout];   % BG 
[~,log_mes]=dos(command);
%SAVE THE WORKSPACE AND PRINT A LOG FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen([rra_results_directory,'\Log\RRA.log'],'w+');
fprintf(fid,'%s\n', log_mes);
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BELOW: GAVINS CODE TO RUN FROM API - NOT WORKING BECAUSE OF LOCAL COMPUTER 
%% ISSUES SO USED ABOVE COMMAND LINE CODE
% % Make copy of generic RRA tool setup to edit
% rraTool=RRATool(XMLTemplate, 0);
% %rraTool=xml_read(XMLTemplate);
% 
% %Set the model
% rraTool.setModel(osimModel);
% rraTool.setModelFilename(osimModel.getDocumentFileName());
% modelName = char(osimModel.getName);
% 
% rraTool.setReplaceForceSet(true);
% rraTool.setResultsDir(rra_results_directory);
% rraTool.setOutputPrecision(16)
% 
% % Setup files needed to run RRA
% RRAForceSetFile     = setupFiles{1}; 
% RRATaskFile         = setupFiles{2};
% %RRAConstraintsFile  = setupFiles{3};
% 
% % Get mot data to determine time range (might have to be grf data
% motData = Storage(coordinates_file);
% grfData = Storage(GRFmot_file);
% 
% % Get initial and intial time
% initial_time    = motData.getFirstTime();
% final_time      = motData.getLastTime();
% 
% % Define times to perform analysis over 
% rraTool.setInitialTime(initial_time);
% rraTool.setFinalTime(final_time);
% 
% % Set optimiser settings
% rraTool.setSolveForEquilibrium(false)
% rraTool.setMaximumNumberOfSteps(20000)
% %analyzeTool.setMaxDT(1e-005)
% rraTool.setMaxDT(1)
% rraTool.setMinDT(1e-008)
% rraTool.setErrorTolerance(1e-005)
% 
% %% Residual reduction analysis
% % Coordinates and external loads files 
% rraTool.setDesiredKinematicsFileName(coordinates_file);
% rraTool.setExternalLoadsFileName(external_loads_file);
% 
% % Set actuators (force set) file 
% forceSet = ArrayStr();
% forceSet.append(RRAForceSetFile);
% rraTool.setForceSetFiles(forceSet);
% rraTool.setLowpassCutoffFrequency(-1); %the default value is -1.0, so no filtering
% 
% % define other input files
% rraTool.setTaskSetFileName(RRATaskFile);
% rraTool.setConstraintsFileName(RRAConstraintsFile);
% 
% %% Save the settings in the Setup folder
% setupFileDir=[rra_results_directory filesep 'Setup' filesep];
% 
% if exist(setupFileDir,'dir') ~= 7
%     mkdir (setupFileDir);
% end
% 
% % Define setup file name and output model name
% setupFile='RRA_setup.xml';
% rraTool.setOutputModelFileName([modelName(1:end-5) '_rraAdjusted.osim']);
% rraTool.print([setupFileDir setupFile ]);
% 
% %% Run
% rraTool.run()
% 
% %Save the log file in a Log folder for each trial
% logFolder=[rra_results_directory filesep 'Log' filesep ];
% if exist(logFolder,'dir') ~= 7
%     mkdir (logFolder);
% end
% movefile([setupFileDir 'out.log'],[logFolder 'out.log'])
% movefile([setupFileDir 'err.log'],[logFolder 'err.log'])
