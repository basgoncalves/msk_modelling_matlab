function [KinematicsoutputDir, KinematicstrialsOutputDir]=runKinematicsAnalysis(inputDir,inputTrials, model_file, IKmotDir, KAid, KATemplateXml, varargin)
% Function to run kinematics analysis for multiple trials

%%

import org.opensim.modeling.*

%Definition of output folders
[KinematicsoutputDir, KinematicstrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, KAid, 'KA');

%Definition of input files lists
[IKmotFullFileName] = inputFilesListGeneration(IKmotDir, inputTrials, '.mot');


%%
nTrials= length(inputTrials);

for k=1:nTrials
    
    %Get the model
    osimModel = Model(model_file.model_full_path{k});
    osimModel.initSystem();
           
    results_directory=KinematicstrialsOutputDir{k};
           
    if exist(results_directory,'dir') ~= 7
        mkdir (results_directory);
    end
    
    coordinates_file=IKmotFullFileName{k};
    
    switch nargin 
           
        case 6  %until there will be probl setting the Muscle Analysis object with API
            runKinematics(osimModel, coordinates_file, results_directory, KATemplateXml)
            
        case 5  %it will be the optimal case when API problems will be solved
            runKinematics(osimModel, coordinates_file, results_directory)            
                     
        case 7
            runKinematics(osimModel, coordinates_file, results_directory, KATemplateXml, fcut_coordinates)
    end
    
end