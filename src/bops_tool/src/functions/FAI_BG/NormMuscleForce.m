%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Load results from "OpenSimPipeline_FatFAI" and time normalise data
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   importdata
%   findData
%   TimeNorm
%
%INPUT
%   CEINMSmodel = [char] directory of the CEINMS calibrated model for one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\007\pre\ceinms\calibration\calibrated\calibratedSubject.xml' 
%   FieldsOfInterest = [N,1]cell vector with the names of the fields to be
%   extracted from Data
%   MatchWholeWord = 1 for "yes" (default) or other for "no"; 



function NormForces = NormMuscleForce(CEINMSmodel,muscleForces,Labels)

fp = filesep;
NormForces =[];
% load model to normalise the muscle forces
Model = xml_read (CEINMSmodel);

for kk = 1:length(Labels)
    idx = find(contains({Model.mtuSet.mtu.name},Labels{kk}));
    MaxOGForce = Model.mtuSet.mtu(idx).maxIsometricForce;
    StrFactor = Model.mtuSet.mtu(idx).strengthCoefficient;
    
    MaxIsomForce = MaxOGForce*StrFactor;
    NormForces(:,kk) = muscleForces(:,kk)./MaxIsomForce;
end



