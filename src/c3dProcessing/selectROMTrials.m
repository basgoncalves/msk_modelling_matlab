function [ROMFolder] = selectROMTrials(c3dFolder, sessionConditions)
%Removes filenames that are not range of motion trials in the load sharing
%data
%   Input folder where all c3d files are located and removes the ones
%   specified by the user.

for i = 1 : length(sessionConditions)
     % Remove files that begin with sessionConditions because these are
     % walking trials.
     c3dFolder(strncmp(sessionConditions{i}, c3dFolder, length(sessionConditions{i}))) = [];
     
end

     c3dFolder(strncmp(c3dFolder, 'Static1', 7)) = [];
     c3dFolder(strncmp(c3dFolder, '.', 1)) = [];
     c3dFolder(strncmp(c3dFolder, '..', 2)) = [];
     c3dFolder(strncmp(c3dFolder, 'KneeFJC', 7)) = [];
     
     ROMFolder = c3dFolder;
     
end

