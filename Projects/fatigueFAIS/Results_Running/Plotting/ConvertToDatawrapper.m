%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Convert data to a CSV format to be used in "datawrapper.de"
% Run scripts before:
%   - importExternalBiomech.m (in PHD_RS_FAIS_results)
%   - splitDataInGroups_TimeVariant.m (in PHD_RS_FAIS_results)
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%
%INPUT
%   IndData = cell vector where each element is a double matrix showing individual
%   data (column) over percentage of gait cycle (row)
%   Subj = cell vector where each element is a cell vector with strings 
%   representing the ID of each individual
%-------------------------------------------------------------------------
%OUTPUT
%   
%--------------------------------------------------------------------------

function CSVfile = ConvertToDatawrapper(IndData,Subj)

NGroups = length(IndData);

if length(Subj) ~= NGroups
   error('Inputs must be the same length')
end

CSVfile = {'% GaitCycle'}; % create first column (%gait cycle)
CSVfile(2:102,1) = num2cell(0:100)';

for i = 1:NGroups % loop through each group of participants (cell in IndData)
    
    [Nrows,Ncols] = size(IndData{i});
    
    % create a cell with heading (Group) and IndData
    CellData = cell(Nrows+1,Ncols+1);
    CellData(1,1) = {['Mean_' Subj{i}]}; % add a mean column before the data
    CellData(1,2:end) = split(cellstr(sprintf([Subj{i} '%d '],1:Ncols)),' ')'; 
    CellData(2:end,:) = num2cell([mean(IndData{i},2) IndData{i}]); % mean data (col 1) + individuals data
    CSVfile =  [CSVfile CellData];
    

end


