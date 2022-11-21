
function S = rmfield_all_levels(S,Str)
%% This function is needed so the xml_write does not save values of 'true' as [true] logicals which will cause problems with running the scale tool in OpenSim.
if isstruct(S)                                                                                                      % recursive loop that checks all "apply" fields and changed them to a string
    S = removeField(S,Str);
    F = fields(S);
    for i = 1:length(F)
        for ii = 1:length(S)
            S(ii).(F{i}) = rmfield_all_levels(S(ii).(F{i}),Str);
        end
    end
end

function S2 = removeField(S,Str)
S2 = S;
fld = fields(S);
for ii = 1: length(fld)
    if isequal(Str,fld{ii})
        S2 = rmfield(S, Str);
    end
end