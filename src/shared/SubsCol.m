% substitute data with next column values
%   INPUT = 2 column Matrix 
%   OUTPUT = colums vector
function output = SubsCol (input)

output =[];
input(input==0)=NaN;
for r = 1:size(input,1)             % through all the rows
   
    if isnan(input(r,1))
       output(r,1) = input(r,2);
    else
       output(r,1) = input(r,1);
    end
end