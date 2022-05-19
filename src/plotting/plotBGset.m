% T = table to be used to find the correct settings 
% Table should have column1 = Group, Column2=ID(starting from 1 for each group) 
function PP = plotBGset(T,N)

PP.alpha = 0.2; PP.FontSize=15;PP.MarkerSize = 10;
PP.Ncols = 1; PP.Nrows = 2;
PP.gap=[0.05 0.05]; PP.marg_h = [0.2 0.03]; PP.marg_w=[0.2 0.05]; PP.size = [2177 100 560 800];
PP.title ={};

if nargin > 0 && contains(class(T),'table') && size(T,2)>3
    if nargin==1;N=4;end
    if length(T.Properties.VariableNames)<N
        PP.ylabel = {[T.Properties.VariableNames{N} '(' T.Properties.VariableUnits{N} ')']};
    else
        PP.ylabel = {};
    end
    PP.xticklabels = T.Properties.VariableNames(4:end);
    PP.legend = unique(T.Group);
else
    PP.ylabel = {};
    PP.xticklabels = {};
    PP.legend = {};
end

