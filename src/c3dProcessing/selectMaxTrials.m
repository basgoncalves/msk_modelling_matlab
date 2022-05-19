function [dynamicCropFolder] = selectMaxTrials(c3dFolder)
%Removes filenames that are not dynamic walking trials in the load sharing
%data
%   Input folder where all c3d files are located and removes the ones
%   specified by the user.

     % Delete files I don't want to analyse
     c3dFolder(strncmp(c3dFolder, 'HF', 2)) = [];
     c3dFolder(strncmp(c3dFolder, 'Shoulder', 8)) = [];
     c3dFolder(strncmp(c3dFolder, 'TF', 2)) = [];
     c3dFolder(strncmp(c3dFolder, 'Static1', 7)) = [];
     c3dFolder(strncmp(c3dFolder, 'UUA', 3)) = [];
     c3dFolder(strncmp(c3dFolder, '.', 1)) = [];
     c3dFolder(strncmp(c3dFolder, '..', 2)) = [];
     
     c3dFolder(~strncmp(c3dFolder, 'KneeFJC', 7)) = [];

     dynamicCropFolder = c3dFolder;
     
end

