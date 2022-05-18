function output = deleteZeros (input,logic)

output = input;

% logic = 1(columns) / 2(row)
% https://au.mathworks.com/matlabcentral/answers/40018-delete-zeros-rows-and-columns
if ~exist('logic') || logic == 2

    for cc = 1:
output( :, ~any(output,1) ) = [];  %columns

elseif logic == 1 
output( ~any(output,2), : ) = [];  %rows
end