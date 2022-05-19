% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% Function to run joint contact analysis for a multiple trials
% Warning: this script is hardcoded for my folder setup!
% Inputs: 
% MuscleSTODir- directory of trial directories with muscle forces (OpenSim .sto format)
% subject- name of subject - use to hardcode some directories
% FootStrike- 'L' = left or 'R'= right - use for xml templates
% JCFid-consistent with MOToNMS,  - use to hardcode some directories
% fcut_coordinates- default is 8
% Outputs:
% JCFoutputDir-
% JCFtrialsOutputDir-
function [JCFoutputDir,JCFtrialsOutputDir] = runJointContactAnalysis(inputTrials, inputDir, JCFid, model_file, fcut_coordinates, JCFTemplateXml,EMG_OpenSim_side)
import org.opensim.modeling.*

%Definition of output folders
[SOoutputDir, SOtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, JCFid, 'SO');
[IDoutputDir, IDtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, JCFid, 'ID');
[IKoutputDir, IKtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, JCFid, 'IK');

[JCFoutputDir, JCFtrialsOutputDir] = outputFoldersDefinition(inputDir, inputTrials, JCFid, 'JCF');

%Definition of input files lists
[IKmotFullFileName, IKmotRelativePath] = inputFilesListGeneration2(IKoutputDir, inputTrials, '.mot');
[ExtLoadXmlFullFileName, ExtLoadXmlRelativePath] = inputFilesListGeneration2(IDoutputDir, inputTrials, 'external_loads.xml'); %hardcoded
[MuscleForceStoFullFileName, MuscleForceStoRelativePath] = inputFilesListGeneration2(SOoutputDir, inputTrials, 'SO_StaticOptimization_force.sto');
%[GRFmotFullFileName] = inputFilesListGeneration(inputDir, inputTrials, '.mot');
%to have also the relative path:
%[IKmotFullFileName, IKmotRelativePath] = inputFilesListGeneration(inputDir, inputTrials, '.mot');

%% Get the model
osimModel = Model(model_file);
osimModel.initSystem();

%%
nTrials= length(inputTrials);

for k=1:nTrials
        
    coordinates_file = IKmotRelativePath{k};
    coordinates_Fullfile = IKmotFullFileName{k};
    %GRFmot_file=GRFmotFullFileName{k};
    externalLoads_file=ExtLoadXmlRelativePath{k}; %hardcoded
    muscleForcesFullFileName=MuscleForceStoFullFileName{k};
    muscleForcesRelFileName=MuscleForceStoRelativePath{k};
    results_directory=JCFtrialsOutputDir{k};
    if exist(muscleForcesFullFileName,'file')&&exist(coordinates_Fullfile,'file')
        if exist(results_directory,'dir') ~= 7
            mkdir (results_directory);
        end
        runJCF(osimModel, coordinates_file, externalLoads_file, muscleForcesRelFileName, results_directory, fcut_coordinates, JCFTemplateXml,EMG_OpenSim_side)
        disp(['JCF: ' inputTrials{k}]);
    else
        disp(['file missing: ' MuscleForceStoFullFileName{k}])
    end
end