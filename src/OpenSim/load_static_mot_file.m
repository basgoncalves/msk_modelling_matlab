function out = load_static_mot_file(staticFilePath)

warning off

% if file doesnt exist ask user for one
if nargin < 1 || ~exist('staticFilePath') 
   [filename,pathname] = uigetfile('*.*',cd); 
   staticFilePath = [pathname filename];
end

% load data
try Data = importdata(staticFilePath);
catch 
    disp(['data could not be loaded for:' staticFilePath])
    return
end

% round data not to have problems with very small decimal points
Data.data = round(Data.data,4); 

% create labvels without the / (including the first character)
Labels = strrep(Data.colheaders,'/','_');
for i = 2:numel(Labels); Labels{i} = Labels{i}(2:end); end

% create data matrix
DataMatrix = Data.data;

% create data struct
out = struct;
for i =1:length(Labels)
    out.(Labels{i}) = DataMatrix(:,i);
end



