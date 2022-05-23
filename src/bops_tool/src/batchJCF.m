% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% batch run of JCF
% run MOtoNMS scripts before this script
% Todo: rewrite JCF function, a bit of a mess
%       use the same GRF xml for all analysis (ID, SO, JCF)

%% Load subject data
% subjectInfo={...
%    'H25s1_Copy','R','L','M'; %uncomment if wanting to define subjects here, instead of loadGenAllSubjDataAndDirInWorkspace.m
%        }; 
% ageHeightMass=[... 
%     54.50,181.7,108.4; %H25s1
%        ]; 

if exist('subjectInfo','var')
    doNotAutoLoadSubjectInfo='true';
else
    doNotAutoLoadSubjectInfo='false';
end
loadGenAllSubjDataAndDirInWorkspace
%%
fcut_coordinates=6;

%% Joint Contact Force (hip emgSide)
JCFTemplateXml=['..\Templates\JCFProcessing\Setup_JCFAnalyze.xml'];
parfor s=1:nSubject
    disp(subject{s})
    mainJCF(dirElabDynamic{s}, idJCF, modelFileFullPath{s}, fcut_coordinates, JCFTemplateXml, OpenSimSide{s});
end