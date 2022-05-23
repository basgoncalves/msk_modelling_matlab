function [ nDofs, nMuscles, dofAnglesFilename, musclesFilename ] = generateMcbsCfg( osimFilename, ceinmsSubject, nPoints, path, sep )
%GENERATECFG Summary of this function goes here
%   Detailed explanation goes here
addpath('shared')
addpath('xml_io_tools')
fp = getFp();
if nargin < 3
    nPoints = 9;
end
if nargin < 4
    path = ['.' fp];
end
if nargin < 5
    sep = '\t';
end

path = [path fp 'ceinms' fp 'mcbs'];

if path(end) ~= fp
    path = [path fp];
end

if exist(path, 'dir') ~= 7
    mkdir(path);
end

[~,n,e] = fileparts(osimFilename);
copyfile(osimFilename,join([path fp n e],''));

path = join([path fp 'cfg'],'');

if path(end) ~= fp
    path = [path fp];
end

if exist(path, 'dir') ~= 7
    mkdir(path);
end

sbj = xml_read(ceinmsSubject);

[nDofs, dofAnglesFilename, dofNames] = createDofAngles(osimFilename, sbj, nPoints, path, sep);
[nMuscles, musclesFilename] = createMusclesIn(sbj,dofNames, path, sep);


end

function [nDofs, outputFilename, dofNames] = createDofAngles(osimFilename, sbj, nPoints,path, sep)
fp = getFp();
import org.opensim.modeling.*
dofsToUse = {sbj.dofSet.dof(:).name};
osimModel = Model(osimFilename);
nCoords = osimModel.getNumCoordinates();
k = 1;
for i=0:nCoords-1
    crd = osimModel.getCoordinateSet().get(i);
    if(ismember( char(crd.getName()), dofsToUse) && ~crd.getDefaultLocked())
        dofs{k}.name = char(crd.getName());
        dofNames{k} = dofs{k}.name;
        dofs{k}.romMax = crd.getRangeMax();
        dofs{k}.romMin = crd.getRangeMin();   
        k = k+1;
        
    end
end

outputFilename = [path fp 'dofAngles.cfg'];
dofAnglesFile = fopen(outputFilename,'w');
fprintf(dofAnglesFile, ['ndof' sep num2str(length(dofs)) '\n']);
for i=1:length(dofs)
    fprintf(dofAnglesFile, ...
        [dofs{i}.name sep ...
        num2str(dofs{i}.romMin) sep ...
        num2str(dofs{i}.romMax) sep ...
        num2str(nPoints) '\n']);
end
nDofs = length(dofs);
end

function [nMuscles, outputFilename] = createMusclesIn(sbj,dofNames, path, sep)
fp = getFp();
muscles = {sbj.mtuSet.mtu(:).name};
muscleToDofsMap = containers.Map();
dofsToUse = intersect({sbj.dofSet.dof(:).name}, dofNames);
for i=1:length(muscles)
   currentMuscle = muscles{i};
   dofsOnMuscle = {};
   for d=1:length(dofsToUse)
       if(ismember(currentMuscle, sbj.dofSet.dof(d).mtuNameSet))
           dofsOnMuscle = cat(1, dofsOnMuscle, dofsToUse{d});
       end  
   end
   muscleToDofsMap(currentMuscle) = dofsOnMuscle;
end

outputFilename = [path fp 'muscles.in'];
musclesFile = fopen(outputFilename,'w');
for i=1:length(muscles)
    currentMuscle = muscles{i};
    fprintf(musclesFile, currentMuscle);
    currentDofs = muscleToDofsMap(currentMuscle);
    for k=1:length(currentDofs)
        fprintf(musclesFile, [sep currentDofs{k}]);
    end
    fprintf(musclesFile, '\n');
end
nMuscles =length(muscles);
end
