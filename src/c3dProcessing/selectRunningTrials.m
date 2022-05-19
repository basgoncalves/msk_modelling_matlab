function [dynamicCropFolder] = selectRunningTrials(c3dFolder, isKneeFJC)
%Removes filenames that are not dynamic walking trials in the load sharing
%data
%   Input folder where all c3d files are located and removes the ones
%   specified by the user.

     % Delete files I don't want to analyse
     c3dFolder(strncmp(c3dFolder, 'HF', 2)) = [];
     c3dFolder(strncmp(c3dFolder, 'Shoulder', 8)) = [];
     c3dFolder(strncmp(c3dFolder, 'TF', 2)) = [];
     c3dFolder(strncmp(c3dFolder, 'static1', 7)) = [];
     c3dFolder(strncmp(c3dFolder, 'UUA', 3)) = [];
     c3dFolder(strncmp(c3dFolder, '.', 1)) = [];
     c3dFolder(strncmp(c3dFolder, '..', 2)) = [];
	 c3dFolder(strncmp(c3dFolder, 'maxEMG', 6)) = [];
	 c3dFolder(strncmp(c3dFolder, 'emgMax', 6)) = [];
	 
	 % select running trials

for ff = 1:length (c3dFolder)  

    if ~contains(c3dFolder(ff),'Run','IgnoreCase',true)&&contains(c3dFolder(ff),'1')
       c3dFolder(ff)=[];
    end

end
	 
     c3dFolder(strncmp(c3dFolder, 'emgMax', 6)) = [];
	 
     if isKneeFJC ==0
     c3dFolder(strncmp(c3dFolder, 'KneeFJC', 7)) = [];
     end
     dynamicCropFolder = c3dFolder;
     
end

