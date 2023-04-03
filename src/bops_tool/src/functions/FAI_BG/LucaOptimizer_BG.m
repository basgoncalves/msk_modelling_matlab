%-------------------------------------------------------------------------%
% Copyright (c) 2015 Modenese L., Ceseracciu, E., Reggiani M., Lloyd, D.G.%
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author: Luca Modenese, August 2014                                   %
%                            revised for paper May 2015                   %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
%
% Script optimizing muscle parameters for the Example 1 described in
% Modenese L, Ceseracciu E, Reggiani M, Lloyd DG (2015). "Estimation of
% musculotendon parameters for scaled and subject specific musculoskeletal
% models using an optimization technique" Journal of Biomechanics (submitted)
% The script performes a sensitivity study from which the Figures of the
% papers are then produced.
% The script:
% 1) optimizes muscle parameters varying the number of points used in the
%    optimization from 5 to 15 per degree of freedom. Optimized models and
%    optimization log are saved in the folder "Example1>OptimModels"
% 2) evaluates the results of the optimization in terms of muscle
%   parameters variation and muscle mapping metrics (and saves structures
%   summarizing the results in the folder "Example1>Results"

% adapted by Basilio Goncalves (2021)
% N_eval = number evaluation iteration (default = 10)

function LucaOptimizer_BG (osimModel_ref_filepath,osimModel_targ_filepath,N_eval)

% importing OpenSim libraries
import org.opensim.modeling.*
% importing muscle optimizer's functions
addpath(genpath('./Functions_MusOptTool'))
fp = filesep;

%=========== INITIALIZING FOLDERS AND FILES =============
% folders used by the script

DirElaborated           = fileparts(osimModel_targ_filepath);
OptimizedModel_folder   = DirElaborated;    % folder for storing optimized model
Results_folder          = [DirElaborated fp 'Results_LO'];
log_folder              = [DirElaborated fp 'Results_LO'];

checkFolder(OptimizedModel_folder);% creates results folder is not existing
checkFolder(Results_folder);

% reference model for calculating results metrics
osimModel_ref = Model(osimModel_ref_filepath);


%====== MUSCLE OPTIMIZER ========
% optimizing target model based on reference model fro N_eval points per
% degree of freedom
if ~exist(N_eval)
    N_eval = 10;
end

[osimModel_opt, SimsInfo{N_eval}] = optimMuscleParams(osimModel_ref_filepath, osimModel_targ_filepath, N_eval, log_folder);

%====== PRINTING OPT MODEL =======
% setting the output folder
if strcmp(OptimizedModel_folder,'') || isempty(OptimizedModel_folder)
    OptimizedModel_folder = targModel_folder;
end
% printing the optimized model
osimModel_opt.print(fullfile(OptimizedModel_folder, char(osimModel_opt.getName())));

% %====== SAVING RESULTS ===========
% % variation in muscle parameters
% Results_MusVarMetrics = assessMuscleParamVar(osimModel_ref, osimModel_opt, N_eval);
% % assess muscle mapping (RMSE, max error, etc) at n_Metrics points
% % between reference and optimized model
% n_Metrics = 10;
% Results_MusMapMetrics = assessMuscleMapping(osimModel_ref,  osimModel_opt,N_eval, n_Metrics);
% % move results mat file to result folder
% movefile('./*.mat',Results_folder)
% 
% % save simulations infos
% save([Results_folder,'./SimsInfo'],'SimsInfo');

