% from https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions

function mergedTable = combineTables(t1,t2,CombiningHeader)

% example data 
if nargin < 2
    disp('========================')
    disp('using example data...')
    disp('========================')
    pause(0.8)

    t1 = table({'A';'B';'C'}, [1;3;6],{'F';'A';'F'}, 'VariableNames', {'Subject', 'Height','Group'});
    t2 = table({'D';'C'}, [3;6], 'VariableNames', {'Subject', 'Weight'});
end


% check if both t1 and t2 have the "CombiningHeader"
try 
    t1.(CombiningHeader); t2.(CombiningHeader);
catch 
    error(['both tables should contain the CombiningHeade: "' CombiningHeader '" to be able to merge'])
end

% find missing columns names
t1colmissing = setdiff(t2.Properties.VariableNames, t1.Properties.VariableNames);
t2colmissing = setdiff(t1.Properties.VariableNames, t2.Properties.VariableNames);

% add missing columns with NaNs
t1 = [t1 array2table(nan(height(t1), numel(t1colmissing)), 'VariableNames', t1colmissing)];
t2 = [t2 array2table(nan(height(t2), numel(t2colmissing)), 'VariableNames', t2colmissing)];

% delete columns and replace NaN by empty cells in t1
for i = 1:numel(t1colmissing)
    if iscell(t2.(t1colmissing{i}))     % if the missing columns contains cell elements
        t1.(t1colmissing{i}) = [];      % delete
        t1.(t1colmissing{i})(:) = {''}; 
    end
end

% same for t2
for i = 1:numel(t2colmissing)
    if iscell(t1.(t2colmissing{i}))     % if the missing columns contains cell elements
        t2.(t2colmissing{i}) = [];      % delete columns and replace NaN by empty cells
        t2.(t2colmissing{i})(:) = {''}; 
    end
end

% t = outerjoin(t1, t2, 'Keys', CombiningHeader);
mergedTable = [t1;t2];

% find the unique values in the header to use to combine tables
combineColumn_UniqueValues = unique(mergedTable.(CombiningHeader));
rowsToDelete = [];

for i = flip(1:length(combineColumn_UniqueValues))    
    rows_containing_element = find(mergedTable.(CombiningHeader)==combineColumn_UniqueValues(i));
    rowToKeep = min(rows_containing_element);

    if length(rows_containing_element)>1
        rowsToDelete = [rowsToDelete rows_containing_element(rows_containing_element~=rowToKeep)];
    end

    % Loop through all variables in the table
    for iVar = 1:width(mergedTable)

        % if all elements are the same, keep first value
        if length(unique(mergedTable.(iVar)(rows_containing_element))) == 1
            idx_row_to_keep = 1; 
        else

            try
                % get indices of non-nans rows
                idx_row_to_keep = ~isnan(mergedTable.(iVar)(rows_containing_element));
            catch
                % get indices of non-empty rows
                idx_row_to_keep = find(~cellfun(@isempty, mergedTable.(iVar)(rows_containing_element)));
            end
        end

        % if idx is empty keep first value
        if ~any(idx_row_to_keep); idx_row_to_keep = 1; end 
        
        row_value_to_keep = rows_containing_element(idx_row_to_keep);
        mergedTable.(iVar)(rowToKeep) = mergedTable.(iVar)(row_value_to_keep);
    end
end

rowsToDelete = unique(rowsToDelete);

mergedTable(rowsToDelete,:) = [];








