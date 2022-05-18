%% load csv or xml file

function output = loadcsv (FileDir)

warning on 
if ~exist ('FileDir') || ~isfile (FileDir)
    warning ('Directory not found')
    [filename,filepath,~] = uigetfile({'*.*';'*.xls';'*.csv'});
    FileDir = [filepath filesep filename];
        
end

if ~contains(FileDir,'.xls') && ~contains(FileDir,'.csv')
    error ('%s is not a .xls or .csv file',FileDir)
end

cd(fileparts(FileDir))
[output.NUM,output.TXT,output.RAW] = xlsread(FileDir);
