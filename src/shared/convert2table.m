

function T = convert2table(cellArray)

data = cellArray(2:end,:);

% remove header symbols
allowedSymbols = 'A-Za-z0-9_';
header = strrep(cellArray(1,:),' ','_');
header = regexprep(header, ['[^', allowedSymbols, ']'], '');

% make the headers max 63 digits long (max for matlab)
for i = 1:length(header)
    if length(header{i})>63; header{i} = header{i}(1:63); end
end

% make empty cells = NaN
data(cellfun(@isempty, data)) = {NaN};

T = cell2table(data, 'VariableNames', header);