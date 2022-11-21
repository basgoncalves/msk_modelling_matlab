% copy all folders from original

function [] = copyMultipleFolder (sourceFile,destinationFolder)

if nargin ==0                        %if DatFolder does not exists
sourceFile = uigetdir ('Name','select the original folder to copy');
destinationFolder = uigetdir ('Name','select the destination folder');
end
%% get Files in the subject folder and subject code
cd(sourceFile);
Trials = dir;
Trials (1:2)=[];

for i=1:length (Trials)                                   % loop through all subjects

copyFolder = sprintf('%s\\%s' , sourceFile,Trials(i).name);                                 % Name original folder to copy
pasteFolder = sprintf ('%s\\%s',destinationFolder, Trials(i).name);                         % Name destination folder to paste       
       
    if exist(pasteFolder,'dir')==7  
        continue
        
    elseif exist (copyFolder,'dir')==7                          % check if the folder is directory 
       cd (destinationFolder)
       mkdir (Trials(i).name)
       copyfile(copyFolder, pasteFolder)        
    end
    
    
end
