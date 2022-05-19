function [sessionConditions] = conditionNames(c3dFiles)
%Determine names of condition tested in Load Sharing Trial
%   Inpout list of c3d files and output the names of the conditions tested.
% Determine name of the conditions in the session

% First find when c3d files are large enough to remove non-walking trials
isubby = [c3dFiles(:).bytes]';
bigFiles = isubby > 1500000;
nameOfConditions = c3dFiles(bigFiles);
nameOfConditions(strncmp({nameOfConditions.name}, 'Static1', 7)) = [];
nameOfConditions(strncmp({nameOfConditions.name}, 'KneeFJC', 7)) = [];

% Now output the condition names without the guff at the end of the
% filename
sessionConditions = {};
for n = 1:length(nameOfConditions)
     sessionName = nameOfConditions(n).name(1:end-19);
     sessionConditions = [sessionConditions, sessionName];
end

% Delete duplicates
wd=sessionConditions';
[~,idx]=unique(  strcat(wd(:,1)));
sessionConditions=wd(idx,:)';

end

