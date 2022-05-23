% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% Main script for joint contact analysis
% Warning: this script may be hardcoded for my folder setup!
% JCFid-consistent with MOToNMS
% Outputs:
%TODO: allow each trial to have different footstrike, atm all trials from a
%           subject has the same footstrike pattern
%    : lowpass hardcoded in xml template for external forces

function [JCFoutputDir, JCFtrialsOutputDir]=mainJCF(inputDir,JCFid, model_file, fcut_coordinates, JCFTemplateXml,EMG_OpenSim_side)
%%
%Get trials in the input folder
trialsList = trialsListGeneration(inputDir);

%fcut_coordinates=8;
inputTrials=trialsList; %list of input trials includes all trials

%%
[JCFoutputDir, JCFtrialsOutputDir]=runJointContactAnalysis(inputTrials, inputDir, JCFid, model_file, fcut_coordinates, JCFTemplateXml,EMG_OpenSim_side); 


