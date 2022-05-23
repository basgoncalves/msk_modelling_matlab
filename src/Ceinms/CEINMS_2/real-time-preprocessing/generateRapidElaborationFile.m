function [ output_args ] = generateRapidElaborationFile(c3dPath)
%GENERATERAPIDELABORATIONFILE Summary of this function goes here
%   Detailed explanation goes here

    addpath('shared');
    fp = getFp();
    motonmsPath = getMOtoNMSpath();
    cwd = pwd;
    cd([motonmsPath fp 'src' fp 'DataProcessing']);
    ElaborationInterface();
    cd(cwd);
end

