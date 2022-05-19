function tight_subplot_ticks (ha,xt,yt)
% tight_subplot_ticks adds xticklabels and yticklables to the assigned
% subplots in "ha" (if xt OR yt == 0, add labels to all subplots)
%
% tight_subplot_ticks (xt,yt)
%
% see also tight_subplotBG

N = length(ha);
for i = 1:length(ha)
    axes(ha(i));
    if any(xt==i) || any(xt==0)
        xticklabels(xticks)
    end
    
    if any(yt==i) || any(yt==0)
        yticklabels(yticks)
    end
end
