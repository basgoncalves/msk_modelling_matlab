%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%copies the folders from '...BiodexData\\ElaboratedData\\sessionData' to
%'...ElaboratedData\\sessionData' for multiple subjects 
%
%CALLBACK FUNCTIONS
%   uigetmultiple
%   copyMultipleFolder2
%

function convertToMat

fp = filesep;
[subjects] = uigetmultiple;
cd (subjects{1})
for i = 1: length (subjects)
        
    % conver Biodex data from .dat to mat
    dat2mat([subjects{i} fp 'BiodexData'])
    sourceFile =[subjects{i} '\BiodexData\ElaboratedData\sessionData'];
    destinationFolder = [subjects{i} '\ElaboratedData\sessionData'];
    copyMultipleFolder2 (sourceFile,destinationFolder);                   % use CALLBACK fucntion to copy multiple files in each subject dir
    
       % conver rig data from .c3d to mat
    C3D2MAT_BG([subjects{i} fp 'InputData'],{})
    
    idDash = strfind(subjects{i},'\');                                   % find the backslashes in the directory of each subject
    currentSubject = subjects{i}(idDash(end)+1:end);                     % get the name of each subject (from last dash onwards)
    sprintf ('data from %s copied ',currentSubject)                      % pop up message
    
end