function [ outputXmlFilename ] = generateContactForcesXml( intercondyleDistance, side, baseDir )
%GENERATECONTACTFORCESXML Summary of this function goes here
%   Detailed explanation goes here

    addpath('xml_io_tools');
    
    fp = getFp();

    if nargin < 2
        side = 'right';
    end
    if nargin < 3
        baseDir = '.';
    end
    
    if strcmp(side, 'right')
        suffix = '_r';
    else
        suffix = '_l';
    end
    
    if baseDir(end) ~= fp
        baseDir = [baseDir fp];
    end

    
    outputDir = [baseDir fp 'ceinms' fp 'contactModels'];
    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir)
    end
        
    cm.kneeBalance.intercondyleDistance = intercondyleDistance;
    cm.kneeBalance.condyle{1}.name = ['medial_condyle' suffix];
    cm.kneeBalance.condyle{1}.dof= ['knee_varus_med' suffix];
    cm.kneeBalance.condyle{2}.name = ['lateral_condyle' suffix];
    cm.kneeBalance.condyle{2}.dof= ['knee_varus_lat' suffix];
    
    refXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
    prefXmlWrite.CellItem   = false;
    
    outputXmlFilename = [outputDir fp 'contactModel.xml'];
    xml_write(outputXmlFilename, cm, 'contactModel', prefXmlWrite);

end

