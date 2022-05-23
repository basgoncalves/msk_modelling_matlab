function [dynamicCropFolder] = selectWalkingTrials(c3dFolder, isKneeFJC)
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
	 c3dFolder(strncmp(c3dFolder, 'maxEMG', 6)) = [];
	 c3dFolder(strncmp(c3dFolder, 'emgMax', 6)) = [];
	 
	 % NEED TO ADD CODE TO SORT THIS SO FILES ENDING WITH A NUMBER ARE NOT
	 % INCLUDED
	 c3dFileArray = [];
	 completeArray = [];
	 for i = 1:length(c3dFolder)

		 for ii = 1:10
			 pattern = num2str(ii-1);
			 TF = contains(c3dFolder{i}(end), pattern);
			 c3dFileArray = [c3dFileArray; TF];
			 
		 end
		 completeArray = [completeArray, c3dFileArray];
		 c3dFileArray = [];
	 end
	 
	 testTrue = true(0);
	 % Loop through again and remove trials with numbers at the end
	 for i = 1:length(c3dFolder)
		 % Build logical array of trials that contain numbers at end
		 if any(completeArray(:,i))
			 testTrue = [testTrue; true(1)];
		 else
			 testTrue = [testTrue; false(1)];
		 end
	 end
	 
	 c3dFolder(testTrue) = [];
	 
     c3dFolder(strncmp(c3dFolder, 'emgMax', 6)) = [];
	 
     if isKneeFJC ==0
     c3dFolder(strncmp(c3dFolder, 'KneeFJC', 7)) = [];
     end
     dynamicCropFolder = c3dFolder;
     
end

