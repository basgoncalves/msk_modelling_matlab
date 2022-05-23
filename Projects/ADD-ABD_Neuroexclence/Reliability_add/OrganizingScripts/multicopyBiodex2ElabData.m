%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%copies the folders from '...BiodexData\\ElaboratedData\\sessionData' to
%'...ElaboratedData\\sessionData' for multiple subjects 
%
%CALLBACK FUNCTIONS
%   copyMultipleFolder2
%
%USE 
%   Select multiple folders 
%% Start Script

[subjects] = uigetmultiple;
cd (subjects{1})
for i = 1: length (subjects)
   
    
   sourceFile = sprintf ('%s\\BiodexData\\ElaboratedData\\sessionData',subjects{i});
   destinationFolder = sprintf ('%s\\ElaboratedData\\sessionData',subjects{i});
    
   copyMultipleFolder2 (sourceFile,destinationFolder);                   % use CALLBACK fucntion to copy multiple files in each subject dir 
   
   idDash = strfind(subjects{i},'\');                                   % find the backslashes in the directory of each subject
   currentSubject = subjects{i}(idDash(end)+1:end);                     % get the name of each subject (from last dash onwards)
   sprintf ('data from %s copied ',currentSubject)                      % pop up message
   
end