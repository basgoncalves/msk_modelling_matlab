% S = struct
% Str = String to be removed from S fields names 
function S = TrimStruct (S,Str) 
%% This function is need so the xml_write does not save values of 'true' as [true] logicals which will cause problems with running the scale tool in OpenSim.
if isstruct(S)                                                                                                      % recursive loop that checks all "apply" fields and changed them to a string
    F = fields(S);
    S = removeField(S,Str);
    for i = 1:length(F)
        s = S.(F{i});
        for ii = 1:length(s)
            s(ii) = TrimStruct(s(ii),Str);
        end
        S.(F{i}) = s;
    end
end

function S2 = removeField(S,Str)
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