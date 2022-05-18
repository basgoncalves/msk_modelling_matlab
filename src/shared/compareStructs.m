

function [equal, differences] = compareStructs(s1,s2)


f1 = sort(fields(s1));
f2 = sort(fields(s2));
equal = 1;
differences = {};
if length(f1) ~= length(f2)
    equal = 0;
else
    for i = 1:length(f2)
        if ~isequal(s1.(f1{i}),s2.(f2{i}))
            equal = 0;
            differences{end+1} = f1{i};
        end
    end  
end