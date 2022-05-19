%
% S = structure with different 

function [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S)

fld = fields(S);
% RMSE and Rsquared
combos = combntns([1:length(fld)],2);
for ii = 1: size(combos,1)
    x = S.(fld{combos(ii,1)});
    y = S.(fld{combos(ii,2)});
    
    % delete the NaN rows from both arrays
    id = isnan(x(:,1));
    x(id,:) =[]; y(id,:) =[];
    id = isnan(y(:,1));
    x(id,:) =[]; y(id,:) =[];
    
    RMSE (ii,:) = rms(x-y);
    RMSELabels{ii} = [fld{combos(ii,2)} ' - ' fld{combos(ii,1)}];
    
    % Rsquared
    for cc = 1: size(x,2)
        [c, pvalue] = corrcoef(x(:,cc),y(:,cc));
        rsquared(ii,cc) = c(1,2)^2;
        pvalue(ii,cc) = pvalue(1,2);
    end
end

% make a vertical list
RMSELabels = RMSELabels';

% RMS( each row = 1 field)
for ii = 1: length(fld)
    x = S.(fld{ii});
    id = isnan(x(:,1));
    x(id,:) =[];
    RMS(ii,:) = rms(x);
end

end