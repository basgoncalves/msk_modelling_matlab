

function IntrapolateMA(filename)

A = load_sto_file(filename);

flds = fields(A);

% convert from struct to double
B = [];
for k = 1:length(flds)
    B(:,k) = A.(flds{k}); 
end

if B(end,1) == B(end-1,1)
    B(end,:) = [];
elseif B(end,1)<B(end-1,1)+0.001
    B(end,:) = [];
end
T = round(B(:,1),4);
% T2 = T(1):T(2)-T(1):T(end);
T2 = round(T(1):0.005:T(end),4);

% find common time point between T2 and T
[idx,~] = find(T2==T);
B = B(idx,:);

% create a new struct with a field for each row of data 
C = struct;
for k = 1:length(flds)
    flds{k} = strtrim (flds{k});
    C.(flds{k}) = B(:,k);
end

write_sto_file_MA(C, filename)