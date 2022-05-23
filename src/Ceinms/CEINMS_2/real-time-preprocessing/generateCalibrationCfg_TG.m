function [ calibrationCfgFilename ] = generateCalibrationCfg(trialList, baseDir, side)
%SELECTTRIALS Summary of this function goes here
%   Detailed explanation goes here
    addpath('shared');
    addpath('xml_io_tools');

    fp = getFp();
    useRelativePath = true;
    if nargin < 2
        baseDir = '.';
    end
    
    
    if baseDir(end) ~= fp
        baseDir = [baseDir fp];
    end

    %%outputDir
    outDir = [baseDir 'ceinms' fp 'calibration' fp 'cfg'];
    if (exist(outDir,'dir') ~= 7)
        mkdir(outDir);
    end

    
    if useRelativePath
        for i = 1:length(trialList)
            [p,n,e] = fileparts(trialList{i});
            trialList{i} = [relativepath(p, outDir) n e];
        end
    end
    
    
    templateDir = ['Template' fp 'calibration'];
    if strcmp(side,'R')
        calibrationCfgTemplateFilename = [templateDir fp 'calibrationCfgTemplate-RIGHT.xml'];
    else 
        calibrationCfgTemplateFilename = [templateDir fp 'calibrationCfgTemplate-LEFT.xml'];
    end
    prefXmlRead.Str2Num = 'never';
    prefXmlRead.NoCells=false;
    tree = xml_read(calibrationCfgTemplateFilename, prefXmlRead);
    
    trialsString = convertPathToLinux(trialList{1});
    for j = 2:length(trialList)
        trialsString = [trialsString, ' ', convertPathToLinux(trialList{j})];
    end
    
    nmsModel = 'openLoop';
    tree.NMSmodel.type.(nmsModel) = struct;
    nmsModel = 'equilibriumElastic';
    tree.NMSmodel.tendon.(nmsModel) = struct;
    nmsModel = 'exponential';
    tree.NMSmodel.activation.(nmsModel) = struct;
    
    % check all the parameters
    N = length(tree.calibrationSteps.step.parameterSet.parameter);% numnber of parameters
    
    for ii =1: N
        if sum(contains(fields(tree.calibrationSteps.step.parameterSet.parameter{ii}),'single'))>0
            tree.calibrationSteps.step.parameterSet.parameter{ii}.single=struct;
        end
    end
    
    tree.trialSet = trialsString;
    prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
    prefXmlWrite.CellItem   = false;
    calibrationCfgFilename = [outDir fp 'calibrationCfg.xml'];
    xml_write(calibrationCfgFilename, tree, 'calibration', prefXmlWrite);
    
end
