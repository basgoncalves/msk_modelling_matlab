
%   Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
function [RRAsoutputDir, RRAtrialsOutputDir]=...
    runResidualReductionAnalysis_BG(inputDir,inputTrials, model_file, IKmotDir, IDresultDir, setupFiles, RRATemplateXml, Logic, varargin)

% Function to run kinematics analysis for multiple trials

%%
fp = filesep;
import org.opensim.modeling.*

%% Definition of output folders
[RRAsoutputDir, RRAtrialsOutputDir] = outputFoldersDefinition_BG(inputDir, inputTrials, '', 'RRA');

% create a copy of the Kinematics_q.sto into Kinematics_q.mot for all files
if length(varargin) >0
    for k = 1: length(RRAtrialsOutputDir)
        if exist([RRAtrialsOutputDir{k} fp varargin{1}])
            files = dir([RRAtrialsOutputDir{k} fp varargin{1} fp '*.sto']);
            IKfile = files(contains({files.name},'Kinematics_q.sto'));
            if ~isempty(IKfile)
                newName = strrep(IKfile.name,'.sto','.mot');
                copyfile([IKfile.folder fp IKfile.name],[IKmotDir fp inputTrials{k} fp newName])
            end
        end
    end
else
    % if oldRRA does not exist, delete the variable in the
    % inversekinematics folder not to be used as input
    for k = 1: length(RRAtrialsOutputDir)  
        cd([IKmotDir fp inputTrials{k}])
        files = dir();
        RRAfile = files(contains({files.name},'Kinematics_q.mot'));
        delete ([IKmotDir fp inputTrials{k} fp RRAfile.name])   
    end  
end

if ~exist('Logic') 
    Logic = 1;
end

%Definition of input files lists
[IKmotFullFileName] = inputFilesListGeneration_BG(IKmotDir, inputTrials, '.mot');
[GRFmotFullFileName] = inputFilesListGeneration_BG(inputDir, inputTrials, '.mot');
[ExtLoadXmlFullFileName] = inputFilesListGeneration_BG(IDresultDir, inputTrials, '.xml');

DirC3D = strrep(fileparts(inputDir),'ElaboratedData', 'InputData');
OrganiseFAI

%% edit task and Actuator xml %%

% adjustTaskXML(TaskFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
adjustTaskXML(TemplateTasksRRA,100,100,100,1,1,1,1,100)

% adjustActuatorXML(ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
adjustActuatorXML(TemplateActuatorsRRA,1000,1000,1000,1000,500,500,500,1)

%% Loop through trials and run RRA
nTrials= length(inputTrials);

for k=1:nTrials

%     names = dir(RRAtrialsOutputDir{k});
%     names = names([names.isdir]);   % get the names that are folder only
%     n = sprintf('%.f',sum(contains({names.name},'RRA'))+1);
    results_directory = [RRAtrialsOutputDir{k} fp 'RRA'];
    
    if exist(results_directory,'dir') ~= 7
        mkdir (results_directory);
    end
    

    
    trialName = inputTrials{k};
    coordinates_file=IKmotFullFileName{k};
    GRFmot_file=GRFmotFullFileName{k};
    copyfile(GRFmot_file,results_directory)
    external_loads_file=ExtLoadXmlFullFileName{k};
    copyfile(external_loads_file,[results_directory fp 'grf.xml'])
    external_loads_file = [results_directory fp 'grf.xml'];
    
    
    % Set as variables to pass out of function
    setupDir = setupFiles;
    for kk = 1:length(setupDir)
        [~,fname,ext] = fileparts(setupDir{kk});
        copyfile(setupDir{kk},results_directory); 
        setupDir{kk} = [results_directory fp fname ext];
    end
 
    if Logic ~= 1 && exist([results_directory fp trialName '_Kinematics_q.sto'])
        continue 
    end
    
    switch nargin
        
        case 8  %until there will be probl setting the Muscle Analysis object with API
            runRRA_BG2(model_file, coordinates_file, GRFmot_file, external_loads_file, results_directory, RRATemplateXml, setupDir);
            %             end
        case 9
            runRRA_BG2(model_file, coordinates_file, GRFmot_file, external_loads_file, results_directory, RRATemplateXml, setupDir);
            
        case 10
            fcut_coordinates = varargin{2};
            runRRA_BG(model_file, coordinates_file, GRFmot_file, external_loads_file, results_directory, RRATemplateXml, setupDir, fcut_coordinates);
    end
    

end