%% Description - Goncalves, BM (2019)
% check which participants have EMG data analysed
%
%   Generalfilename = name of the file to look in each folder
%   Folders = generated from uigetmultiple
function ExistingFiles = checkFileExists (Generalfilename,Folders)
if ~exist('Folders')
prompt = sprintf('select all the folders to look search for the file called %s',Generalfilename);
Folders = uigetmultiple('',prompt);
end

[nRow,Ncol] = size (Folders);
ExistingFiles = {};
for ss = 1:Ncol 
    
    if exist([Folders{ss} filesep Generalfilename])
        folder = split(Folders{ss},filesep);
        ExistingFiles{end+1}=folder{end};
    end
    
end 

ExistingFiles=ExistingFiles';

if isempty(ExistingFiles)
   fprintf('no files exist with the name %s \n \n', Generalfilename)
   fprintf('ensure the name contains the extension of the file (eg. File.mat) \n \n')
end