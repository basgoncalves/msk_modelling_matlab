function S = ConvertLogicToString(S,fieldName)
%% This function is need so the xml_write does not save values of 'true' as [true] logicals which will cause problems with running the scale tool in OpenSim.
if nargin < 2
    fieldName = 'apply';
end

if isstruct(S)                                                                                                      % recursive loop that checks all "apply" fields and changed them to a string
    F = fields(S);
    S = editApplyField(S,F,fieldName);
    for i = 1:length(F)
        s = S.(F{i});
        for ii = 1:length(s)
            s(ii) = ConvertLogicToString(s(ii),fieldName);
        end
        S.(F{i}) = s;
    end
    
end

function s = editApplyField(s,f,fieldName)
%% converts "apply" flieds from [true] / [false] to 'true' / 'false'

try s.(fieldName);
    if islogical(s.(fieldName)) && length(s.(fieldName))<2
        if s.(fieldName)== 1
            s.(fieldName) = 'true';
        elseif s.(fieldName) == 0
            s.(fieldName) = 'false';
        end
    else
        s.(fieldName) = num2str(s.(fieldName));
    end
catch
end
