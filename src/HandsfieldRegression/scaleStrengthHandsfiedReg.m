%% scaleStrengthHandsfiedReg
% Update muscle volumes and then use them to calculate maximal isometric forces based
% Handsfield et al. 2014

% Regression equation coefficients are provided accompanying excel sheet
% handsfieldRegressionCoefficients.xlsx
% Please change excel sheet file path according to where the file is saved

% NOTE:
%   1.  Maximal isometric forces are not scaled for muscles
%       which were not reported by Handsfield et al. 2014
%   2.  This script works only for scaling muscle forces of GAIT2392 model

% INPUTS:
%       modelPath: path of scaled model for adjustments to be made
%       mass: participant mass in kg (e.g., 70)
%       height: participant height in metres (e.g., 1.75)

% Daniel Devaprakash (Griffith University) (2020)
% Adapted by Tamara Grant (2021)
% Adapted by Basilio Goncalves (2021)

function scaleStrengthHandsfiedReg(ModelIn,ModelOut,mass,height,sex)

import org.opensim.modeling.*
if nargin < 5
   sex = 'M';
end
if ~exist(ModelOut)
    % Create model object
    model = Model(ModelIn);
    % Create reference for the maintained model state
    model.initSystem;
    
    %% Muscles in model
    muscles = model.getMuscles();
    nMuscles = muscles.getSize();
    
    % read b1 and b2 (regression equation coefficients based on Handsfield et al. 2014)
    % change path accordingly
    inF = "handsfieldRegressionCoefficients.xlsx";
    d = xlsread(inF);
    muscleInfo = struct();
    
    % Create a structure to store required information
    for ii = 0:nMuscles-1
        muscleInfo(ii+1).muscleNames = char(muscles.get(ii).getName());
        muscleInfo(ii+1).muscleOptFiberLength = muscles.get(ii).getOptimalFiberLength()*100;
        %   Here specific tension of the muscle is taken as 55; Thomas O' Brien 2010
        if contains(sex,'M')
            muscleInfo(ii+1).specificTension = 55;
        else
            muscleInfo(ii+1).specificTension = 57;
        end
        muscleInfo(ii+1).muscleForce = muscles.get(ii).getMaxIsometricForce();
        muscleInfo(ii+1).presentVolume = (muscleInfo(ii+1).muscleForce * muscleInfo(ii+1).muscleOptFiberLength)/muscleInfo(ii+1).specificTension;
        muscleInfo(ii+1).b1 = d(ii+1,1);
        muscleInfo(ii+1).b2 = d(ii+1,2);
    end
    
    % Calculate total lower limb muscle volume
    totalVolume = (47*mass*height) + 1285;
    
    % Recalculate volume for specific muscles
    [muscleInfo] = recalculateMuscleVolumes_RajModel(nMuscles, muscleInfo, totalVolume);
    
    for ii = 0:nMuscles-1
        muscleInfo(ii+1).updatedMuscleForce = (muscleInfo(ii+1).specificTension * muscleInfo(ii+1).updatedVolume)/muscleInfo(ii+1).muscleOptFiberLength;
    end
    muscles.get(muscleInfo(ii+1).muscleNames).setMaxIsometricForce(muscleInfo(ii+1).updatedMuscleForce);
    % Write the model to a new file
    model.print(ModelOut)
end
disp(['The new model has been saved as ' ModelOut]);



