function A = ZeroToNaN(A)


% Loop through each column
for col = 1:size(A, 2)
    if all(A(:, col) == 0)
        
        % Replace column with NaN values
        A(:, col) = NaN;  
    end
end