% copy all folders from original
% MoveorCopy = 1 for copy (default) or other to move files
function [] = copyMultipleFiles (sourceFolder,destinationFolder,MoveorCopy,extensionsToCopy)

if nargin ==0                        %if DatFolder does not exists
sourceFolder = uigetdir ('Name','select the original folder to copy');
destinationFolder = uigetdir ('Name','select the destination folder');
end

if nargin <3
    MoveorCopy = 1;
end

if ~isfolder(destinationFolder)
    mkdir(destinationFolder)        
end

%% get Files in the subject folder and subject code
cd(sourceFolder);
Trials = dir;
Trials (1:2)=[];

for i=1:length (Trials)                                                             % loop through all subjects

    copyFile = sprintf('%s\\%s' , sourceFolder,Trials(i).name);                     % Name original folder to copy
    pasteFile = sprintf ('%s\\%s',destinationFolder, Trials(i).name);               % Name destination folder to paste
    [~,~,fileExtension] = fileparts(copyFile);
    
    if nargin > 3 && ~contains(fileExtension, extensionsToCopy)
       continue
    end
    
    if MoveorCopy == 1
        copyfile(copyFile, pasteFile)
    else
        movefile(copyFile, pasteFile)
    end
  
end