function [RRAsoutputDir, RRAtrialsOutputDir]=runResidualReductionAnalysis(inputDir,inputTrials, model_file, IKmotDir, IDresultDir, RRAid, RRATemplateXml, setupFiles, varargin)
% Function to run kinematics analysis for multiple trials

%%

import org.opensim.modeling.*

%Definition of output folders
[RRAsoutputDir, RRAtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, RRAid, 'RRA');

%Definition of input files lists
[IKmotFullFileName] = inputFilesListGeneration(IKmotDir, inputTrials, '.mot');
[GRFmotFullFileName] = inputFilesListGeneration(inputDir, inputTrials, '.mot');
[ExtLoadXmlFullFileName] = inputFilesListGeneration(IDresultDir, inputTrials, '.xml');

%% Loop through trials and run RRA
nTrials= length(inputTrials);

for k=1:nTrials
    
    %Get the model
    osimModel = Model(model_file.model_full_path{1});
    osimModel.initSystem();
           
    results_directory=RRAtrialsOutputDir{k};
           
    if exist(results_directory,'dir') ~= 7
        mkdir (results_directory);
    end
    
    coordinates_file=IKmotFullFileName{k};
    GRFmot_file=GRFmotFullFileName{k};
    external_loads_file=ExtLoadXmlFullFileName{k};
    
    switch nargin 
           
        case 8  %until there will be probl setting the Muscle Analysis object with API
            runRRA_BGBOPS(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, RRATemplateXml, setupFiles)  
                     
        case 9
            fcut_coordinates = varargin{1};
            runRRA(osimModel, coordinates_file, GRFmot_file, external_loads_file, results_directory, RRATemplateXml, setupFiles, fcut_coordinates)
    end
    
    clear  osimModel coordinates_file results_directory
    
end