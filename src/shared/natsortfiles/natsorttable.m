%% outTable = natsorttable(inTable)
% sort the columns of a table alhpahnumericlly by heading names
%
%-------------------------------------------------------------------------
%INPUT
% KeepFirstCol = 0 (default) for no or 1 for yes;
%
%see also:   natsortfiles
%
% Written by Basilio Goncalves (2021) https://www.researchgate.net/profile/Basilio_Goncalves
function outTable = natsorttable(inTable,KeepFirstCol)

if nargin<2; KeepFirstCol=0; end

outTable = inTable;
 
if KeepFirstCol==0
    sortedNames = natsortfiles(outTable.Properties.VariableNames); % sort alpha numerically (by  Stephen Cobeldick)
    outTable = outTable(:,sortedNames);
    
elseif KeepFirstCol==1
    sortedNames = natsortfiles(outTable.Properties.VariableNames(2:end)); % sort alpha numerically (by  Stephen Cobeldick)
    table2array([outTable(:,1) outTable(:,sortedNames)]);
end

