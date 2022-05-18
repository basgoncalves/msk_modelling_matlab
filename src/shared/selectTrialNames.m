%select data names to analyse

function Files = selectTrialNames (DataDir,DataExt,ConvertToCell)

if ~exist('DataExt')                                                                                                % if data extension does not exist use all data types
    DataExt ='*.*';
elseif ~contains (DataExt, '.')                                                                                     % if it exists but does not contain a dot by mistake
    DataExt =['.' DataExt];
end
if ~contains (DataExt, '*')                                                                                         % if it exists but does not contain a dot by mistake
    DataExt =['*' DataExt];
end
if ~exist('DataDir','var') || ~contains(class(DataDir),'char')
    prompt = sprintf('Select a folder where your %s files are stored',DataExt);
    DataDir = uigetdir('',prompt);
end


Files = ls([DataDir filesep DataExt]);                                                                              % get the information about the files 
 

if isempty(Files)
    error('no files exists in %s with extension %s', DataDir, DataExt)
end


if nargin > 2 && ConvertToCell == 1
   Files = cellstr(Files);                                                                                          % convert to cell if needed
end
