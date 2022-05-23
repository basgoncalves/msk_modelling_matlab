function yaxisnice(nticks)


yticks([min(ylim):range(ylim)/nticks:max(ylim)])
if range(ylim)<1 && range(ylim)>0.1
    n = 1;
elseif range(ylim)>4
    n = 0;
else
     n = 1;
end
yticklabels(round(yticks,n))