% S = struct
% Str = String to be removed from S fields names 

function S2 = TrimStruct (S,Str)
S2 = struct;
fld = fields(S);
for ii = 1: length(fld)
        NewFld = erase(fld{ii}, Str);
        if isfield(S2,NewFld)
            S2.(NewFld) = [S2.(NewFld) S.(fld{ii})];
        else 
            S2.(NewFld) = S.(fld{ii});
        end
end

